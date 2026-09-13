// SPIKE JETABLE — serveur WebSocket sur TLS embarqué (dart:io).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'tls_identity.dart';

typedef SpikeLog = void Function(String message);

class SpikeServer {
  SpikeServer._(this._server, this._log);

  final HttpServer _server;
  final SpikeLog _log;
  int connections = 0;
  int messages = 0;

  int get port => _server.port;

  static Future<SpikeServer> start({
    required TlsIdentity identity,
    required SpikeLog log,
    int port = 8443,
  }) async {
    final context = SecurityContext(withTrustedRoots: false)
      ..useCertificateChainBytes(utf8.encode(identity.certificatePem))
      ..usePrivateKeyBytes(utf8.encode(identity.privateKeyPem));

    final server = await HttpServer.bindSecure(
      InternetAddress.anyIPv4,
      port,
      context,
    );
    final spike = SpikeServer._(server, log);
    server.listen(
      spike._handle,
      onError: (Object error) => log('ERREUR_SERVEUR $error'),
    );
    return spike;
  }

  Future<void> _handle(HttpRequest request) async {
    final remote = request.connectionInfo?.remoteAddress.address ?? '?';
    if (request.uri.path != '/ws' ||
        !WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    connections++;
    _log('CONNEXION n°$connections depuis $remote');
    socket.listen(
      (data) {
        messages++;
        socket.add(
          jsonEncode({
            'echo': data,
            'serverMicros': DateTime.now().microsecondsSinceEpoch,
          }),
        );
      },
      onDone: () => _log('DECONNEXION $remote (messages total $messages)'),
      onError: (Object error) => _log('ERREUR_WS $remote $error'),
    );
  }

  Future<void> close() => _server.close(force: true);
}
