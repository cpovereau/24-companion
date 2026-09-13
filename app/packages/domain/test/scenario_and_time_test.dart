import 'package:juste_a_temps_domain/juste_a_temps_domain.dart';
import 'package:test/test.dart';

import 'support/intervention_alpha.dart';

Map<String, Object?> _validJson() => {
  'scenarioId': 'S',
  'startTime': '10:00',
  'initialTension': 1,
  'characters': [
    {
      'id': 'A',
      'initialActionPoints': 1,
      'initialInformation': ['I_A'],
    },
  ],
  'masterSecrets': ['SECRET'],
  'objects': [
    {
      'id': 'O',
      'qrCode': 'Q',
      'examineCost': 1,
      'revealedInformation': ['I_O'],
      'grantedAssets': <String>[],
    },
  ],
  'deadlines': [
    {'id': 'D', 'at': '10:05', 'tensionAfter': 2},
  ],
};

void main() {
  group('FictionalTime', () {
    test('lecture, affichage et comparaison', () {
      expect(at('14:07').toString(), '14:07');
      expect(at('09:05'), FictionalTime(9, 5));
      expect(at('14:00').isBefore(at('14:10')), isTrue);
      expect(at('14:10').isAfter(at('14:00')), isTrue);
    });

    test('formats et valeurs invalides refusés', () {
      expect(() => FictionalTime.parse('14h00'), throwsFormatException);
      expect(() => FictionalTime.parse('24:00'), throwsArgumentError);
      expect(() => FictionalTime.parse('12:60'), throwsArgumentError);
    });
  });

  group('ScenarioDefinition.fromJson', () {
    test('la fixture INTERVENTION_ALPHA est chargée', () {
      final scenario = loadInterventionAlpha();

      expect(scenario.id, const ScenarioId('INTERVENTION_ALPHA'));
      expect(scenario.characters.keys, {p1, p2});
      expect(scenario.masterSecrets, {secretMjAlpha});
      expect(scenario.objects[objetAlpha]!.revealedInformation, {indiceAlpha});
      expect(scenario.deadlines.single.at, at('14:10'));
    });

    test('un scénario valide minimal est accepté', () {
      expect(
        ScenarioDefinition.fromJson(_validJson()).id,
        const ScenarioId('S'),
      );
    });

    test('identifiants de personnage en double refusés', () {
      final json = _validJson();
      final characters = json['characters']! as List<Object?>;
      json['characters'] = [...characters, characters.first];
      expect(() => ScenarioDefinition.fromJson(json), throwsFormatException);
    });

    test('champ manquant ou mal typé refusé', () {
      expect(
        () => ScenarioDefinition.fromJson(_validJson()..remove('startTime')),
        throwsFormatException,
      );
      expect(
        () =>
            ScenarioDefinition.fromJson(_validJson()..['initialTension'] = '1'),
        throwsFormatException,
      );
    });

    test('échéance antérieure au démarrage refusée', () {
      final json = _validJson()
        ..['deadlines'] = [
          {'id': 'D', 'at': '09:00', 'tensionAfter': 2},
        ];
      expect(() => ScenarioDefinition.fromJson(json), throwsFormatException);
    });

    test('coût d\'examen non positif refusé', () {
      final json = _validJson();
      final object = Map<String, Object?>.of(
        (json['objects']! as List<Object?>).single! as Map<String, Object?>,
      )..['examineCost'] = 0;
      json['objects'] = [object];
      expect(() => ScenarioDefinition.fromJson(json), throwsFormatException);
    });
  });
}
