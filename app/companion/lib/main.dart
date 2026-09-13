import 'package:flutter/material.dart';

/// Point d'entrée du POC LOT 0 « Juste à temps ».
///
/// Socle T0 : aucune logique de 24 n'est encore implémentée. Les rôles maître
/// et joueur arriveront avec les tranches suivantes
/// (doc/dev/architecture/LOT0_POC_CONCEPTION.md).
void main() {
  runApp(const JusteATempsApp());
}

class JusteATempsApp extends StatelessWidget {
  const JusteATempsApp({super.key});

  static const title = 'Juste à temps';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
      ),
      home: const SocleScreen(),
    );
  }
}

class SocleScreen extends StatelessWidget {
  const SocleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(JusteATempsApp.title)),
      body: const Center(child: Text('POC LOT 0 — socle technique')),
    );
  }
}
