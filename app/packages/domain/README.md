# juste_a_temps_domain

Domaine **artificiel et déterministe** du POC LOT 0 : INTERVENTION_ALPHA.
Dart pur, sans Flutter, `dart:io`, réseau ni stockage (contrôlé en CI).
Il ne valide pas le moteur de résolution réel de 24.

## Contenu

| Élément | Rôle |
|---|---|
| `ScenarioDefinition` | Scénario synthétique complet, détenu par le maître ; lecture du JSON expérimental des fixtures |
| `SessionState` | État officiel immuable : statut, heure fictive, tension, personnages, échéances déclenchées |
| `Command` | `ExamineObject` (joueur), `AdvanceTime` et `ResumeSession` (maître) |
| `DomainEngine.decide` | Fonction pure : `Accepted(état, événements)` ou `Rejected(erreur)` sans mutation |
| `DomainEngine.identifyQr` | QR de jeu → identité d'objet uniquement |
| `DomainEngine.recoverAfterInterruption` | État persisté → `recoveryPaused` à la dernière heure persistée |
| `DomainEvent` | Événements annotés de leur visibilité (public, personnages, maître seul) |
| `DomainErrorCode` | Codes stables : `RESOURCE_EXHAUSTED`, `NOT_AUTHORIZED`, `SESSION_NOT_RUNNING`… |

Ce que le domaine ne fait pas : séquence globale, déduplication durable et
authentification (T2), construction des vues client (T3), transport (T4).

## Conventions précisées en T1

Précisions de conception prises pendant l'implémentation, à valider
(`LOT0_POC_CONCEPTION.md` §4, T1) :

1. Un nouvel examen du même objet est une action valide : il consomme son
   coût sans nouvelle information (étape 7 du parcours).
2. En `recoveryPaused`, toute commande de joueur et tout avancement du temps
   sont refusés (`SESSION_NOT_RUNNING`) jusqu'à la reprise explicite du MJ.
3. L'événement de pause et celui de reprise sont publics ; la demande audio
   est réservée au maître.
4. Un avancement qui dépasse une échéance la déclenche à son heure exacte,
   puis poursuit jusqu'à l'heure demandée.
5. Le QR de test est un code opaque (`TEST-QR-0001`), sans syntaxe définitive.
6. Les groupes destinataires ne sont pas encore modélisés ; ils le seront
   avant le test qui en dépend.
7. Une session tient sur une journée fictive (pas de passage de minuit).

## Commandes

``` shell
dart analyze --fatal-infos
dart test
```

Les tests lisent la fixture `app/fixtures/intervention_alpha/scenario.json`.
