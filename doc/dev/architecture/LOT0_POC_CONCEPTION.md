# LOT 0 — Conception technique initiale du POC

> Statut : **proposition soumise à validation humaine**. Ce document prépare
> l'implémentation du POC dans `app/`. Il ne choisit ni la stack produit, ni le
> nombre de binaires, ni le protocole ou la sécurité de production.
> Références : [ARCHITECTURE.md](ARCHITECTURE.md),
> [LOT0_PREPARATION.md](LOT0_PREPARATION.md),
> [LOT0_POC.md](../specifications/LOT0_POC.md),
> [DEV_ENVIRONMENT.md](../operations/DEV_ENVIRONMENT.md) et les [ADR](../decisions/).

## 1. Cadre et autorisations

**Arbitrages humains du 13 septembre 2026** :

- implémentation du POC autorisée dans le dépôt public ;
- code placé dans `app/` ;
- CI à mettre en place au plus tôt ;
- recherche de solutions d'émulation iOS en cours côté humain (voir §8).

**Invariants applicables** : ADR-0001 et ADR-0002 (**ACTÉS**), conventions
**ACTÉES POUR LE LOT 0** de `LOT0_POC.md` et `LOT0_PREPARATION.md`. En
particulier : mécaniques artificielles déterministes (INTERVENTION_ALPHA),
sécurité dès le POC, curseur par flux client, cinq tentatives automatiques
au maximum, `RECOVERY_PAUSED` puis reprise explicite MJ, et acceptation à
100 % des opérations requises.

**Portée** : Flutter est le **premier candidat expérimental**. Le code
doit rester comparable si une évaluation React Native est décidée ensuite :
mêmes oracles, mêmes parcours, mêmes mesures.

Tout élément ci-dessous marqué **RECOMMANDATION** ou **À TESTER** reste
révisable sans nouvelle décision. Les points **À ARBITRER** sont regroupés
en §10.

## 2. Principes de conception retenus pour le POC — RECOMMANDATION

1. **Domaine d'abord, sans dépendance** : la résolution d'INTERVENTION_ALPHA,
   l'horloge fictive et les échéances sont en Dart pur, sans Flutter,
   `dart:io`, réseau ni stockage.
2. **Frontières vérifiées par le compilateur** : chaque composant logique
   de `LOT0_PREPARATION.md` §2 devient un package Dart distinct. Un package
   ne peut importer que les packages autorisés (§3.2).
3. **La projection est une frontière de sécurité** : les données envoyées
   au client sont construites par des types dédiés, jamais par
   sérialisation d'un objet maître. Tests de non-fuite obligatoires.
4. **Commit avant diffusion** : aucune confirmation ni diffusion avant
   l'écriture durable de la mutation, de l'événement et du résultat de
   déduplication.
5. **Tests d'oracle avant intégration** : chaque oracle d'INTERVENTION_ALPHA
   et des incidents A et B est un test automatisé nommé, exécuté en CI.
6. **Tranches verticales courtes** : chaque tranche se termine par des tests
   verts et un état documenté ; aucun échafaudage vide créé à l'avance.
7. **Dépendances minimales et examinées** : toute dépendance mobile est
   évaluée sur les permissions et entitlements qu'elle introduit dans
   l'artefact final (ADR-0002) avant d'être conservée.
8. **Aucun secret dans les journaux** : jetons, secrets de scénario et
   payloads maître sont exclus des logs, y compris en debug.

## 3. Organisation du code dans `app/`

### 3.1 Arborescence cible — RECOMMANDATION

Espace de travail Dart (*pub workspace*) à la racine de `app/`, un
package par frontière logique. Les packages ne sont créés qu'au moment de
la tranche qui en a besoin (§4).

``` text
app/
├── README.md                     # démarrage, commandes, état des tranches
├── pubspec.yaml                  # racine du workspace Dart
├── analysis_options.yaml         # règles d'analyse communes
├── packages/
│   ├── domain/                   # T1 — Dart pur : horloge, échéances, commandes,
│   │                             #      résolution artificielle, événements
│   ├── session/                  # T2 — Dart pur : service maître, autorisation,
│   │                             #      déduplication, ports de persistance
│   ├── persistence_sqlite/       # T2 — adaptateur SQLite du port de persistance
│   ├── projection/               # T3 — Dart pur : vues client, flux et curseurs
│   ├── protocol/                 # T4 — Dart pur : messages expérimentaux et codec
│   ├── transport/                # T4 — dart:io : serveur/client WebSocket TLS,
│   │                             #      enrôlement, reprise
│   └── scenario_package/         # T6 — lecture et vérification .24scenario
├── companion/                    # T0 — application Flutter (Android + iOS),
│                                 #      rôles maître et joueur, adaptateurs mobiles
├── fixtures/
│   └── intervention_alpha/       # T1 — données synthétiques du micro-scénario
├── spikes/                       # explorations jetables, hors workspace et hors CI
└── tool/
    └── ci/                       # T0 — contrôle des permissions des artefacts
```

