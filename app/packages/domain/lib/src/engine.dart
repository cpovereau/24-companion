import 'commands.dart';
import 'errors.dart';
import 'events.dart';
import 'ids.dart';
import 'scenario.dart';
import 'state.dart';
import 'value_equality.dart';

/// Résultat d'une décision du domaine.
sealed class Decision extends ValueObject {
  const Decision();
}

/// Décision acceptée : nouvel état officiel et événements produits, dans
/// l'ordre. Le service de session les persiste avant toute diffusion (T2).
final class Accepted extends Decision {
  Accepted(this.state, List<DomainEvent> events)
    : events = List.unmodifiable(events);

  final SessionState state;
  final List<DomainEvent> events;

  @override
  List<Object?> get props => [state, events];
}

/// Décision rejetée : aucune mutation, aucun événement.
final class Rejected extends Decision {
  const Rejected(this.error);

  final DomainError error;

  @override
  List<Object?> get props => [error];
}

/// Moteur artificiel et déterministe d'INTERVENTION_ALPHA.
///
/// Fonctions pures : mêmes entrées, mêmes sorties ; aucune horloge réelle,
/// aucun aléa, aucune entrée/sortie.
final class DomainEngine {
  const DomainEngine(this.scenario);

  final ScenarioDefinition scenario;

  SessionState startSession() => SessionState.start(scenario);

  /// Résout un QR de jeu en identité d'objet, sans révéler d'information ni
  /// de conséquence. Renvoie `null` pour un code inconnu.
  ObjectId? identifyQr(String qrCode) {
    for (final object in scenario.objects.values) {
      if (object.qrCode == qrCode) return object.id;
    }
    return null;
  }

  /// Applique une commande à l'état officiel.
  Decision decide(SessionState state, Command command) => switch (command) {
    final ExamineObject c => _examine(state, c),
    final AdvanceTime c => _advanceTime(state, c),
    final ResumeSession c => _resume(state, c),
  };

  /// Restaure un état persisté après interruption du maître : dernière heure
  /// persistée conservée, session en récupération, aucun avancement.
  Accepted recoverAfterInterruption(SessionState persisted) => Accepted(
    persisted.copyWith(status: SessionStatus.recoveryPaused),
    [SessionRecoveryPaused(fictionalTime: persisted.time)],
  );

  Decision _examine(SessionState state, ExamineObject command) {
    final actor = command.actor;
    if (actor is! PlayerActor) {
      return _reject(
        DomainErrorCode.notAuthorized,
        'Seul un joueur peut examiner un objet',
      );
    }
    if (state.status != SessionStatus.running) {
      return _reject(DomainErrorCode.sessionNotRunning, 'Session non active');
    }
    final character = state.characters[actor.characterId];
    if (character == null) {
      return _reject(DomainErrorCode.unknownCharacter, 'Personnage inconnu');
    }
    final object = scenario.objects[command.objectId];
    if (object == null) {
      return _reject(DomainErrorCode.unknownObject, 'Objet inconnu');
    }
    if (character.actionPoints < object.examineCost) {
      return _reject(
        DomainErrorCode.resourceExhausted,
        'Points d\'action insuffisants',
      );
    }

    final newInformation = object.revealedInformation.difference(
      character.knownInformation,
    );
    final newAssets = object.grantedAssets.difference(
      character.accessibleAssets,
    );
    final updated = character.copyWith(
      actionPoints: character.actionPoints - object.examineCost,
      knownInformation: {...character.knownInformation, ...newInformation},
      accessibleAssets: {...character.accessibleAssets, ...newAssets},
    );

    return Accepted(
      state.copyWith(
        characters: {...state.characters, actor.characterId: updated},
      ),
      [
        ObjectExamined(
          fictionalTime: state.time,
          commandId: command.commandId,
          characterId: actor.characterId,
          objectId: object.id,
          cost: object.examineCost,
          actionPointsAfter: updated.actionPoints,
          newlyRevealedInformation: newInformation,
          newlyGrantedAssets: newAssets,
        ),
      ],
    );
  }

  Decision _advanceTime(SessionState state, AdvanceTime command) {
    if (command.actor is! MasterActor) {
      return _reject(
        DomainErrorCode.notAuthorized,
        'Seul le maître fait avancer le temps',
      );
    }
    if (state.status != SessionStatus.running) {
      return _reject(DomainErrorCode.sessionNotRunning, 'Session non active');
    }
    if (!command.to.isAfter(state.time)) {
      return _reject(
        DomainErrorCode.timeNotAdvancing,
        'L\'heure demandée doit être postérieure à ${state.time}',
      );
    }

    // Les échéances atteintes ne sont jamais franchies silencieusement :
    // chacune est traitée à son heure, une seule fois, dans l'ordre.
    final events = <DomainEvent>[];
    var cursor = state.time;
    var tension = state.tension;
    final triggered = {...state.triggeredDeadlines};

    for (final deadline in scenario.deadlines) {
      if (triggered.contains(deadline.id) || deadline.at.isAfter(command.to)) {
        continue;
      }
      if (deadline.at.isAfter(cursor)) {
        events.add(TimeAdvanced(from: cursor, to: deadline.at));
        cursor = deadline.at;
      }
      events.add(
        DeadlineTriggered(fictionalTime: cursor, deadlineId: deadline.id),
      );
      if (deadline.tensionAfter != tension) {
        events.add(
          TensionChanged(
            fictionalTime: cursor,
            from: tension,
            to: deadline.tensionAfter,
          ),
        );
        tension = deadline.tensionAfter;
      }
      final audio = deadline.masterAudio;
      if (audio != null) {
        events.add(MasterAudioRequested(fictionalTime: cursor, assetId: audio));
      }
      triggered.add(deadline.id);
    }

    if (command.to.isAfter(cursor)) {
      events.add(TimeAdvanced(from: cursor, to: command.to));
    }

    return Accepted(
      state.copyWith(
        time: command.to,
        tension: tension,
        triggeredDeadlines: triggered,
      ),
      events,
    );
  }

  Decision _resume(SessionState state, ResumeSession command) {
    if (command.actor is! MasterActor) {
      return _reject(
        DomainErrorCode.notAuthorized,
        'Seul le maître reprend la session',
      );
    }
    if (state.status != SessionStatus.recoveryPaused) {
      return _reject(
        DomainErrorCode.sessionNotPaused,
        'Session non en récupération',
      );
    }
    return Accepted(state.copyWith(status: SessionStatus.running), [
      SessionResumed(fictionalTime: state.time, commandId: command.commandId),
    ]);
  }

  static Rejected _reject(DomainErrorCode code, String message) =>
      Rejected(DomainError(code, message));
}
