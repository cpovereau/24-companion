import 'value_equality.dart';

/// Codes d'erreur métier stables, utilisés par les tests et le diagnostic.
///
/// Noms provisoires du POC, sans valeur de contrat réseau définitif.
enum DomainErrorCode {
  /// Réserve de points d'action insuffisante.
  resourceExhausted('RESOURCE_EXHAUSTED'),

  /// Personnage inconnu du scénario.
  unknownCharacter('UNKNOWN_CHARACTER'),

  /// Objet inconnu du scénario.
  unknownObject('UNKNOWN_OBJECT'),

  /// Rôle non autorisé pour cette commande.
  notAuthorized('NOT_AUTHORIZED'),

  /// La session n'est pas en cours (par exemple en récupération).
  sessionNotRunning('SESSION_NOT_RUNNING'),

  /// Reprise demandée alors que la session n'est pas en récupération.
  sessionNotPaused('SESSION_NOT_PAUSED'),

  /// L'heure demandée n'est pas postérieure à l'heure courante.
  timeNotAdvancing('TIME_NOT_ADVANCING');

  const DomainErrorCode(this.code);

  final String code;
}

final class DomainError extends ValueObject {
  const DomainError(this.code, this.message);

  final DomainErrorCode code;

  /// Message de diagnostic ; ne contient aucune donnée secrète du scénario.
  final String message;

  @override
  List<Object?> get props => [code, message];
}
