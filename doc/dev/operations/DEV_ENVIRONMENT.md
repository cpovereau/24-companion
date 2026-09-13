# LOT 0 — Environnement de développement

## Installation réelle — suivi du 13 septembre 2026

Flutter reste candidat expérimental nº 1, sans choix de stack produit.
Ce suivi actualise l'inventaire préalable conservé ci-dessous.

### Palier A — VALIDÉ

- Flutter 3.47.4 stable Windows x64, Dart 3.13.3 inclus, installé dans
  `C:\dev\flutter` depuis l'archive officielle Google Storage.
- Archive conservée dans `C:\dev\downloads`, SHA-256 vérifié contre
  l'[index officiel Windows](https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json).
- `C:\dev\flutter\bin` ajouté une seule fois au PATH utilisateur.
  JAVA_HOME et JDK global inchangés. Analytics Flutter désactivées.
- `flutter --version`, `dart --version`, `flutter doctor -v` réussis.
  Section Flutter valide ; SDK Android encore absent à ce palier, attendu.
- Avant téléchargement : C: environ 97,2 Gio libres. Studio Quail 4
  2026.1.4, Emulator 37.1.11 stable et API 36 du guide Flutter reconfirmés.
- Aucune création de projet 24, aucun AVD, aucune modification WHP.

### Palier B — VALIDÉ (démarrage)

- Android Studio Quail 4 / 2026.1.4, build
  `AI-261.26222.65.2614.16204760`, archive Windows officielle extraite dans
  `C:\dev\android-studio` ; SHA-256 conforme à la page Android officielle,
  signature Authenticode Google valide.
- Runtime embarqué : OpenJDK 25.0.3, build
  `25.0.3+-15898627-b508.16`, dans `C:\dev\android-studio\jbr`.
  Temurin et JAVA_HOME global conservés.
- Démarrage observé : processus répondant, écran de consentement puis
  « Android Studio Setup Wizard ». Statistiques refusées (« Don't send »).
  Aucun projet créé. Installation SDK gérée séparément pour maîtriser les composants.
- **Assistant de premier démarrage finalisé le 13 septembre 2026**, après les
  paliers H et I, avec l'émulateur arrêté (7 575 Mio disponibles avant
  lancement de Studio). Type d'installation Custom ; SDK existant
  `C:\dev\android-sdk` détecté ; aucun AVD ni pilote AEHD proposé.
  Le composant « Android SDK Platform — Android 17.0 (CinnamonBun ; API 37.0),
  50,4 MB », non décochable, correspondait uniquement à
  `sources;android-37.0` révision 2 (canal stable, `source-37.0_r02.zip`
  depuis dl.google.com), installé dans `sources\android-37.0`
  (environ 212 Mio). Aucun autre paquet ajouté ; `lot0_api37_medium_phone`
  reste le seul AVD. « CinnamonBun » est le nom de code d'Android 17
  affiché par Studio, pas un paquet bêta installé.
- Configuration Studio constatée : `android.sdk.path.xml` vaut
  `C:\dev\android-sdk`, `androidStudioFirstRun.xml` est présent
  (assistant terminé) et les SDK Android 36 et 37.0 sont déclarés dans
  `jdk.table.xml`. Consentement statistiques enregistré comme refusé.
  Écran « Welcome to Android Studio » atteint (Quail 4, 2026.1.4), Studio
  occupant environ 1,6 Gio.
- `flutter doctor -v` après l'assistant : aucun problème, SDK
  `C:\dev\android-sdk`, plateforme android-37.0, Build-Tools 36.0.0, Java
  de Studio 25.0.3, licences acceptées.

### Palier C — VALIDÉ (composants installés)

- SDK retenu : `C:\dev\android-sdk` ; Command-line Tools 23.0 installés
  dans `cmdline-tools\latest`, archive officielle `16111833`, empreinte
  vérifiée contre le dépôt Google. `sdkmanager --version` fonctionne.
- Cette distribution redirige sdkmanager vers Android CLI
  `1.0.16261425` (avertissement de dépréciation). Il s'agit du composant
  embarqué dans les outils officiels ; aucun écosystème séparé ajouté.
- Flutter configuré avec `android-studio-dir = C:\dev\android-studio`.
  Le Java de Studio n'est défini que pour les processus des outils SDK.
- Platform-Tools 37.0.1 installé dans `platform-tools` ; adb 1.0.41,
  build 37.0.1-15733141, commande de version réussie.
- Platform API 36 révision 2 installée dans `platforms\android-36`.
- Build-Tools 36.0.0 installés dans `build-tools\36.0.0` ; aapt2 fonctionne.
  Version conforme au défaut AGP 9.1 fourni par le template Flutter stable.
- NDK r28c / 28.2.13676358 installé dans `ndk\28.2.13676358`, version
  prescrite par le SDK Flutter installé ; extraction et métadonnées vérifiées.
- CMake 4.1.2 installé via le dépôt Android dans `cmake\4.1.2` ; commande
  de version réussie. CMake et NDK figurent dans le guide Android Flutter
  stable consulté ; aucune version parallèle installée.
- Emulator 37.1.11.0 / build 15917651 installé dans `emulator` ;
  `emulator -version` réussi. Aucun AVD créé ou lancé.
