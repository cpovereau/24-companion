// Oracles d'INTERVENTION_ALPHA — doc/dev/architecture/LOT0_PREPARATION.md §3.
//
// Chaque test porte le nom de l'étape ou de l'oracle qu'il vérifie. Le
// transport, l'authentification, la persistance et la projection relèvent
// des tranches T2 à T4.
import 'package:juste_a_temps_domain/juste_a_temps_domain.dart';
import 'package:test/test.dart';

import 'support/intervention_alpha.dart';

void main() {
  late DomainEngine engine;
  late SessionState start;

  setUp(() {
    engine = DomainEngine(loadInterventionAlpha());
    start = engine.startSession();
  });

  group('État initial à 14:00', () {
    test('session démarrée, heure 14:00, tension 2', () {
      expect(start.status, SessionStatus.running);
      expect(start.time, at('14:00'));
      expect(start.tension, 2);
      expect(start.triggeredDeadlines, isEmpty);
    });

    test('P1 et P2 ont 2 points et ne connaissent que leur information', () {
      expect(start.characters[p1]!.actionPoints, 2);
      expect(start.characters[p1]!.knownInformation, {infoP1Initial});
      expect(start.characters[p2]!.actionPoints, 2);
      expect(start.characters[p2]!.knownInformation, {infoP2Initial});
    });

    test('aucun personnage ne connaît INDICE_ALPHA ni SECRET_MJ_ALPHA', () {
      for (final character in start.characters.values) {
        expect(character.knownInformation, isNot(contains(indiceAlpha)));
        expect(character.knownInformation, isNot(contains(secretMjAlpha)));
        expect(character.accessibleAssets, isEmpty);
      }
    });
  });

  group('Parcours principal', () {
    test('étape 1 — le QR identifie seulement OBJET_ALPHA', () {
      expect(engine.identifyQr(qrObjetAlpha), objetAlpha);
      expect(engine.identifyQr('CODE-INCONNU'), isNull);
    });

    test('étapes 2 à 4 — EXAMINER(C1) : P1 passe de 2 à 1 et reçoit '
        'INDICE_ALPHA', () {
      final result = expectAccepted(engine.decide(start, examine('C1')));

      final p1State = result.state.characters[p1]!;
      expect(p1State.actionPoints, 1);
      expect(p1State.knownInformation, {infoP1Initial, indiceAlpha});
      expect(p1State.accessibleAssets, {objetAlphaImage});

      expect(result.events, [
        ObjectExamined(
          fictionalTime: at('14:00'),
          commandId: const CommandId('C1'),
          characterId: p1,
          objectId: objetAlpha,
          cost: 1,
          actionPointsAfter: 1,
          newlyRevealedInformation: {indiceAlpha},
          newlyGrantedAssets: {objetAlphaImage},
        ),
      ]);
      expect(result.events.single.visibility, CharactersVisibility({p1}));
    });

    test('étape 5 — P2 ne reçoit ni INDICE_ALPHA ni SECRET_MJ_ALPHA', () {
      final result = expectAccepted(engine.decide(start, examine('C1')));

      expect(result.state.characters[p2], start.characters[p2]);
      for (final event in result.events) {
        if (event.visibility.includesCharacter(p2)) {
          expect(informationIn(event), isNot(contains(indiceAlpha)));
        }
        expect(informationIn(event), isNot(contains(secretMjAlpha)));
      }
    });

    test(
      'étape 6 — retransmission exacte de C1 sans nouvelle mutation',
      () {},
      skip:
          'Déduplication durable : service de session, tranche T2 '
          '(LOT0_POC_CONCEPTION.md §4).',
    );

    test('étape 7 — deuxième action valide (C2) : P1 passe de 1 à 0', () {
      final afterC1 = expectAccepted(engine.decide(start, examine('C1')));
      final afterC2 = expectAccepted(
        engine.decide(afterC1.state, examine('C2')),
      );

      final p1State = afterC2.state.characters[p1]!;
      expect(p1State.actionPoints, 0);
      expect(p1State.knownInformation, {infoP1Initial, indiceAlpha});

      final event = afterC2.events.single as ObjectExamined;
      expect(event.commandId, const CommandId('C2'));
      expect(event.actionPointsAfter, 0);
      expect(event.newlyRevealedInformation, isEmpty);
      expect(event.newlyGrantedAssets, isEmpty);
    });

    test('étape 8 — troisième action (C3) rejetée RESOURCE_EXHAUSTED, sans '
        'mutation', () {
      final afterC1 = expectAccepted(engine.decide(start, examine('C1')));
      final afterC2 = expectAccepted(
        engine.decide(afterC1.state, examine('C2')),
      );
      final exhausted = afterC2.state;
      final snapshot = exhausted.copyWith();

      final code = expectRejected(engine.decide(exhausted, examine('C3')));

      expect(code, DomainErrorCode.resourceExhausted);
      expect(code.code, 'RESOURCE_EXHAUSTED');
      expect(exhausted, snapshot);
    });

    test('la résolution est déterministe', () {
      expect(
        engine.decide(start, examine('C1')),
        engine.decide(start, examine('C1')),
      );
    });
  });

  group('Échéance ALERTE_ALPHA', () {
    test(
      '14:00 → 14:10 : déclenchée une fois, tension 2 → 4, audio maître',
      () {
        final result = expectAccepted(
          engine.decide(start, advanceTo('T1', '14:10')),
        );

        expect(result.events, [
          TimeAdvanced(from: at('14:00'), to: at('14:10')),
          DeadlineTriggered(
            fictionalTime: at('14:10'),
            deadlineId: alerteAlpha,
          ),
          TensionChanged(fictionalTime: at('14:10'), from: 2, to: 4),
          MasterAudioRequested(
            fictionalTime: at('14:10'),
            assetId: alerteAlphaAudio,
          ),
        ]);
        expect(result.state.time, at('14:10'));
        expect(result.state.tension, 4);
        expect(result.state.triggeredDeadlines, {alerteAlpha});

        expect(result.events[1].visibility, const PublicVisibility());
        expect(result.events[2].visibility, const PublicVisibility());
        expect(result.events[3].visibility, const MasterOnlyVisibility());
      },
    );

    test('une progression ultérieure ne la déclenche pas une seconde fois', () {
      final at1410 = expectAccepted(
        engine.decide(start, advanceTo('T1', '14:10')),
      );
      final at1420 = expectAccepted(
        engine.decide(at1410.state, advanceTo('T2', '14:20')),
      );

      expect(at1420.events, [TimeAdvanced(from: at('14:10'), to: at('14:20'))]);
      expect(at1420.state.tension, 4);
    });

    test('un avancement au-delà de 14:10 ne franchit pas l\'échéance '
        'silencieusement', () {
      final result = expectAccepted(
        engine.decide(start, advanceTo('T1', '14:30')),
      );

      expect(result.events.whereType<DeadlineTriggered>(), hasLength(1));
      expect(
        result.events.first,
        TimeAdvanced(from: at('14:00'), to: at('14:10')),
      );
      expect(
        result.events.last,
        TimeAdvanced(from: at('14:10'), to: at('14:30')),
      );
      expect(result.state.time, at('14:30'));
      expect(result.state.tension, 4);
    });

    test('avant 14:10, aucun événement ne révèle l\'alerte future', () {
      final result = expectAccepted(
        engine.decide(start, advanceTo('T1', '14:09')),
      );

      expect(result.events, [TimeAdvanced(from: at('14:00'), to: at('14:09'))]);
      expect(result.state.tension, 2);
      expect(result.state.triggeredDeadlines, isEmpty);
    });
  });

  group('Incident B — logique de récupération (sans persistance réelle)', () {
    late SessionState persistedAt1407;

    setUp(() {
      persistedAt1407 = expectAccepted(
        engine.decide(start, advanceTo('T1', '14:07')),
      ).state;
    });

    test('au redémarrage : 14:07 conservée, RECOVERY_PAUSED', () {
      final recovered = engine.recoverAfterInterruption(persistedAt1407);

      expect(recovered.state.status, SessionStatus.recoveryPaused);
      expect(recovered.state.time, at('14:07'));
      expect(recovered.state.tension, 2);
      expect(recovered.events, [
        SessionRecoveryPaused(fictionalTime: at('14:07')),
      ]);
    });

    test('aucun avancement ni commande avant la reprise explicite', () {
      final paused = engine.recoverAfterInterruption(persistedAt1407).state;

      expect(
        expectRejected(engine.decide(paused, advanceTo('T2', '14:10'))),
        DomainErrorCode.sessionNotRunning,
      );
      expect(
        expectRejected(engine.decide(paused, examine('C1'))),
        DomainErrorCode.sessionNotRunning,
      );
    });

    test('seul le maître reprend la session', () {
      final paused = engine.recoverAfterInterruption(persistedAt1407).state;
      final resumeByPlayer = ResumeSession(
        commandId: const CommandId('R1'),
        actor: player1,
      );

      expect(
        expectRejected(engine.decide(paused, resumeByPlayer)),
        DomainErrorCode.notAuthorized,
      );
    });

    test('après reprise MJ puis progression à 14:10, ALERTE_ALPHA exécutée '
        'une seule fois', () {
      final paused = engine.recoverAfterInterruption(persistedAt1407).state;
      final resumed = expectAccepted(
        engine.decide(
          paused,
          const ResumeSession(commandId: CommandId('R1'), actor: master),
        ),
      );
      expect(resumed.state.status, SessionStatus.running);
      expect(resumed.state.time, at('14:07'));

      final at1410 = expectAccepted(
        engine.decide(resumed.state, advanceTo('T2', '14:10')),
      );
      expect(at1410.events.whereType<DeadlineTriggered>(), hasLength(1));
      expect(at1410.state.tension, 4);

      final at1415 = expectAccepted(
        engine.decide(at1410.state, advanceTo('T3', '14:15')),
      );
      expect(at1415.events.whereType<DeadlineTriggered>(), isEmpty);
    });

    test('reprise refusée si la session n\'est pas en récupération', () {
      expect(
        expectRejected(
          engine.decide(
            start,
            const ResumeSession(commandId: CommandId('R1'), actor: master),
          ),
        ),
        DomainErrorCode.sessionNotPaused,
      );
    });
  });

  group('Autorisations et erreurs', () {
    test('un joueur ne fait pas avancer le temps', () {
      expect(
        expectRejected(
          engine.decide(start, advanceTo('T1', '14:10', actor: player1)),
        ),
        DomainErrorCode.notAuthorized,
      );
    });

    test('le maître n\'examine pas d\'objet', () {
      expect(
        expectRejected(engine.decide(start, examine('C1', actor: master))),
        DomainErrorCode.notAuthorized,
      );
    });

    test('personnage inconnu', () {
      expect(
        expectRejected(
          engine.decide(
            start,
            examine('C1', actor: const PlayerActor(CharacterId('P9'))),
          ),
        ),
        DomainErrorCode.unknownCharacter,
      );
    });

    test('objet inconnu', () {
      final command = ExamineObject(
        commandId: const CommandId('C1'),
        actor: player1,
        objectId: const ObjectId('OBJET_INCONNU'),
      );
      expect(
        expectRejected(engine.decide(start, command)),
        DomainErrorCode.unknownObject,
      );
    });

    test('le temps ne recule ni ne stagne', () {
      expect(
        expectRejected(engine.decide(start, advanceTo('T1', '14:00'))),
        DomainErrorCode.timeNotAdvancing,
      );
      expect(
        expectRejected(engine.decide(start, advanceTo('T1', '13:59'))),
        DomainErrorCode.timeNotAdvancing,
      );
    });

    test('l\'action d\'un joueur ne modifie que son personnage', () {
      final result = expectAccepted(
        engine.decide(start, examine('C1', actor: player2)),
      );
      expect(result.state.characters[p1], start.characters[p1]);
      expect(result.state.characters[p2]!.knownInformation, {
        infoP2Initial,
        indiceAlpha,
      });
    });
  });
}
