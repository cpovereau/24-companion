/// Identifiants typés du domaine.
///
/// Valeurs opaques issues des données de test : elles ne constituent pas un
/// format réseau ni un format de package définitif.
library;

extension type const ScenarioId(String value) {}

extension type const CharacterId(String value) {}

extension type const ObjectId(String value) {}

extension type const InformationId(String value) {}

extension type const AssetId(String value) {}

extension type const DeadlineId(String value) {}

/// Identité d'une commande, fournie par l'émetteur. La déduplication durable
/// relève du service de session (T2), pas du domaine.
extension type const CommandId(String value) {}