Les noms de packages sont provisoires. `companion/` est **un seul projet
Flutter à deux rôles**, conformément à la recommandation d'architecture
**À TESTER**. Il ne décide pas du nombre de binaires distribués.

### 3.2 Règles de dépendance entre packages

| Package | Peut dépendre de | Ne doit jamais dépendre de |
|---|---|---|
| `domain` | SDK Dart (hors `dart:io`) | Flutter, `dart:io`, autres packages 24 |
| `session` | `domain` | Flutter, `dart:io`, `transport`, adaptateurs |
| `projection` | `domain` | `session` interne, Flutter, `dart:io`, `transport` |
| `protocol` | `projection` (types de vue) | `domain` interne, `session`, Flutter |
| `persistence_sqlite` | `session` (ports), `domain` | Flutter, `transport` |
| `transport` | `protocol`, `dart:io` | `domain`, `session` interne, Flutter |
| `scenario_package` | `domain` | Flutter, `transport` |
| `companion` | tous | — |

`protocol` ne voit jamais les types du domaine complet : un client ne peut
recevoir que ce que `projection` a explicitement construit. Un contrôle
automatique des imports en CI est **RECOMMANDÉ** dès T3 (vérification des
`pubspec.yaml` et des `import`).

### 3.3 Conventions techniques

- Flutter 3.47.4 stable / Dart 3.13.3, versions épinglées en CI.
- Analyse : `package:lints` (packages Dart) et `package:flutter_lints`
  (application), avec `dart format` imposé.
- Tests : `package:test` pour les packages Dart, `flutter_test` pour
  l'application ; les oracles portent le nom de l'étape qu'ils vérifient.
- Identifiants client aléatoires générés par `Random.secure()` ; aucun
  identifiant matériel.
- `.gitignore` complété pour Flutter/Dart (`.dart_tool/`, `build/`,
  fichiers locaux Android/iOS générés, `*.jks`, `key.properties`).

## 4. Tranches d'implémentation — RECOMMANDATION

Chaque tranche : implémentation, tests verts en CI, mise à jour de
`app/README.md` et, si une conclusion change, de la documentation `doc/dev`.
Les détails laissés ouverts par `LOT0_PREPARATION.md` §9 sont tranchés
**au plus tard dans la tranche indiquée**, avant le test qui en dépend.

### T0 — Socle et CI

- Workspace `app/`, `analysis_options.yaml`, `.gitignore` Flutter.
- `companion/` créé par `flutter create --platforms=android,ios`, sans code
  24, sans dépendance supplémentaire.
- CI GitHub Actions (§6) : format, analyse, tests, build APK et contrôle
  des permissions de l'artefact Android dès ce socle.
- Build iOS sans signature sur runner macOS : reporté par arbitrage (§10).

**Sortie** : CI verte, allowlist Android initiale revue humainement (§5).

### T1 — Domaine INTERVENTION_ALPHA

- Horloge fictive, tension, points d'action, informations privées,
  objet QR, échéance 14:10 et événement ALERTE_ALPHA, en Dart pur.
- Commande EXAMINER(OBJET_ALPHA) résolue de façon déterministe.
- États de session incluant `RECOVERY_PAUSED` (nom provisoire) et reprise
  explicite MJ, sans persistance réelle.
- Tests d'oracle : parcours principal étapes 1 à 8 (hors transport),
  `RESOURCE_EXHAUSTED`, ALERTE_ALPHA exactement une fois lors de
  l'avancement 14:00 → 14:10 et d'une progression ultérieure.

**Précisé ici** : représentation des données synthétiques (fixture), forme
des commandes et événements de domaine, erreurs métier.

**Réalisation (13 septembre 2026)** : package `app/packages/domain`
(`juste_a_temps_domain`) et fixture JSON expérimentale
`app/fixtures/intervention_alpha/scenario.json`. Les oracles de l'état
initial, des étapes 1 à 5, 7 et 8, d'ALERTE_ALPHA et la logique de l'incident B
sont des tests automatisés.

**Écart au plan** : l'étape 6 (retransmission exacte de C1) est reportée en
T2, où elle est déjà prévue. La déduplication dépend de l'identité du client
authentifié et de la persistance, qui appartiennent au service de session et
non au domaine. Le test existe et est marqué comme ignoré jusqu'à T2.