- Platform Android 17 / API 37.0 révision 2 installée dans
  `platforms\android-37.0` ; PreviewSdkInt = 0, aucun suffixe beta.
- Image stable Google APIs x86_64 API 37.0 révision 6 installée dans
  `system-images\android-37.0\google_apis\x86_64`. Aucun AVD créé.
- Flutter configuré avec `android-sdk = C:\dev\android-sdk`.
  Fichier utilisateur `.androidrc` créé avec uniquement `--no-metrics`,
  pour désactiver également les métriques des appels CLI indirects.
- Android CLI retourne actuellement 1 même pour une liste correctement
  affichée et l'installation achevée de Platform-Tools. Validation effectuée
  par `source.properties`, liste des paquets installés et exécution d'adb ;
  ne pas assimiler ce code à une preuve suffisante d'échec ou de réussite.
  Invocations directes Android CLI avec `--no-metrics`.

### Palier D — VALIDÉ

- `flutter doctor --android-licenses` exécuté : le wrapper officiel indique
  que cette option n'est plus nécessaire. `flutter doctor -v` confirme
  « All Android licenses accepted » et « No issues found ».
- Flutter et Android toolchain valides ; SDK détecté dans `C:\dev\android-sdk`,
  Emulator 37.1.11.0, Build-Tools 36.0.0. Java effectivement utilisé :
  `C:\dev\android-studio\jbr\bin\java`, OpenJDK 25.0.3 embarqué.
- Aucun remplacement du JAVA_HOME global, aucun JDK supplémentaire.
  Compatibilité de build à confirmer au palier G.

### Palier E — VALIDÉ (reconnaissance par VS Code)

- VS Code Marketplace : `Dart-Code.flutter` 3.142.0 et sa dépendance
  `Dart-Code.dart-code` 3.142.0 installées et listées par VS Code.
  Extension OpenAI/Codex conservée à 26.908.40401.
- Journaux VS Code de la session postérieure au redémarrage (13 septembre
  2026, 18:45) : `Dart-Code.dart-code` activée sur ouverture d'un fichier
  Dart, `Dart-Code.flutter` activée, commande `flutter` du SDK
  `C:\dev\flutter` exécutée avec code 0, puis « Device daemon started ».
  Flutter est donc trouvé sans réglage VS Code spécifique (PATH utilisateur).
- Non observé : sélection d'appareil dans l'interface VS Code. Aucun réglage
  du dépôt 24 ajouté. Le serveur LSP a expiré à l'arrêt de cette fenêtre
  (« Stopping server timed out »), sans effet constaté sur l'activation.

### Palier F — VALIDÉ après connexion volontaire

Initialement absent, puis détecté après activation et autorisation USB.
ANDROID_P01 : Google Pixel 8a, Android 17 / API 37 ; `adb -d get-state`
retourne `device`, confirmé après redémarrage du PC. Aucun identifiant
matériel conservé dans cette documentation.

### Palier G — VALIDÉ (build sans appareil)

- Projet temporaire Android seul : `C:\dev\lot0-toolchain-smoke` ;
  `flutter create` et résolution des dépendances réussis. Aucun code 24.
- `flutter build apk --debug` réussi, code 0, assembleDebug environ
  373,7 secondes au premier build (téléchargements et caches initiaux inclus).
- APK : `build\app\outputs\flutter-apk\app-debug.apk` dans ce projet.
  Après redémarrage du PC : installation USB réussie sur ANDROID_P01 via
  adb, lancement de MainActivity avec Status = ok et processus présent.
  Aucun nouveau build requis. Validation visuelle/interactions non mesurées.
- Java de Studio 25.0.3 utilisé par Gradle 9.3.1 du wrapper ; aucun Gradle global.
- Avertissements non bloquants : accès natif Java et lecture XML SDK
  (version 4 rencontrée, lecteur annonçant 3). Aucun changement de baseline.
- Pression mémoire observée pendant ce premier build : environ 0,18 Gio
  disponibles / commit 24,93 Gio sur un relevé, puis environ 1,27 Gio ;
  lectures de pagination importantes. Le template laisse un plafond heap
  Gradle de 8 Gio ; ce plafond n'est pas une allocation permanente mesurée.
  Aucun AVD lancé, aucun processus utilisateur fermé.
- Fenêtre VS Code temporaire demandée ; activation effective Flutter/Dart
  dans l'éditeur reste à confirmer (installation des extensions vérifiée).

### Palier H — VALIDÉ après redémarrage supervisé

- Avant modification : CIM indique HypervisorPlatform désactivée, Hyper-V
  et VMP activés, VBS en fonctionnement. `emulator -accel-check` annonce
  pourtant WHPX utilisable : divergence observée, pas une preuve de validation
  complète du banc avant redémarrage.
- Contrôle Windows élevé `Get-WindowsOptionalFeature` : état Disabled confirmé.
- Seule modification Windows :
  `Enable-WindowsOptionalFeature -Online -FeatureName HypervisorPlatform -NoRestart`.
  Résultat : état Enabled, RestartNeeded = True, aucune erreur.
