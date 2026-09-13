import 'fictional_time.dart';
import 'ids.dart';
import 'value_equality.dart';

/// Définition d'un personnage fournie par le scénario de test.
final class CharacterDefinition extends ValueObject {
  CharacterDefinition({
    required this.id,
    required this.initialActionPoints,
    required Set<InformationId> initialInformation,
  }) : initialInformation = Set.unmodifiable(initialInformation) {
    if (initialActionPoints < 0) {
      throw ArgumentError.value(initialActionPoints, 'initialActionPoints');
    }
  }

  final CharacterId id;
  final int initialActionPoints;

  /// Informations privées connues de ce seul personnage au démarrage.
  final Set<InformationId> initialInformation;

  @override
  List<Object?> get props => [id, initialActionPoints, initialInformation];
}

/// Objet physique identifié par un QR de jeu.
final class ObjectDefinition extends ValueObject {
  ObjectDefinition({
    required this.id,
    required this.qrCode,
    required this.examineCost,
    required Set<InformationId> revealedInformation,
    required Set<AssetId> grantedAssets,
  }) : revealedInformation = Set.unmodifiable(revealedInformation),
       grantedAssets = Set.unmodifiable(grantedAssets) {
    if (examineCost <= 0) {
      throw ArgumentError.value(examineCost, 'examineCost');
    }
  }

  final ObjectId id;

  /// Contenu opaque du QR de jeu : il identifie l'objet et ne contient
  /// aucune réponse ni conséquence secrète.
  final String qrCode;

  final int examineCost;

  /// Informations révélées au seul personnage qui examine l'objet.
  final Set<InformationId> revealedInformation;

  /// Assets rendus accessibles au seul personnage qui examine l'objet.
  final Set<AssetId> grantedAssets;

  @override
  List<Object?> get props => [
    id,
    qrCode,
    examineCost,
    revealedInformation,
    grantedAssets,
  ];
}

/// Échéance temporelle déclenchant un événement public.
final class DeadlineDefinition extends ValueObject {
  const DeadlineDefinition({
    required this.id,
    required this.at,
    required this.tensionAfter,
    this.masterAudio,
  });

  final DeadlineId id;
  final FictionalTime at;
  final int tensionAfter;

  /// Asset audio joué côté maître au déclenchement.
  final AssetId? masterAudio;

  @override
  List<Object?> get props => [id, at, tensionAfter, masterAudio];
}

/// Scénario synthétique complet, détenu par le seul maître (ADR-0001).
final class ScenarioDefinition extends ValueObject {
  ScenarioDefinition({
    required this.id,
    required this.startTime,
    required this.initialTension,
    required List<CharacterDefinition> characters,
    required Set<InformationId> masterSecrets,
    required List<ObjectDefinition> objects,
    required List<DeadlineDefinition> deadlines,
  }) : characters = _indexUnique(characters, (c) => c.id, 'personnage'),
       masterSecrets = Set.unmodifiable(masterSecrets),
       objects = _indexUnique(objects, (o) => o.id, 'objet'),
       deadlines = List<DeadlineDefinition>.unmodifiable(
         <DeadlineDefinition>[...deadlines]
           ..sort((a, b) => a.at.compareTo(b.at)),
       ) {
    _checkUnique(objects.map((o) => o.qrCode), 'code QR');
    _checkUnique(deadlines.map((d) => d.id), 'échéance');
    for (final deadline in deadlines) {
      if (deadline.at.isBefore(startTime)) {
        throw ArgumentError('Échéance ${deadline.id} antérieure au démarrage');
      }
    }
  }

  /// Lit la représentation JSON expérimentale des fixtures du POC.
  ///
  /// Ce format n'est pas le package `.24scenario` définitif.
  factory ScenarioDefinition.fromJson(Map<String, Object?> json) {
    try {
      return ScenarioDefinition(
        id: ScenarioId(_string(json, 'scenarioId')),
        startTime: FictionalTime.parse(_string(json, 'startTime')),
        initialTension: _int(json, 'initialTension'),
        characters: [
          for (final c in _objects(json, 'characters'))
            CharacterDefinition(
              id: CharacterId(_string(c, 'id')),
              initialActionPoints: _int(c, 'initialActionPoints'),
              initialInformation: {
                for (final i in _strings(c, 'initialInformation'))
                  InformationId(i),
              },
            ),
        ],
        masterSecrets: {
          for (final s in _strings(json, 'masterSecrets')) InformationId(s),
        },
        objects: [
          for (final o in _objects(json, 'objects'))
            ObjectDefinition(
              id: ObjectId(_string(o, 'id')),
              qrCode: _string(o, 'qrCode'),
              examineCost: _int(o, 'examineCost'),
              revealedInformation: {
                for (final i in _strings(o, 'revealedInformation'))
                  InformationId(i),
              },
              grantedAssets: {
                for (final a in _strings(o, 'grantedAssets')) AssetId(a),
              },
            ),
        ],
        deadlines: [
          for (final d in _objects(json, 'deadlines'))
            DeadlineDefinition(
              id: DeadlineId(_string(d, 'id')),
              at: FictionalTime.parse(_string(d, 'at')),
              tensionAfter: _int(d, 'tensionAfter'),
              masterAudio: switch (d['masterAudio']) {
                null => null,
                final String audio => AssetId(audio),
                final other => throw FormatException(
                  'masterAudio doit être une chaîne',
                  other,
                ),
              },
            ),
        ],
      );
    } on ArgumentError catch (error) {
      throw FormatException('Scénario invalide : ${error.message}');
    }
  }

  final ScenarioId id;
  final FictionalTime startTime;
  final int initialTension;
  final Map<CharacterId, CharacterDefinition> characters;
  final Set<InformationId> masterSecrets;
  final Map<ObjectId, ObjectDefinition> objects;

  /// Échéances triées par heure.
  final List<DeadlineDefinition> deadlines;

  @override
  List<Object?> get props => [
    id,
    startTime,
    initialTension,
    characters,
    masterSecrets,
    objects,
    deadlines,
  ];
}

Map<K, V> _indexUnique<K, V>(List<V> values, K Function(V) key, String label) {
  final index = <K, V>{};
  for (final value in values) {
    if (index.containsKey(key(value))) {
      throw ArgumentError('Identifiant de $label en double : ${key(value)}');
    }
    index[key(value)] = value;
  }
  return Map.unmodifiable(index);
}

void _checkUnique(Iterable<Object?> values, String label) {
  final seen = <Object?>{};
  for (final value in values) {
    if (!seen.add(value)) {
      throw ArgumentError('Valeur de $label en double : $value');
    }
  }
}

String _string(Map<String, Object?> json, String key) => switch (json[key]) {
  final String value when value.isNotEmpty => value,
  final other => throw FormatException('« $key » : chaîne attendue', other),
};

int _int(Map<String, Object?> json, String key) => switch (json[key]) {
  final int value => value,
  final other => throw FormatException('« $key » : entier attendu', other),
};

List<String> _strings(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      final List<Object?> list => [
        for (final item in list)
          item is String && item.isNotEmpty
              ? item
              : throw FormatException('« $key » : chaînes attendues', item),
      ],
      final other => throw FormatException('« $key » : liste attendue', other),
    };

List<Map<String, Object?>> _objects(Map<String, Object?> json, String key) =>
    switch (json[key]) {
      final List<Object?> list => [
        for (final item in list)
          item is Map<String, Object?>
              ? item
              : throw FormatException('« $key » : objets attendus', item),
      ],
      final other => throw FormatException('« $key » : liste attendue', other),
    };
