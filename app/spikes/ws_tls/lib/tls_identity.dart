// SPIKE JETABLE — ne pas réutiliser tel quel (LOT0_POC_CONCEPTION.md §4, T4).
//
// Génère sur l'appareil une clé EC P-256 et un certificat X.509 auto-signé,
// puis calcule l'empreinte SHA-256 du certificat (valeur à épingler).
import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';

import 'pinning.dart';

class TlsIdentity {
  TlsIdentity({
    required this.certificatePem,
    required this.privateKeyPem,
    required this.fingerprint,
    required this.generationMicros,
  });

  final String certificatePem;
  final String privateKeyPem;
  final String fingerprint;
  final int generationMicros;

  Map<String, Object> toJson() => {
    'certificatePem': certificatePem,
    'privateKeyPem': privateKeyPem,
    'fingerprint': fingerprint,
    'generationMicros': generationMicros,
  };

  static TlsIdentity fromJson(Map<String, Object?> json) => TlsIdentity(
    certificatePem: json['certificatePem']! as String,
    privateKeyPem: json['privateKeyPem']! as String,
    fingerprint: json['fingerprint']! as String,
    generationMicros: json['generationMicros']! as int,
  );
}

/// Exécutée dans un isolate : la génération peut prendre du temps.
Map<String, Object> generateIdentityJson(String commonName) {
  final watch = Stopwatch()..start();
  final pair = CryptoUtils.generateEcKeyPair(curve: 'prime256v1');
  final privateKey = pair.privateKey as ECPrivateKey;
  final publicKey = pair.publicKey as ECPublicKey;

  final csr = X509Utils.generateEccCsrPem(
    {'CN': commonName},
    privateKey,
    publicKey,
  );
  final certificatePem = X509Utils.generateSelfSignedCertificate(
    privateKey,
    csr,
    1,
    serialNumber: DateTime.now().microsecondsSinceEpoch.toString(),
  );
  final privateKeyPem = CryptoUtils.encodeEcPrivateKeyToPem(privateKey);
  watch.stop();

  return TlsIdentity(
    certificatePem: certificatePem,
    privateKeyPem: privateKeyPem,
    fingerprint: sha256Fingerprint(derFromPem(certificatePem)),
    generationMicros: watch.elapsedMicroseconds,
  ).toJson();
}

Uint8List derFromPem(String pem) {
  final body = pem
      .split(RegExp(r'\r?\n'))
      .where((line) => line.isNotEmpty && !line.startsWith('-----'))
      .join();
  return base64.decode(body);
}