- Aucun redémarrage déclenché. Hyper-V, VBS, BIOS, antivirus et firewall
  non modifiés. Aucun AEHD ajouté. Aucun AVD créé ou lancé.
- Redémarrage confirmé par l'utilisateur ; dernier démarrage Windows relevé
  le 13 septembre 2026 à 18:42:36 (heure locale). WHP, Hyper-V et VMP :
  InstallState = 1 ; VBS = 2. `emulator -accel-check` retourne 0 et WHPX
  utilisable. Flutter doctor ne détecte aucun problème, licences acceptées,
  SDK et Java de Studio reconnus. Pixel autorisé par adb.
- Points restant à vérifier à ce palier, depuis traités : reconnaissance des
  outils dans VS Code (palier E), finalisation de l'assistant Studio
  (palier B), premier AVD et ses mesures (palier I). Le build CLI est validé.

### Palier I — VALIDÉ : 1 AVD VIABLE MAIS CONTRAIGNANT

Historique : premier essai reporté pour mémoire insuffisante, puis AVD
créé, session allégée et AVD lancé le 13 septembre 2026 (détails ci-dessous).

Après redémarrage : 0,54 Gio disponibles au premier relevé, puis 991 Mio,
commit environ 18,68 / 39,46 Gio et lectures de pagination importantes
sur un échantillon (pas une mesure de pression soutenue).
Principales familles résidentes : Code environ 2,72 Gio, Java 1,83 Gio,
WebView2 1,12 Gio, WSL 0,57 Gio ; les sommes de working sets incluent
potentiellement des pages partagées et ne constituent pas un gain garanti.
Alléger les applications utilisateur non nécessaires avant une nouvelle mesure.
Aucun processus fermé automatiquement. Aucun AVD créé ou lancé ; mesures
AVD au repos/build et classement de viabilité restent À TESTER. Le lancement
d'un AVD de 4 Gio est déconseillé dans cet état mémoire précis.

**AVD créé, non lancé — 13 septembre 2026.** Création par
`avdmanager create avd` (Command-line Tools 23.0, Java de Studio limité au
processus) :

| Paramètre | Valeur |
|---|---|
| Nom | `lot0_api37_medium_phone` |
| Emplacement | `%USERPROFILE%\.android\avd` (C:, hors dépôt/Drive/OneDrive) |
| Profil matériel | `medium_phone`, téléphone générique |
| Image | `system-images;android-37.0;google_apis;x86_64`, révision 6 stable |
| RAM / heap VM | 4G / 228M |
| CPU / GPU | 4 cœurs / `hw.gpu.enabled=yes`, `hw.gpu.mode=auto` |
| Partition données | 10G |

`avdmanager` avait écrit `hw.ramSize=2G` et `hw.gpu.enabled=no`. Ces deux
valeurs ont été corrigées dans `config.ini`, dont l'original est conservé en
`config.ini.orig`, pour respecter le minimum de 4 Go documenté pour les AVD
téléphone API 37 et le mode GPU automatique par défaut de Studio. Le GPU
n'est pas qualifié pour autant. `emulator -list-avds` liste cet AVD, seul AVD
présent. C: : 79,2 Gio libres après création.

Relevé A, avant lancement : 5 388 Mio disponibles, 10 441 Mio utilisés,
commit 12,32 / 39,46 Gio, aucune pagination entrante et CPU indicatif 0 % au
relevé. Ce niveau est sous le repère local d'environ 6 Gio : lancement
suspendu en attente de validation humaine.

