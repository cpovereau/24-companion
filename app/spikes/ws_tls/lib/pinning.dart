// SPIKE JETABLE — empreinte SHA-256 d'un certificat (DER), en hexadécimal.
//
// Sans dart:io ni Flutter : utilisable par l'application et par le client PC.
import 'dart:typed_data';

import 'package:pointycastle/digests/sha256.dart';

String sha256Fingerprint(List<int> der) {
  final digest = SHA256Digest().process(Uint8List.fromList(der));
  return digest.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
