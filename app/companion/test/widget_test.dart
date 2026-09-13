import 'package:flutter_test/flutter_test.dart';
import 'package:juste_a_temps/main.dart';

void main() {
  testWidgets('le socle affiche le nom de l\'application', (tester) async {
    await tester.pumpWidget(const JusteATempsApp());

    expect(find.text('Juste à temps'), findsOneWidget);
    expect(find.text('POC LOT 0 — socle technique'), findsOneWidget);
  });
}