**Allègement complémentaire.** Arrêt des derniers sous-agents Dell (voir
la section Allègement). SonarLint (`sonarsource.sonarlint-vscode` 5.9.1,
serveur Java d'environ 0,49 Gio) a été désactivé par l'utilisateur
**pour le seul workspace** `C:\Temp\Perso\24`, qui est un workspace dossier
déjà connu de VS Code : aucun fichier `.code-workspace` ni `.vscode` créé.
Cette désactivation ne prend effet qu'après redémarrage de l'hôte
d'extensions : un arrêt du serveur Java avant ce redémarrage a entraîné sa
relance immédiate. Autres extensions laissées actives. Elles tournent dans
l'hôte d'extensions commun (environ 0,39 Gio) : leur désactivation ne
libérerait pas de gain notable immédiat. Point de vigilance pour le futur
projet Flutter : les extensions Java (Red Hat) et Gradle peuvent démarrer
un serveur Java sur les fichiers Gradle de `android/`. L'utilisateur les a
ensuite désactivées pour ce workspace. D'après l'état VS Code du workspace
(`extensionsIdentifiers/disabled`, lu sur une copie), les extensions
désactivées pour le seul workspace sont : `sonarsource.sonarlint-vscode`,
`redhat.java`, `vscjava.vscode-gradle`, `vscjava.vscode-java-debug` et
`vscjava.vscode-java-test`. Aucun processus Java actif au contrôle.
`vscjava.vscode-java-dependency` et `vscjava.vscode-java-pack` restent
actives mais dépendent de `redhat.java`, désactivée. `vscjava.vscode-maven`
et `vscjava.migrate-java-to-azure` restent actives (activation Maven sur
`pom.xml`, sans serveur Java observé). Les autres extensions (Python, PHP,
Docker…) sont inchangées. Seule désactivation globale préexistante :
`continue.continue`.

**Lancement et mesures du premier AVD.** Commande :
`emulator -avd lot0_api37_medium_phone -no-metrics -no-snapshot -no-boot-anim`
(démarrage à froid, sans sauvegarde d'état). Relevés instantanés : il ne
s'agit pas d'un benchmark. CPU = compteur Windows `% Processor Time` total,
indicatif.

| État | Disponible | Utilisée | Commit | Pagination entrante | CPU | Observations |
|---|---|---|---|---|---|---|
| A — avant lancement | 6 717 Mio | 9 112 Mio | 10,77 Gio | 0 /s | ~0 % | Dell arrêté, SonarLint inactif |
| Démarrage AVD (64 s) | minimum 1 525 Mio | — | 15,2 → 16,5 Gio | pics 22 000–64 000 /s | — | `sys.boot_completed=1` en 64 s |
| B — AVD au repos | ~1 450–1 580 Mio | ~14,3 Gio | ~16,5 Gio | 0–63 /s | 1–57 % (fin de boot invité) | qemu : 5,15 Gio WS, 5,4 Gio privés |
| C — VS Code + Flutter + AVD | ~1 580–1 650 Mio | ~14,2 Gio | ~16,5 Gio | pic 37 000 /s puis 0 | 0–30 % | `flutter devices` : Pixel 8a et `emulator-5554` Android 17/API 37 ; VS Code ~2,7 Gio |
| D — `flutter run --debug` sur l'AVD (101 s) | minimum 66 Mio | — | 17,2 → 19,6 Gio | pics jusqu'à 42 600 /s | 9–59 % | Gradle `assembleDebug` 88,1 s, installation 1,5 s ; Java/Gradle jusqu'à ~1,66 Gio ; WS qemu réduit par Windows de 5,14 à ~3,3 Gio |
| Après D, daemon Gradle arrêté | 3 037 Mio | — | 16,93 Gio | 0 /s | 12 % | `gradlew --stop` ; qemu 3,74 Gio WS |

Accélération : « Windows Hypervisor Platform accelerator is operational ».
Rendu : backend gfxstream sur le GPU Intel intégré (Vulkan détecté) ; les
exigences GPU matérielles de l'AVD sont signalées « passed ». Le journal
contient aussi « Software OpenGL failed. Falling back to system OpenGL »,
sans échec observé. L'émulateur affiche un avertissement de compatibilité
non bloquant : RAM système suggérée 16 384 Mio, 15 828 Mio visibles.

Résultat fonctionnel : l'application temporaire a été construite, installée
et lancée sur l'AVD (`MainActivity` au premier plan, rendu Impeller
OpenGLES), sans erreur. Les avertissements Gradle (accès natif Java) et SDK
XML v4 sont identiques au palier G. Validation visuelle et interactions non
mesurées.

**Classement : 1 AVD = VIABLE MAIS CONTRAIGNANT** sur ce poste, après
allègement. Le démarrage, le build et le lancement aboutissent. En revanche,
l'AVD de 4 Go laisse environ 1,5 Gio disponible au repos, et un build
Flutter amène la mémoire disponible près de zéro, avec une pagination
entrante très élevée et une réduction du working set de l'émulateur par
Windows. Ressenti perceptible : le poste n'a pas été manipulé pendant les
relevés, donc aucun ressenti interactif n'a été mesuré pendant A à D. Après D,
avec l'AVD toujours actif et le daemon Gradle arrêté, l'utilisateur ne
constate pas de ralentissement. Le classement repose donc sur les mesures
mémoire et pagination.
Deux AVD simultanés non testés et déconseillés dans cet état. Conséquences
pratiques, sans décision d'architecture : privilégier le Pixel pour les
cycles build/lancement ; arrêter le daemon Gradle après les builds quand un
AVD tourne ; éviter tout autre build ou application lourde pendant une
session AVD. L'assistant de premier démarrage
d'Android Studio n'est pas finalisé (aucun chemin SDK enregistré dans sa
configuration) ; il n'est pas nécessaire à la création de l'AVD en ligne de
commande.

### Allègement de la session avant AVD — 13 septembre 2026

Liste des applications/outils fermés, confirmée par l'utilisateur :
AnyDesk, TeamViewer, Docker, Spotify, Edge, HFSQL (Manta Manager),
PostgreSQL, CCleaner, Gradle et Kotlin, Mobile connecté.
Cette liste retrace les arrêts réalisés ; elle ne garantit pas qu'aucune
application ne redémarrera automatiquement.

Arrêts effectués par Codex sur autorisation explicite : Gradle par
`gradlew --stop` (Kotlin terminé également), processus Edge et Mobile connecté,
puis CCleaner et son service CCleaner7. PostgreSQL absent au contrôle suivant.
VS Code/Codex conservés à la demande de l'utilisateur.
Dell Optimizer Systray et DDPM utilisateur ont été arrêtés mais relancés
automatiquement par Dell.TechHub : ils ne sont pas considérés comme arrêtés.

Ensuite, l'utilisateur a arrêté six services Dell : Dell SupportAssist
Remediation, DellClientManagementService, DellPairService, DellTechHub,
DPMService et SupportAssistAgent. Ils sont à l'état Stopped, avec un
démarrage toujours Manual : ils peuvent être relancés par une application
ou au prochain démarrage de session. Arrêter un service n'a pas fermé ses
sous-agents : 15 processus Dell (environ 2 Gio de working set) restaient
actifs juste après. Au relevé suivant, 6 subsistaient (environ 0,73 Gio) :
DDPM.Subagent, DDPM.Subagent.User, Dell.Digital.Delivery.Service.SubAgent,
Dell.TechHub.DataManager.SubAgent, Dell.UCA.Manager et Dell.UUE.User.SubAgent.
Ces six processus ont ensuite été arrêtés sur autorisation explicite, après
contrôle : greffons Dell TechHub/SupportAssist (gestion écrans/périphériques,
livraison de logiciels, télémétrie), sans pilote ni composant Windows, et
dont les services étaient déjà arrêtés. Deux processus de session
utilisateur ont été arrêtés directement ; les quatre processus système l'ont
été via une élévation UAC acceptée par l'utilisateur. Aucun ne s'était
relancé 20 secondes après. Mémoire disponible : 5 470 Mio avant, 6 090 Mio
après, commit 11,68 Gio. Aucun réglage de démarrage automatique modifié :
ces composants peuvent revenir au prochain démarrage de Windows.

Relevé lors de la première consignation : 5 353 Mio disponibles
(environ 5,23 Gio), commit 12,26 Gio. Après les arrêts Dell : 5 455 Mio
disponibles, commit 12,25 Gio, sans pagination entrante au relevé. Les variations entre relevés ne
permettent pas d'attribuer un gain exact à chaque fermeture.
Repère local proposé, non seuil officiel : viser environ 6 Gio disponibles
pour un essai AVD de 4 Gio sans compilation simultanée ; davantage pour un build.
Le premier AVD reste non lancé et non qualifié.

### Script local d'allègement avant AVD

Pour rendre l'allègement reproductible, un script PowerShell local existe
sur le poste : `C:\dev\scripts\prepare-avd-session.ps1`. Il est **hors
dépôt et non versionné**, car il contient des noms d'applications et de
services propres à ce poste.

Ce qu'il fait :

- mesure la mémoire disponible et le commit avant et après ;
- arrête les daemons Gradle/Kotlin ;
- ferme les applications utilisateur non nécessaires au banc : outils
  d'accès distant, conteneurs, musique, nettoyage, Mobile connecté,
  utilitaires constructeur, navigateur Edge sauf avec `-KeepEdge` ;
- arrête les services qui relanceraient ces applications ou qui
  consomment de la mémoire sans servir au banc : accès distant,
  conteneurs, bases de données locales, utilitaires constructeur ;
- arrête les sous-agents constructeur orphelins et exécute `wsl --shutdown`
  si une VM WSL tourne ;
- signale les processus relancés et compare la mémoire disponible au seuil
  local, 6 000 Mio par défaut (`-ThresholdMB`) ;
- avec `-StartEmulator`, lance `lot0_api37_medium_phone` en démarrage à
  froid, sans métriques ni sauvegarde d'état, seulement si le seuil est
  atteint (`-Force` pour passer outre).

Garde-fous : simulation avec `-WhatIf` ; auto-élévation UAC hors
simulation ; aucun type de démarrage modifié, donc le script est à
relancer après chaque redémarrage de Windows. VS Code, Codex, Claude Code,
Android Studio (seulement signalé s'il est ouvert), Defender et Hyper-V/WHP
ne sont jamais touchés.

``` powershell
pwsh -File C:\dev\scripts\prepare-avd-session.ps1 -WhatIf
pwsh -File C:\dev\scripts\prepare-avd-session.ps1 -StartEmulator
```

Validation : exécution en simulation réussie le 13 septembre 2026, avec
6 856 Mio disponibles. Aucune exécution réelle ni mesure de gain n'a encore
été faite avec ce script.

Sur ce poste, le banc courant privilégie les appareils Android physiques
et au maximum un AVD simultané jusqu'à mesure contraire. Avant les campagnes
AVD, alléger les applications utilisateur non nécessaires et mesurer la
mémoire disponible.

## Inventaire préalable à l'installation

Inventaire du 13 septembre 2026. Diagnostics en lecture seule et consultation
des sources officielles ; aucune installation, modification Windows ou BIOS,
détection de téléphone, création de projet ou sélection définitive de stack.
Les mesures libres sont instantanées. Aucun identifiant personnel, compte,
token ou numéro de série n'est conservé ici.

## ÉTAT OBSERVÉ — matériel et Windows

| Élément | Constat |
|---|---|
| OS | Windows 11 Professionnel 25H2, 10.0.26200.9445 |
| Architecture | x64, processeur et OS 64 bits |
| CPU | Intel Core Ultra 7 165U ; 12 cœurs physiques, 14 processeurs logiques rapportés par CIM |
| RAM installée | 16 Gio (somme des capacités physiques) |
| RAM visible par Windows | Environ 15,46 Gio |
| RAM disponible | Environ 1,09 à 1,22 Gio pendant les relevés ; forte occupation actuelle |
| GPU | Intel Graphics ; pilote 32.0.101.8860 |
| VRAM | CIM rapporte environ 2 Gio via AdapterRAM ; ne constitue pas une mesure fiable de VRAM dédiée sur ce GPU intégré. Capacité dédiée/partagée exacte non déterminée |
| Écran | 1920 × 1080 rapporté par le contrôleur |
| Disque physique | SSD NVMe 512,11 Go, soit environ 476,94 Gio |
| Volume C: | 473,8 Gio au total ; 97,2 Gio libres au relevé |

C: est le volume local proposé pour outils, SDK et AVD ; les répertoires
exacts restent à fixer lors de l'installation. Aucun espace cloud monté
n'est compté comme capacité physique supplémentaire ou cible des AVD.
Prévoir téléchargements, extraction, SDK, caches Gradle et snapshots : la
place actuelle permet un banc initial limité, pas une réserve illimitée.

### Virtualisation

| Élément | Constat |
|---|---|
| HypervisorPresent | True |
| Hyper-V et hyperviseur Hyper-V | Activés, InstallState = 1 via Win32_OptionalFeature |
| Virtual Machine Platform | Activée, InstallState = 1 |
| Windows Hypervisor Platform | Désactivée, InstallState = 2 |
| Sous-système Windows pour Linux | Fonctionnalité activée ; distributions non inventoriées |
| VBS | En fonctionnement, VirtualizationBasedSecurityStatus = 2 |
| Services HvHost, vmcompute, vmms | En cours d'exécution |

Les indicateurs processeur VirtualizationFirmwareEnabled, SLAT et
VMMonitorModeExtensions valent False dans CIM, alors qu'un hyperviseur et
VBS fonctionnent. Ne pas conclure à une virtualisation désactivée dans le
BIOS à partir de ces seuls indicateurs : leur exposition sous hyperviseur
est insuffisante pour cette conclusion. L'utilisation effective d'un
hyperviseur est observée ; l'aptitude exacte à Android Emulator reste à tester.

Get-WindowsOptionalFeature exigeait une élévation ; aucune élévation n'a été
tentée. La lecture Win32_OptionalFeature a permis l'inventaire ci-dessus.

Android recommande WHPX sur Windows. Hyper-V actif ne signifie pas que
Windows Hypervisor Platform est activée. Pour le banc recommandé, prévoir
son activation seulement après autorisation, puis un contrôle
`emulator -accel-check` une fois l'émulateur installé. Ne pas désactiver
Hyper-V/VBS pour installer un pilote concurrent. AEHD arrive en fin de
support fin 2026 selon la documentation. [Accélération officielle](https://developer.android.com/studio/run/emulator-acceleration).

## ÉTAT OBSERVÉ — outils

| Outil | Version / état |
|---|---|
| VS Code | 1.137.0 x64 |
| Extension OpenAI/Codex identifiable | openai.chatgpt 26.908.40401 |
| Git | 2.55.0.windows.5 |
| Node | 22.16.0 |
| npm | 11.0.0 |
| Java | Eclipse Temurin OpenJDK 21.0.11+10 LTS, HotSpot x64 |
| JAVA_HOME | C:\Program Files\Eclipse Adoptium\jdk-21.0.11.10-hotspot\ |
| Python | 3.13.4 ; lanceur py présent |
| PowerShell courant | 7.6.6 |
| GitHub CLI | 2.97.0 |
| Chocolatey | 2.4.3 |
| winget | 1.29.290 |
| Scoop | Non trouvé dans le PATH |

Flutter, Dart, Android Studio, Android SDK, adb et sdkmanager : absents
selon confirmation humaine, aucun exécutable trouvé dans le PATH, aucun
Android Studio/SDK dans les emplacements standards inspectés, aucune entrée
correspondante dans les registres de désinstallation interrogés. Ce contrôle
n'est pas une recherche exhaustive des logiciels portables sur le disque.

Méthodes : CIM matériel/OS, capacités mémoire, Get-PhysicalDisk et association
C: au disque NVMe, registre Windows limité aux versions et logiciels pertinents,
Get-Command, commandes de version, liste des extensions filtrée OpenAI/Codex.

## Capacité estimée du banc AVD — À TESTER

**RECOMMANDATION validée pour ce poste** : 1 AVD simultané maximum en usage
courant, complété par les appareils Android physiques. Avant les campagnes
AVD, alléger les applications utilisateur non nécessaires puis mesurer et
consigner la mémoire disponible. Cette préparation ne signifie pas arrêter
des services Windows ou des protections de sécurité.

Android documente 16 Go minimum pour Studio avec émulateur, 32 Go recommandés,
un GPU avec 4 Go de VRAM minimum et déconseille les séries CPU U/N. Le poste
atteint la RAM minimale, mais son CPU U et son GPU intégré invitent à rester
prudent. Le SSD et l'écran sont favorables. [Prérequis Studio](https://developer.android.com/studio/install).
Les AVD téléphone API 37 imposent au moins 4 Go de RAM chacun.
[Notes Emulator](https://developer.android.com/studio/releases/emulator).

| Configuration | Classement | Justification |
|---|---|---|
| Studio + 1 AVD | À TESTER | 4 Go pour la VM, plus IDE/build/OS ; seulement ~1,1 Go actuellement libre, GPU à qualifier et WHPX désactivé. Plausible après libération de mémoire et préparation autorisée, pas garanti confortable |
| Studio + 2 AVD | À TESTER, hors usage courant recommandé | Au moins 8 Go de VM ; marge étroite sur 16 Go, compilation et rendu concurrents sur CPU U/GPU intégré |
| Studio + 4 AVD | DÉCONSEILLÉ | Au moins 16 Go de VM seuls, avant Windows, IDE, build et mémoire graphique ; pagination et contention susceptibles de fausser les mesures |
| Studio + 6 AVD | DÉCONSEILLÉ | Au moins 24 Go de VM, au-delà de la RAM physique ; SSD ne remplace pas RAM/CPU/GPU |

Ces classements sont des estimations, pas des benchmarks. Dans l'occupation
mémoire actuelle, aucun lancement d'AVD n'est qualifié. Commencer les essais
sur téléphones physiques et conserver au plus un AVD simultané en usage courant.
Les campagnes à six clients peuvent utiliser les téléphones ; elles n'exigent
pas six AVD. Aucun processus n'a été fermé ni réglage système changé.

## NON DISPONIBLE ACTUELLEMENT — appareils et iOS

Plusieurs téléphones Android physiques sont disponibles selon confirmation
humaine. Aucun téléphone n'a été recherché ou interrogé pendant cet inventaire.

| Identifiant | Fabricant/modèle | Android | API | Usage LOT 0 |
|---|---|---|---|---|
| ANDROID_P01 | À compléter | À compléter | À compléter | Maître/joueur à affecter |
| ANDROID_P02 | À compléter | À compléter | À compléter | Maître/joueur à affecter |
| ANDROID_P03+ | À compléter selon parc réel | À compléter | À compléter | Clients complémentaires |

Identifiants internes proposés, sans numéro de série. Après installation
d'adb et connexion volontaire des appareils, l'inventaire pourra être automatisé.
Les modèles manquants ne bloquent pas l'installation des outils.

Aucun iPhone ni Mac local. Windows ne fournit pas une chaîne native iOS
locale. Le début Android du LOT 0 n'est pas bloqué ; la validation matérielle
iOS sur le LAN réel reste requise avant validation finale de la stack.

### Shortlist iOS à étudier au premier besoin concret

- Priorité : BrowserStack App Live / Real Device Cloud, Corellium,
  TestingBot, Sauce Labs.
- Secondaire : AWS Device Farm, Firebase Test Lab, SmartBear BitBar,
  Perfecto, HeadSpin, Appetize.io.
- Structurel : Mac/Xcode distant ou cloud conforme aux licences Apple,
  iPhone physique local ultérieur.
- Exclus : iPadian, Air iPhone, VM macOS sur matériel Windows non Apple.

La liste est une demande d'étude, pas une qualification des offres.
Évaluer séparément : A compilation iOS ; B exécution de notre app ; C protocole
IP/WebSocket ; D accès éventuel au maître Android local via tunnel ; E permissions
et comportements iOS ; F Bonjour/mDNS sur LAN réel ; G hotspot, changements
de réseau et background réel. Ajouter compatibilité des deux stacks, versions,
coût, automatisation, caméra/QR, audio et limites matérielles.
Un tunnel ou un service cloud ne vaut pas, par défaut, un iPhone sur le LAN.
Aucune étude commerciale exhaustive ni solution retenue à cette étape.

## BASELINE RETENUE — préparation, versions officielles vérifiées

| Élément | Référence constatée au 13 septembre 2026 |
|---|---|
| Android de test | Android 17 / API 37 |
| Android Studio stable | Quail 4 / 2026.1.4 |
| Android Emulator stable | 37.1.11 |
| AVD | Image téléphone API 37 stable x86_64, ≥ 4 Go RAM ; révision exacte à consigner au téléchargement |
| iOS de comparaison | Branche stable 26.x ; Xcode 26.6 avec SDK iOS 26.5 comme référence observée, pas installation locale |
| iOS/Xcode exclus du départ stable | Xcode 27 RC / SDK iOS 27 |

Sources : [Studio stable](https://developer.android.com/studio/releases),
[Android 17](https://developer.android.com/about/versions/17),
[Emulator stable et RAM API 37](https://developer.android.com/studio/releases/emulator),
[table Xcode/SDK Apple](https://developer.apple.com/xcode/system-requirements).
Revérifier le canal stable et consigner les révisions réellement installées.
Pas de Canary/Beta/Preview en remplacement silencieux d'une version stable.

### Compatibilité Flutter

Windows x64, Git et l'éditeur sont présents. Le SDK Flutter stable fournit
les commandes Flutter/Dart ; aucun Dart indépendant nécessaire. Choisir un
chemin local sans espaces/caractères spéciaux ni élévation requise.
[Installation officielle](https://docs.flutter.dev/install/manual).

Le guide Android Flutter consulté demande Studio stable, SDK API 36,
Build-Tools, Command-line Tools, Platform-Tools, Emulator, CMake et NDK.
L'API 37 du banc est une version d'exécution ; ne pas la confondre avec
compileSdk/targetSdk ou imposer leur changement. Prévoir API 36 pour la
chaîne documentée en plus de l'image de test API 37 ; versions NDK/Build-Tools
à accorder au Flutter stable effectivement installé.
[Configuration Android Flutter](https://docs.flutter.dev/platform-integration/android/setup).

Flutter privilégie le Java fourni avec Studio ; en son absence JAVA_HOME
puis PATH interviennent. Ne pas modifier le JDK 21 global maintenant ;
contrôler le JDK réellement retenu avec doctor lors de l'installation.
La compatibilité Java/Gradle/AGP dépend du futur projet : aucune combinaison
n'est validée par la seule présence de Java.
[Documentation Java Flutter](https://docs.flutter.dev/release/breaking-changes/android-java-gradle-migration-guide).

Stockage : le seuil Studio/Emulator ne couvre pas tous les SDK, Flutter,
caches et snapshots. Réserver à titre de planification locale 40–60 Gio
pour le banc initial, à ajuster aux tailles téléchargées ; ce n'est pas un
minimum officiel Flutter. Avec 97,2 Gio libres, l'installation limitée est
envisageable ; éviter plusieurs images redondantes. Aucun besoin de chaîne
Windows desktop C++ dans le périmètre Android initial.

### Compatibilité React Native — PLUS TARD

Le guide Windows demande Node ≥ 22.11.0, recommande Node LTS et JDK 17,
et avertit sur les JDK supérieurs. Node 22.16.0 satisfait ce minimum ; le
Temurin 21 présent diffère du JDK conseillé, sans démontrer à lui seul une
incompatibilité. Le guide cite Studio, Platform 35, Build-Tools 36.0.0 et
Command-line Tools. Ne pas ajouter cette chaîne maintenant : vérifier la
version RN effectivement expérimentée si la comparaison est décidée.
[Prérequis React Native](https://reactnative.dev/docs/set-up-your-environment).

Flutter reste candidat expérimental nº 1, React Native finaliste. Après le
POC Flutter, décision humaine sur la nécessité de comparer RN ; aucune stack
produit n'est choisie ici.

## À INSTALLER — ordre proposé, aucune exécution

1. **Obligatoire** : Flutter SDK stable Windows x64 (Dart inclus), dans un
   répertoire local adapté sur C: ; configurer son PATH lors de l'étape autorisée.
   Conserver Git/VS Code déjà présents.
2. **Obligatoire** : Android Studio Quail 4 stable avec son runtime Java.
3. **Obligatoire** : SDK Command-line Tools, Platform-Tools (adb), Platform
   API 36 demandée par le guide Flutter et Build-Tools compatibles ; NDK/CMake
   selon cette configuration officielle, sans multiplier leurs versions.
4. **Validation de la chaîne** : examiner/accepter les licences Android,
   vérifier doctor et le Java sélectionné ; pilote USB constructeur seulement
   si nécessaire au téléphone volontairement connecté. Rien n'est exécuté ici.
5. **Utile immédiatement au banc AVD** : après autorisation distincte de
   modifier Windows, activer Windows Hypervisor Platform et redémarrer si requis.
   Cette étape ne bloque pas les premiers essais sur appareils physiques.
6. **Utile immédiatement** : Emulator stable 37.1.11, une image stable API 37
   x86_64 et un AVD ≥ 4 Go ; contrôler l'accélération et le GPU. Conserver
   un AVD simultané maximum en usage courant ; avant chaque campagne AVD,
   alléger les applications utilisateur inutiles et mesurer la RAM disponible.
7. **Utile immédiatement** : extension Flutter/Dart de l'éditeur choisi,
   si absente, puis diagnostics appareils et connexion AVD/LAN.

**Plus tard** : chaîne React Native et éventuel JDK 17 dédié, moyens iOS,
outils de charge/automatisation supplémentaires. Aucun Gradle global ou
écosystème parallèle ajouté par défaut. Les noms de paquets/révisions seront
consignés avant téléchargement dans le plan d'installation exécutable.

## À VÉRIFIER — vrais obstacles et limites

- Avant usage WHPX : fonctionnalité aujourd'hui désactivée ; activation future
  soumise à autorisation et contrôle, sans toucher au BIOS sur simple lecture CIM.
- Avant essai AVD : libérer une marge mémoire dans la session de travail,
  qualifier le GPU et l'accélération ; 4/6 AVD sont déconseillés sur ce poste.
- Avant installation : choisir les chemins sur C:, revérifier espace libre,
  canal stable et compatibilité des révisions SDK/Flutter.
- Aucun obstacle matériel identifié à l'installation limitée Flutter/Android
  et au démarrage sur téléphones physiques. GPU/AVD non qualifiés n'impliquent
  pas un blocage de ce parcours.
- iOS indisponible bloque les validations iOS finales, pas le début Android.

Aucun benchmark ni build n'a été lancé. Cet inventaire n'est pas une preuve
de passage du LOT 0. Voir [LOT0_PREPARATION.md](../architecture/LOT0_PREPARATION.md)
pour les conventions, oracles et campagnes à respecter.
