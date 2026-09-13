import 'fictional_time.dart';
import 'ids.dart';
import 'value_equality.dart';

/// Émetteur d'une commande, tel qu'établi par le service de session après
/// authentification (T2). Le domaine ne fait que vérifier le rôle.
sealed class Actor extends ValueObject {
  const Actor();
}

/// Joueur associé à un personnage : il n'agit que pour ce personnage.
final class PlayerActor extends Actor {
  const PlayerActor(this.characterId);

  final CharacterId characterId;

  @override
  List<Object?> get props => [characterId];
}

/// Maître du jeu / Conteur.
final class MasterActor extends Actor {
  const MasterActor();

  @override
  List<Object?> get props => const [];
}

sealed class Command extends ValueObject {
  const Command({required this.commandId, required this.actor});

  final CommandId commandId;
  final Actor actor;
}

/// Intention d'un joueur : examiner un objet identifié par QR.
final class ExamineObject extends Command {
  const ExamineObject({
    required super.commandId,
    required super.actor,
    required this.objectId,
  });

  final ObjectId objectId;

  @override
  List<Object?> get props => [commandId, actor, objectId];
}

/// Avancement explicite du temps fictif par le MJ jusqu'à [to].
final class AdvanceTime extends Command {
  const AdvanceTime({
    required super.commandId,
    required super.actor,
    required this.to,
  });

  final FictionalTime to;

  @override
  List<Object?> get props => [commandId, actor, to];
}

/// Reprise explicite par le MJ d'une session en récupération.
final class ResumeSession extends Command {
  const ResumeSession({required super.commandId, required super.actor});

  @override
  List<Object?> get props => [commandId, actor];
}
