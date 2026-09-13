// SPIKE JETABLE — serveur WebSocket TLS sur le téléphone maître.
//
// Au lancement : génère l'identité TLS dans un isolate, démarre le serveur
// sur le port 8443 et journalise les résultats (préfixe SPIKE| dans logcat).
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

import 'spike_server.dart';
import 'tls_identity.dart';

void main() => runApp(const SpikeApp());

class SpikeApp extends StatelessWidget {
  const SpikeApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(home: SpikeScreen());
}

class SpikeScreen extends StatefulWidget {
  const SpikeScreen({super.key});

  @override
  State<SpikeScreen> createState() => _SpikeScreenState();
}

class _SpikeScreenState extends State<SpikeScreen> {
  final _lines = <String>[];
  SpikeServer? _server;

  void _log(String message) {
    // ignore: avoid_print
    print('SPIKE|$message');
    if (mounted) setState(() => _lines.add(message));
  }

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    try {
      _log('GENERATION_IDENTITE en cours');
      final json = await Isolate.run(
        () => generateIdentityJson('juste-a-temps-spike'),
      );
      final identity = TlsIdentity.fromJson(json);
      _log(
        'GENERATION_MS ${(identity.generationMicros / 1000).toStringAsFixed(1)}',
      );
      _log('EMPREINTE ${identity.fingerprint}');

      final watch = Stopwatch()..start();
      _server = await SpikeServer.start(identity: identity, log: _log);
      _log(
        'SERVEUR_PRET port ${_server!.port} en ${watch.elapsedMilliseconds} ms',
      );

      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          _log('ADRESSE ${interface.name} ${address.address}');
        }
      }
    } catch (error, stack) {
      _log('ECHEC $error');
      _log('PILE ${stack.toString().split('\n').take(3).join(' | ')}');
    }
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Spike WebSocket TLS')),
    body: ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final line in _lines)
          SelectableText(line, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}