**Précisions prises en T1 — à valider** (détail dans
`app/packages/domain/README.md`) :

1. un nouvel examen du même objet est valide et coûte son prix, sans
   nouvelle information (base de l'étape 7) ;
2. en `RECOVERY_PAUSED`, les commandes joueurs sont aussi refusées, pas
   seulement l'avancement du temps ;
3. pause et reprise sont des événements publics ; l'audio est réservé au
   maître ;
4. un avancement au-delà d'une échéance la déclenche à son heure exacte ;
5. QR de test opaque, groupes destinataires non encore modélisés,
   session limitée à une journée fictive.

### T2 — Service maître et persistance

- Service de session : authentification abstraite (port), autorisation,
  ordonnancement unique des commandes concurrentes.
- Port de persistance et adaptateur SQLite : état officiel, journal
  séquencé global, résultats de déduplication.
- Transaction unique : mutation + événement(s) + séquence + résultat de
  commande, puis seulement confirmation.
- Tests : retransmission exacte de C1 sans nouvelle mutation ; même
  identifiant avec contenu différent détecté ; **incident B** (persistance
  14:07, arrêt, redémarrage en `RECOVERY_PAUSED`, aucune exécution
  d'ALERTE_ALPHA avant reprise explicite, puis une seule exécution).

**Précisé ici** : clé de déduplication (session + client authentifié +
identifiant de commande), rétention, schéma SQLite expérimental.

### T3 — Projections et flux client

- Construction explicite de `ClientPlayerView` (nom provisoire) et des
  entrées de flux par destinataire.
- Curseur propre à chaque flux autorisé, sans exposer la séquence globale.
- Snapshot filtré cohérent associé à une position du flux, puis reprise
  des entrées suivantes sans perte ni duplication.
- Tests de non-fuite : P1 ne reçoit ni INDICE_ALPHA de P2 ni
  SECRET_MJ_ALPHA ; contrôle sur les objets **et** sur leur forme
  sérialisée ; aucune donnée d'ALERTE_ALPHA avant 14:10 ; **incident A** au
  niveau logique (P1 absent pendant l'alerte, rattrapage exact).

**Précisé ici** : persistance des curseurs, raccord snapshot/flux,
visibilité tardive et conditions de repli sur snapshot.

### T4 — Protocole expérimental, transport et sécurité

- Codec des messages expérimentaux (commande, accusé, entrée de flux,
  snapshot, reprise, erreur), versionné et explicitement provisoire.
- Serveur WebSocket sur TLS embarqué dans le maître, client joueur.
- Enrôlement par QR de connexion : donnée de confiance du maître + jeton
  d'enrôlement temporaire ; jeton de reprise distinct ; association
  client/personnage décidée par le maître.
- Reconnexion : cinq tentatives automatiques maximum, succès seulement après
  réauthentification et resynchronisation complète ; mesures t0, t1, t2.
- Tests d'intégration **sur l'hôte** (plusieurs clients Dart dans le même
  processus de test, `dart:io`) : faux maître refusé, client inconnu refusé,
  accès croisé refusé, jeton rejoué ou expiré, retransmission après commit
  avant réponse, épuisement des cinq tentatives.
- Essais matériels : maître sur Pixel 8a, joueur sur AVD (et inversement).

**Précisé ici** : cycle de vie des jetons, temporisations et backoff,
mécanisme de confiance (§7), format expérimental du QR de connexion.

**Exploration anticipée RECOMMANDÉE** : dès T1 verte, un court essai
jetable du serveur WebSocket TLS sur le Pixel, pour détecter tôt un
blocage de faisabilité, dans `app/spikes/` (§10). Aucun code de spike
n'est réutilisé tel quel dans les packages.

**Prérequis** : ADR-0003 validé (§5, §10) avant l'ajout de `INTERNET`.

### T5 — Découverte locale et changement d'adresse

- Publication et découverte Bonjour/mDNS ; la découverte ne vaut jamais
  authentification.
- Test de changement d'IP du maître : retrouver la session par son identité,
  pas par l'adresse.

### T6 — Package `.24scenario`, import et OFFLINE_READY

- Lecture et vérification du package expérimental : manifeste, versions,
  digest, références internes, mapping QR, assets image/audio.
- Import maître limité au stockage privé de l'application ; aucun parcours
  des fichiers personnels. Mécanisme d'import comparé selon ADR-0002.
- État `OFFLINE_READY` avant création de session.

### T7 — Adaptateurs mobiles et interfaces minimales

- Interfaces minimales MJ et joueur, suffisantes pour les parcours.
- Scan QR depuis le flux caméra, permission demandée au premier besoin,
  aucun accès Photos.
- Audio ALERTE_ALPHA_AUDIO côté maître, écran maintenu éveillé, passage
  temporaire en arrière-plan : audio et réseau observés séparément.
- Inspection du stockage et des journaux du client joueur (test de
  confidentialité de `LOT0_POC.md`).

### T8 — Campagnes A, B, C et rapport

- Banc reproductible, décomptes, programme de charge et calendrier
  d'incidents consignés ; clients complémentaires physiques ou virtuels.
- Rapport des mesures et de la grille comparative Flutter.

## 5. Permissions et allowlist — ACTÉ sur le principe, noms À ARBITRER

L'ADR-0002 impose l'allowlist sur l'artefact final et toute nouvelle
permission par décision explicite. Les **noms concrets** des permissions
correspondant aux capacités autorisées ne sont pas encore fixés. Proposition
à valider **avant d'ajouter la dépendance ou la fonction qui les introduit** :

| Capacité ADR-0002 | Android — à confirmer sur les builds observés | iOS — à confirmer |
|---|---|---|
| Réseau local | `INTERNET` ; `ACCESS_NETWORK_STATE` et `CHANGE_WIFI_MULTICAST_STATE` si requis par mDNS | `NSLocalNetworkUsageDescription`, `NSBonjourServices` |
| Caméra QR | `CAMERA` | `NSCameraUsageDescription` |
| Sortie audio | aucune permission attendue | mode arrière-plan audio pour le rôle maître, **À TESTER** |
| Écran éveillé (maître) | aucune si drapeau de fenêtre ; `WAKE_LOCK` à éviter sauf nécessité démontrée | aucune attendue |
| Stockage privé | aucune | aucune |

Mise en œuvre T0 : l'allowlist Android initiale reflète exactement le
template Flutter **observé** sur l'APK release, puis s'élargit uniquement
par une modification revue de `tool/ci/`. Contrôle sur l'APK release, pas
seulement debug : le template ajoute `INTERNET` aux variantes debug/profile.

**Arbitré (option B, §10)** : cette table sera formalisée par un ADR-0003
validé avant T4, puis amendé pour toute nouvelle permission.

## 6. Intégration continue — RECOMMANDATION

### 6.1 Principes

- GitHub Actions, déclenchement sur `push` et `pull_request` vers `main`,
  limité aux changements de `app/` et de la CI pour les jobs de build.
- Jeton du workflow en lecture seule (`permissions: contents: read`) ;
  aucun secret requis au LOT 0 ; aucune signature d'application en CI.
- Versions épinglées : Flutter 3.47.4 et actions tierces référencées par
  empreinte de commit ou version exacte ; aucune action non officielle sans
  examen.
- Artefacts APK conservés brièvement pour inspection, jamais publiés.

### 6.2 Jobs

| Job | Runner | Contenu | Dès |
|---|---|---|---|
| `analyze-test` | Linux | `dart format --set-exit-if-changed`, `dart analyze`, tests des packages et de l'application | T0 |
| `android-permissions` | Linux | `flutter build apk --release` (non signé ou signature debug), extraction du manifeste final (`aapt2`/`apkanalyzer`), comparaison stricte à `tool/ci/android-permissions.allowlist` | T0 |
| `ios-build` | macOS | `flutter build ios --no-codesign`, extraction des clés `Info.plist` et entitlements, comparaison à une allowlist iOS | T0 si le runner le permet, sinon dès que possible |
| `boundaries` | Linux | contrôle des dépendances et imports interdits entre packages | T3 |

### 6.3 Points à vérifier avant activation

- Disponibilité et coût des runners macOS GitHub pour ce dépôt public :
  **À VÉRIFIER** sur la documentation GitHub en vigueur.
- Compatibilité de la version Xcode des runners avec Flutter 3.47.4 et la
  référence Xcode 26.6 / SDK iOS 26.5.
- Outil exact d'extraction du manifeste Android disponible sur le runner.

## 7. Sécurité du transport — options à tester en T4

Contraintes existantes : TLS ou protection standard équivalente, identité
du maître, donnée de confiance obtenue par QR, jamais de validation du pair
désactivée, aucune cryptographie inventée.

**Option candidate principale — À TESTER** : le maître génère une paire de
clés et un certificat auto-signé propres à la session ou à l'installation.
Le QR de connexion transporte l'empreinte SHA-256 du certificat. Le client
n'accepte **que** ce certificat (épinglage strict), puis présente le jeton
d'enrôlement dans le canal chiffré.

Points à démontrer : génération du certificat sur Android et iOS sans
dépendance ajoutant des permissions ; faisabilité de l'épinglage strict
avec les API TLS de `dart:io` sans accepter un certificat inattendu ;
comportement lors d'un changement d'IP ; persistance de la donnée de
confiance côté client pour la reprise.

**Alternatives à comparer si l'option principale échoue** : certificat
stable du maître par installation ; protocole d'appairage standard reposant
sur un secret court affiché par le maître. Aucune n'est retenue ici.

## 8. iOS — état et pistes d'émulation

**Constat** : aucun Mac ni iPhone local ; Windows ne permet pas d'exécuter
le simulateur iOS, qui requiert macOS et Xcode. `DEV_ENVIRONMENT.md`
contient la shortlist à étudier et la grille A à G.

| Famille (shortlist existante) | Ce qu'elle peut couvrir | Limites attendues, à vérifier |
|---|---|---|
| Runner macOS de CI (Mac distant) | A compilation ; tests automatisés sur simulateur ; C protocole entre simulateur et processus de test sur le même Mac | Pas de caméra ni de LAN réel avec les téléphones du banc |
| Mac/Xcode distant loué, conforme aux licences Apple | A, B exécution interactive sur simulateur ; C | Même limites ; latence d'usage |
| Corellium (iOS virtualisé) | B exécution sur appareil virtuel ; C via réseau du service ; E une partie des permissions | Accès au maître Android local seulement par tunnel (D) ; ne vaut pas un iPhone sur le LAN |
| BrowserStack, Sauce Labs, TestingBot, AWS Device Farm (appareils réels distants) | B sur vrais iPhone ; E permissions réelles ; caméra selon offre | Maître local seulement via tunnel ; Bonjour sur LAN réel non couvert |
| Appetize.io (simulateur en streaming) | B démonstration d'interface | Peu adapté au serveur local, au réseau et au background |

**Conséquences pour la conception** :

- le code transport et domaine est testable sans iOS (Dart pur et `dart:io`
  sur l'hôte) ; seules les frontières plateforme dépendent d'iOS ;
- la compilation iOS en CI est la première validation iOS réaliste (§6) ;
- la **configuration maître iOS** et Bonjour sur le LAN réel (F), le
  hotspot et le background (G) exigent un iPhone physique ; aucune solution
  émulée ne remplace cette validation, déjà requise avant validation finale
  de la stack.

## 9. Diagnostic et journaux

- Catégories d'erreurs de `LOT0_POC.md` : réseau, reconnexion, persistance,
  commande rejetée, synchronisation, package/scénario, séquence incohérente.
- Codes d'erreur stables et testés dès T1 (`RESOURCE_EXHAUSTED`…).
- Journal local structuré, niveaux distincts maître/joueur ; filtrage des
  champs sensibles par construction (types dédiés), vérifié par tests en T4
  et par inspection en T7.
- Aucun service tiers de collecte ou de crash reporting.

## 10. Arbitrages pour T0

**Arbitrés le 13 septembre 2026** :

- **Identité de l'application** : package Dart `juste_a_temps` ;
  `applicationId` Android et bundle identifier iOS
  `io.github.cpovereau.justeatemps` ; nom affiché « Juste à temps ».
  Ces identifiants concernent le POC et ne décident ni du nom commercial
  définitif ni du nombre de binaires.
- **Licence** : fichier `LICENSE` « Tous droits réservés » à la racine.
- **Exploration anticipée T4** : dans `app/spikes/`, code jetable, hors
  workspace Dart et exclu de la CI.
- **Runner macOS** : reporté ; le job `ios-build` n'est pas activé en T0.
- **Workspace Dart multi-packages** (§3) : confirmé.
- **Procédure d'ajout de permission — option B** : un **ADR-0003**
  établira la correspondance entre capacités ADR-0002 et permissions
  Android/iOS concrètes, sur la base des builds observés. Il sera proposé à
  validation humaine **avant T4**, puis amendé à chaque nouvelle permission.
  Une permission absente de cette table exige une nouvelle décision
  explicite. Les allowlists de `tool/ci/` y font référence. Doit être tranché avant T4
   (`INTERNET` pour le WebSocket).

## 11. Hors périmètre de ce document

Choix définitif de Flutter, nombre de binaires, protocole et sécurité de
production, format définitif des packages et QR, politique produit de
récupération, progression interscénarios, notifications, affichage
physique, crash reporting tiers et routeur recommandé.
