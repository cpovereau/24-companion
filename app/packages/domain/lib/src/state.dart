import 'fictional_time.dart';
import 'ids.dart';
import 'scenario.dart';
import 'value_equality.dart';

/// État de la session.
enum SessionStatus {
  /// Session démarrée : commandes et avancement du temps acceptés.
  running,

  /// Récupération après interruption du maître (`RECOVERY_PAUSED`, nom
  /// provisoire) : aucune mutation avant la reprise explicite du MJ.
  recoveryPaused,
}

/// État officiel d'un personnage dans la session.
final class CharacterState extends ValueObject {
  CharacterState({
    required this.actionPoints,
    required Set<InformationId> knownInformation,
    required Set<AssetId> accessibleAssets,
  }) : knownInformation = Set.unmodifiable(knownInformation),
       accessibleAssets = Set.unmodifiable(accessibleAssets);

  final int actionPoints;
  final Set<InformationId> knownInformation;
  final Set<AssetId> accessibleAssets;

  CharacterState copyWith({
    int? actionPoints,
    Set<InformationId>? knownInformation,
    Set<AssetId>? accessibleAssets,
  }) => CharacterState(
    actionPoints: actionPoints ?? this.actionPoints,
    knownInformation: knownInformation ?? this.knownInformation,
    accessibleAssets: accessibleAssets ?? this.accessibleAssets,
  );

  @override
  List<Object?> get props => [actionPoints, knownInformation, accessibleAssets];
}

/// État officiel complet de la session, détenu par le maître (ADR-0001).
///
/// Valeur immuable : toute évolution produit un nouvel état.
final class SessionState extends ValueObject {
  SessionState({
    required this.scenarioId,
    required this.status,
    required this.time,
    required this.tension,
    required Map<CharacterId, CharacterState> characters,
    required Set<DeadlineId> triggeredDeadlines,
  }) : characters = Map.unmodifiable(characters),
       triggeredDeadlines = Set.unmodifiable(triggeredDeadlines);

  /// Session démarrée à l'heure initiale du scénario.
  factory SessionState.start(ScenarioDefinition scenario) => SessionState(
    scenarioId: scenario.id,
    status: SessionStatus.running,
    time: scenario.startTime,
    tension: scenario.initialTension,
    characters: {
      for (final definition in scenario.characters.values)
        definition.id: CharacterState(
          actionPoints: definition.initialActionPoints,
          knownInformation: definition.initialInformation,
          accessibleAssets: const {},
        ),
    },
    triggeredDeadlines: const {},
  );

  final ScenarioId scenarioId;
  final SessionStatus status;
  final FictionalTime time;
  final int tension;
  final Map<CharacterId, CharacterState> characters;
  final Set<DeadlineId> triggeredDeadlines;

  SessionState copyWith({
    SessionStatus? status,
    FictionalTime? time,
    int? tension,
    Map<CharacterId, CharacterState>? characters,
    Set<DeadlineId>? triggeredDeadlines,
  }) => SessionState(
    scenarioId: scenarioId,
    status: status ?? this.status,
    time: time ?? this.time,
    tension: tension ?? this.tension,
    characters: characters ?? this.characters,
    triggeredDeadlines: triggeredDeadlines ?? this.triggeredDeadlines,
  );

  @override
  List<Object?> get props => [
    scenarioId,
    status,
    time,
    tension,
    characters,
    triggeredDeadlines,
  ];
}
