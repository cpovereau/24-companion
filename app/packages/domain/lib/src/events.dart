import 'fictional_time.dart';
import 'ids.dart';
import 'value_equality.dart';

/// Destinataires autorisés d'un événement de domaine.
///
/// Annotation du domaine : la construction des données réellement envoyées
/// aux clients relève de la projection (T3).
sealed class EventVisibility extends ValueObject {
  const EventVisibility();

  /// Indique si le personnage [characterId] est destinataire.
  bool includesCharacter(CharacterId characterId);
}

/// Visible par tous les participants.
final class PublicVisibility extends EventVisibility {
  const PublicVisibility();

  @override
  bool includesCharacter(CharacterId characterId) => true;

  @override
  List<Object?> get props => const [];
}

/// Visible par les seuls personnages listés (et par le maître).
final class CharactersVisibility extends EventVisibility {
  CharactersVisibility(Set<CharacterId> characters)
    : characters = Set.unmodifiable(characters);

  final Set<CharacterId> characters;

  @override
  bool includesCharacter(CharacterId characterId) =>
      characters.contains(characterId);

  @override
  List<Object?> get props => [characters];
}

/// Réservé au maître.
final class MasterOnlyVisibility extends EventVisibility {
  const MasterOnlyVisibility();

  @override
  bool includesCharacter(CharacterId characterId) => false;

  @override
  List<Object?> get props => const [];
}

/// Événement de domaine produit par une décision acceptée.
///
/// Aucune séquence globale ici : elle est attribuée par le service de
/// session lors de la persistance (T2).
sealed class DomainEvent extends ValueObject {
  const DomainEvent({required this.fictionalTime});

  final FictionalTime fictionalTime;

  EventVisibility get visibility;
}

/// Un personnage a examiné un objet.
final class ObjectExamined extends DomainEvent {
  ObjectExamined({
    required super.fictionalTime,
    required this.commandId,
    required this.characterId,
    required this.objectId,
    required this.cost,
    required this.actionPointsAfter,
    required Set<InformationId> newlyRevealedInformation,
    required Set<AssetId> newlyGrantedAssets,
  }) : newlyRevealedInformation = Set.unmodifiable(newlyRevealedInformation),
       newlyGrantedAssets = Set.unmodifiable(newlyGrantedAssets);

  final CommandId commandId;
  final CharacterId characterId;
  final ObjectId objectId;
  final int cost;
  final int actionPointsAfter;

  /// Informations nouvellement connues du personnage (vide si déjà connues).
  final Set<InformationId> newlyRevealedInformation;

  /// Assets nouvellement accessibles au personnage.
  final Set<AssetId> newlyGrantedAssets;

  @override
  EventVisibility get visibility => CharactersVisibility({characterId});

  @override
  List<Object?> get props => [
    fictionalTime,
    commandId,
    characterId,
    objectId,
    cost,
    actionPointsAfter,
    newlyRevealedInformation,
    newlyGrantedAssets,
  ];
}

/// Le temps fictif a progressé de [from] à [to] sans franchir d'échéance
/// non traitée.
final class TimeAdvanced extends DomainEvent {
  const TimeAdvanced({required this.from, required this.to})
    : super(fictionalTime: to);

  final FictionalTime from;
  final FictionalTime to;

  @override
  EventVisibility get visibility => const PublicVisibility();

  @override
  List<Object?> get props => [from, to];
}

/// Une échéance du scénario a été atteinte (événement public).
final class DeadlineTriggered extends DomainEvent {
  const DeadlineTriggered({
    required super.fictionalTime,
    required this.deadlineId,
  });

  final DeadlineId deadlineId;

  @override
  EventVisibility get visibility => const PublicVisibility();

  @override
  List<Object?> get props => [fictionalTime, deadlineId];
}

/// La tension publique a changé.
final class TensionChanged extends DomainEvent {
  const TensionChanged({
    required super.fictionalTime,
    required this.from,
    required this.to,
  });

  final int from;
  final int to;

  @override
  EventVisibility get visibility => const PublicVisibility();

  @override
  List<Object?> get props => [fictionalTime, from, to];
}

/// Demande de lecture d'un asset audio côté maître.
final class MasterAudioRequested extends DomainEvent {
  const MasterAudioRequested({
    required super.fictionalTime,
    required this.assetId,
  });

  final AssetId assetId;

  @override
  EventVisibility get visibility => const MasterOnlyVisibility();

  @override
  List<Object?> get props => [fictionalTime, assetId];
}

/// La session est entrée en récupération après interruption du maître.
final class SessionRecoveryPaused extends DomainEvent {
  const SessionRecoveryPaused({required super.fictionalTime});

  @override
  EventVisibility get visibility => const PublicVisibility();

  @override
  List<Object?> get props => [fictionalTime];
}

/// Le MJ a explicitement repris la session.
final class SessionResumed extends DomainEvent {
  const SessionResumed({required super.fictionalTime, required this.commandId});

  final CommandId commandId;

  @override
  EventVisibility get visibility => const PublicVisibility();

  @override
  List<Object?> get props => [fictionalTime, commandId];
}
