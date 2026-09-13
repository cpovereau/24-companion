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

Précisions prises pendant l'implémentation (`LOT0_POC_CONCEPTION.md` §4, T1).
Les points 1 et 2 ont été validés par l'utilisateur le 13 septembre 2026.

1. **Validé pour le POC** : un nouvel examen du même objet est une action
   valide ; il consomme son coût sans nouvelle information (étape 7). Règle
   artificielle, qui ne reflète pas la mécanique réelle de 24.
2. **Validé** : en `recoveryPaused`, toute commande de joueur et tout
   avancement du temps sont refusés (`SESSION_NOT_RUNNING`) jusqu'à la
   reprise explicite du MJ. C'est le temps du récit : les joueurs n'ont pas à
   intervenir.
3. L'événement de pause et celui de reprise sont **publics** ; la demande
   audio est réservée au maître. Dans le domaine, « public »
   (`PublicVisibility`) signifie que l'information est autorisée pour tous
   les participants de la session : le maître et chaque joueur associé à un
   personnage. La projection (T3) pourra donc l'envoyer à chaque téléphone
   joueur, par exemple « Partie suspendue par le Conteur à 14:07 ».
   « Public » ne signifie jamais hors de la session ni diffusé sur le réseau
   sans authentification. À l'inverse, `CharactersVisibility` limite
   l'information aux personnages listés, et `MasterOnlyVisibility` au maître.
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
