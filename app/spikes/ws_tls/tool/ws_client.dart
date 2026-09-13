// SPIKE JETABLE — client PC de l'essai WebSocket TLS.
//
// dart run tool/ws_client.dart <hôte> <port> <empreinte-sha256> [messages]
//
// Scénarios :
//   1. empreinte correcte          -> connexion attendue, échanges et latences ;
//   2. empreinte différente         -> refus attendu (simulation de faux maître) ;
//   3. validation standard (racines système, sans épinglage) -> refus attendu.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ws_tls_spike/pinning.dart';

Future<void> main(List<String> args) async {
  if (args.length < 3) {
    stderr.writeln(
      'Usage : ws_client.dart <hôte> <port> <empreinte> [messages]',
    );
    exit(2);
  }
  final host = args[0];
  final port = int.parse(args[1]);
  final fingerprint = args[2].toLowerCase();
  final count = args.length > 3 ? int.parse(args[3]) : 50;
  final url = 'wss://$host:$port/ws';
  var failures = 0;

  stdout.writeln('Cible : $url');

  // 1. Épinglage strict de l'empreinte attendue.
  try {
    final result = await _exchange(url, _pinnedClient(fingerprint), count);
    stdout.writeln('1. EMPREINTE_CORRECTE : OK — $result');
  } catch (error) {
    failures++;
    stdout.writeln('1. EMPREINTE_CORRECTE : ÉCHEC inattendu — $error');
  }

  // 2. Faux maître simulé : le client attend une autre empreinte.
  final wrong = fingerprint.replaceRange(
    0,
    2,
    fingerprint.startsWith('00') ? 'ff' : '00',
  );
  try {
    await _exchange(url, _pinnedClient(wrong), 1);
    failures++;
    stdout.writeln(
      '2. EMPREINTE_DIFFERENTE : ÉCHEC — connexion acceptée à tort',
    );
  } catch (error) {
    stdout.writeln(
      '2. EMPREINTE_DIFFERENTE : refus attendu — ${_short(error)}',
    );
  }

  // 3. Validation standard sans épinglage : certificat auto-signé refusé.
  try {
    await _exchange(url, HttpClient(), 1);
    failures++;
    stdout.writeln(
      '3. VALIDATION_STANDARD : ÉCHEC — connexion acceptée à tort',
    );
  } catch (error) {
    stdout.writeln('3. VALIDATION_STANDARD : refus attendu — ${_short(error)}');
  }

  stdout.writeln(
    failures == 0 ? 'RÉSULTAT : conforme' : 'RÉSULTAT : $failures écart(s)',
  );
  exit(failures == 0 ? 0 : 1);
}

HttpClient _pinnedClient(String expected) {
  // Aucune autorité de confiance : seul le certificat dont l'empreinte est
  // exactement celle attendue est accepté.
  final client = HttpClient(context: SecurityContext(withTrustedRoots: false));
  client.badCertificateCallback = (certificate, host, port) =>
      sha256Fingerprint(certificate.der) == expected;
  return client;
}

Future<String> _exchange(String url, HttpClient client, int count) async {
  final connectWatch = Stopwatch()..start();
  final socket = await WebSocket.connect(
    url,
    customClient: client,
  ).timeout(const Duration(seconds: 10));
  final connectMs = connectWatch.elapsedMilliseconds;

  final replies = StreamIterator(socket);
  final rtts = <int>[];
  for (var i = 0; i < count; i++) {
    final watch = Stopwatch()..start();
    socket.add('ping-$i');
    if (!await replies.moveNext().timeout(const Duration(seconds: 5))) {
      throw StateError('flux fermé après $i messages');
    }
    final reply = jsonDecode(replies.current as String) as Map<String, Object?>;
    if (reply['echo'] != 'ping-$i') throw StateError('réponse inattendue');
    rtts.add(watch.elapsedMicroseconds);
  }
  await socket.close();
  client.close(force: true);

  rtts.sort();
  String ms(int micros) => (micros / 1000).toStringAsFixed(1);
  return 'connexion TLS+WS $connectMs ms ; $count échanges ; '
      'RTT min ${ms(rtts.first)} / médiane ${ms(rtts[rtts.length ~/ 2])} / '
      'max ${ms(rtts.last)} ms';
}

String _short(Object error) => error.toString().split('\n').first;
