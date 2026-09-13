import 'dart:convert';
import 'dart:io';

import 'package:juste_a_temps_domain/juste_a_temps_domain.dart';
import 'package:test/test.dart';

// Les tests peuvent lire des fichiers ; le code du domaine (lib/) jamais.

const p1 = CharacterId('P1');
const p2 = CharacterId('P2');
const player1 = PlayerActor(p1);
const player2 = PlayerActor(p2);
const master = MasterActor();

const objetAlpha = ObjectId('OBJET_ALPHA');
const qrObjetAlpha = 'TEST-QR-0001';
const infoP1Initial = InformationId('INFO_P1_INITIAL');
const infoP2Initial = InformationId('INFO_P2_INITIAL');
const indiceAlpha = InformationId('INDICE_ALPHA');
const secretMjAlpha = InformationId('SECRET_MJ_ALPHA');
const objetAlphaImage = AssetId('OBJET_ALPHA_IMAGE');
const alerteAlpha = DeadlineId('ALERTE_ALPHA');
const alerteAlphaAudio = AssetId('ALERTE_ALPHA_AUDIO');

FictionalTime at(String hhmm) => FictionalTime.parse(hhmm);

/// Charge la fixture partagée `app/fixtures/intervention_alpha/scenario.json`.
ScenarioDefinition loadInterventionAlpha() {
  final file = File('../../fixtures/intervention_alpha/scenario.json');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
  return ScenarioDefinition.fromJson(json);
}

ExamineObject examine(String commandId, {Actor actor = player1}) =>
    ExamineObject(
      commandId: CommandId(commandId),
      actor: actor,
      objectId: objetAlpha,
    );

AdvanceTime advanceTo(String commandId, String hhmm, {Actor actor = master}) =>
    AdvanceTime(commandId: CommandId(commandId), actor: actor, to: at(hhmm));

Accepted expectAccepted(Decision decision) {
  expect(decision, isA<Accepted>());
  return decision as Accepted;
}

DomainErrorCode expectRejected(Decision decision) {
  expect(decision, isA<Rejected>());
  return (decision as Rejected).error.code;
}

/// Toutes les informations mentionnées par un événement, quelle que soit sa
/// visibilité.
Set<InformationId> informationIn(DomainEvent event) => switch (event) {
  final ObjectExamined e => e.newlyRevealedInformation,
  _ => const {},
};
