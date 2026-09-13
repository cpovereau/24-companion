# ADR-0003 --- Correspondance entre capacités autorisées et permissions système

-   **Statut** : ACTÉ --- validé par décision humaine le 13 septembre 2026
-   **Contexte** : LOT 0 --- mise en œuvre de l'ADR-0002, avant la tranche T4
-   **Complète** : [ADR-0002](ADR-0002-player-client-privacy.md), sans le modifier

## Contexte

L'ADR-0002 autorise quatre **capacités** pour le client joueur : caméra
pour les QR, réseau local, stockage privé et sortie audio. Il interdit les
accès personnels et exige qu'une nouvelle permission fasse l'objet d'une
décision explicite, contrôlée par allowlist sur l'artefact final.

Les systèmes ne raisonnent pas en capacités mais en **noms de permissions
et de clés** qui ne leur correspondent pas un pour un :

-   sur Android, toute connexion réseau, même locale, exige `INTERNET` ;
-   depuis Android 17, les applications ciblant l'API 37 doivent aussi
    déclarer et demander `ACCESS_LOCAL_NETWORK` (permission dangereuse, groupe
    « Appareils à proximité ») pour tout trafic local : connexions TCP
    sortantes et entrantes, UDP, mDNS. En dessous de l'API 37, `INTERNET`
    accorde implicitement cet accès, à titre transitoire ;
-   sur iOS, le réseau local et Bonjour reposent sur des clés
    `Info.plist` (`NSLocalNetworkUsageDescription`, `NSBonjourServices`) ;
-   des dépendances peuvent ajouter des permissions de manière transitive.

Le build release du socle T0 (13 septembre 2026, `targetSdk` 36) ne
déclare **aucune permission système**. Seule y figure une permission de
signature interne créée par AndroidX.

L'application est un **codebase commun à deux rôles** (recommandation à
tester). Les permissions déclarées dans l'artefact s'appliquent donc au
joueur, même si une fonction ne sert qu'au maître.

## Décision

### 1. Statuts

Chaque permission, clé ou entitlement relève d'un seul statut :

| Statut | Signification |
|---|---|
| **AUTORISÉE — OBSERVÉE** | Présente dans l'artefact et dans l'allowlist |
| **AUTORISÉE — CONDITIONNELLE** | Correspond à une capacité de l'ADR-0002. Ajoutée **uniquement** lorsque la fonction indiquée l'introduit, après observation dans l'artefact. L'allowlist est mise à jour avec un renvoi à la ligne de cet ADR, sans nouvel ADR |
| **INTERDITE** | Contraire à l'ADR-0002 ; aucune dépendance ou fonction ne peut l'introduire |
| **HORS TABLE** | Non couverte : exige un amendement de cet ADR, validé humainement, avant tout ajout |

Une permission absente des tables ci-dessous est **HORS TABLE** par défaut.

### 2. Android

| Réf. | Capacité | Permission | Protection | Statut | Condition |
|---|---|---|---|---|---|
| A1 | Technique interne | `${applicationId}.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (déclarée et utilisée) | signature, propre à l'application | AUTORISÉE — OBSERVÉE | Introduite par AndroidX ; aucun accès au téléphone |
| A2 | Réseau local | `android.permission.INTERNET` | normale | AUTORISÉE — CONDITIONNELLE | Premier échange réseau de session (T4). Aucun trafic vers Internet pendant une partie (ADR-0001) ; aucun appel à un service tiers (ADR-0002) |
| A3 | Réseau local | `android.permission.ACCESS_LOCAL_NETWORK` | dangereuse, groupe NEARBY_DEVICES | AUTORISÉE — CONDITIONNELLE | Obligatoire dès que `targetSdk` ≥ 37. Demandée au premier besoin : publication de session (maître), rejoindre une session (joueur) |
| A4 | Réseau local | `android.permission.ACCESS_NETWORK_STATE` | normale | AUTORISÉE — CONDITIONNELLE | Seulement si la détection des changements de réseau (T4, T5) ou la solution de découverte retenue l'exige |
| A5 | Réseau local | `android.permission.CHANGE_WIFI_MULTICAST_STATE` | normale | AUTORISÉE — CONDITIONNELLE | Seulement pour un mDNS applicatif en multicast (T5), pas avec `NsdManager` |
| A6 | Caméra QR | `android.permission.CAMERA` | dangereuse | AUTORISÉE — CONDITIONNELLE | Scan QR (T7), demandée au premier scan |
| A7 | Sortie audio | aucune | --- | --- | Lecture des sons de 24 sans permission |
| A8 | Stockage privé | aucune | --- | --- | Stockage interne de l'application ; import maître via sélecteur système, sans accès global |

**INTERDITES** (ADR-0002) :

-   microphone : `RECORD_AUDIO` ;
-   contacts et comptes : `READ_CONTACTS`, `WRITE_CONTACTS`, `GET_ACCOUNTS` ;
-   SMS et messages : `READ_SMS`, `SEND_SMS`, `RECEIVE_SMS`, `RECEIVE_MMS`,
    `RECEIVE_WAP_PUSH` ;
-   appels et identifiants de téléphonie : `READ_CALL_LOG`,
    `WRITE_CALL_LOG`, `PROCESS_OUTGOING_CALLS`, `READ_PHONE_STATE`,
    `READ_PHONE_NUMBERS` ;
-   photos, vidéos, audio et fichiers personnels : `READ_EXTERNAL_STORAGE`,
    `WRITE_EXTERNAL_STORAGE`, `MANAGE_EXTERNAL_STORAGE`,
    `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`,
    `READ_MEDIA_VISUAL_USER_SELECTED`, `ACCESS_MEDIA_LOCATION` ;
-   calendrier : `READ_CALENDAR`, `WRITE_CALENDAR` ;
-   localisation : `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`,
    `ACCESS_BACKGROUND_LOCATION` ;
-   données des autres applications : `QUERY_ALL_PACKAGES`,
    `PACKAGE_USAGE_STATS` ;
-   publicité et tracking : `com.google.android.gms.permission.AD_ID`.

**HORS TABLE notables** (amendement requis avant ajout) :
`FOREGROUND_SERVICE` et ses types (`FOREGROUND_SERVICE_MEDIA_PLAYBACK`,
`FOREGROUND_SERVICE_CONNECTED_DEVICE`…), `POST_NOTIFICATIONS`, `WAKE_LOCK`,
`NEARBY_WIFI_DEVICES`, `ACCESS_WIFI_STATE`, `BLUETOOTH_*`, `VIBRATE`,
`RECEIVE_BOOT_COMPLETED`.

### 3. iOS

| Réf. | Capacité | Clé ou entitlement | Statut | Condition |
|---|---|---|---|---|
| I1 | Réseau local | `NSLocalNetworkUsageDescription` (invite système) | AUTORISÉE — CONDITIONNELLE | Premier échange réseau local (T4) ; texte expliquant l'usage limité à la session |
| I2 | Réseau local | `NSBonjourServices` | AUTORISÉE — CONDITIONNELLE | Découverte (T5) ; liste limitée aux types de service propres à 24 (nom provisoire à fixer) |
| I3 | Caméra QR | `NSCameraUsageDescription` | AUTORISÉE — CONDITIONNELLE | Scan QR (T7), demandée au premier scan |
| I4 | Sortie audio | aucune clé pour la lecture au premier plan | --- | --- |
| I5 | Stockage privé | aucune | --- | Conteneur de l'application ; import via sélecteur système |

**INTERDITES** : `NSMicrophoneUsageDescription`,
`NSContactsUsageDescription`, `NSPhotoLibraryUsageDescription`,
`NSPhotoLibraryAddUsageDescription`, `NSAppleMusicUsageDescription`,
`NSCalendarsUsageDescription`, `NSCalendarsFullAccessUsageDescription`,
`NSCalendarsWriteOnlyAccessUsageDescription`,
`NSLocationWhenInUseUsageDescription`,
`NSLocationAlwaysAndWhenInUseUsageDescription`,
`NSLocationAlwaysUsageDescription`, `NSUserTrackingUsageDescription`.
La **présence** d'une de ces clés dans l'artefact est un échec, même si
l'API n'est pas appelée.

**HORS TABLE notables** : entitlement
`com.apple.developer.networking.multicast`, `UIBackgroundModes` (dont
`audio`), `NSBluetoothAlwaysUsageDescription`, `NSFaceIDUsageDescription`,
`NSMotionUsageDescription`, `NSSpeechRecognitionUsageDescription`,
`NSRemindersUsageDescription`, clés HealthKit.

Le manifeste de confidentialité iOS (`PrivacyInfo.xcprivacy`) déclare
l'absence de tracking ; il est contrôlé avec les clés ci-dessus.

### 4. Demande à l'exécution

-   Les permissions soumises à l'accord de l'utilisateur (A3, A6, I1, I3)
    sont demandées **au premier besoin pertinent**, jamais au démarrage.
-   Un refus produit un état explicite et une explication à l'écran, sans
    contournement ni nouvelle demande insistante.
-   Le texte des invites décrit l'usage propre à 24 : rejoindre ou héberger
    la session, scanner un QR de jeu.

### 5. Binaire commun à deux rôles

La table s'applique à **l'artefact final**, quel que soit le rôle exercé.
Un besoin propre au maître (par exemple service de premier plan, audio en
arrière-plan ou notifications) reste HORS TABLE tant qu'il n'est pas
décidé. S'il se révèle nécessaire et incompatible avec le client joueur,
la question du nombre de binaires, **À ARBITRER** dans
[ARCHITECTURE.md](../architecture/ARCHITECTURE.md), est rouverte plutôt
que d'accorder la permission au joueur par défaut.

### 6. Contrôle et amendement

-   L'allowlist Android (`app/tool/ci/android-permissions.allowlist`) et la
    future allowlist iOS renvoient, pour chaque entrée, à sa référence
    (A1, A2, I1…).
-   Un statut **CONDITIONNELLE** devient **OBSERVÉE** par modification revue
    de l'allowlist, lorsque la fonction indiquée est livrée.
-   Tout ajout **HORS TABLE**, tout changement de statut vers ou depuis
    **INTERDITE** et toute nouvelle ligne passent par un amendement de cet
    ADR, validé humainement et daté.
-   La CI échoue sur toute entrée non listée dans l'allowlist.

## Conséquences

-   `INTERNET` peut être ajoutée en T4 sans nouvel ADR, avec renvoi à A2.
-   Le passage à `targetSdk` 37 ajoute une invite « Appareils à proximité »
    sur les deux rôles. Son effet sur la confiance du joueur devient un
    critère d'observation du LOT 0.
-   Le choix des dépendances de découverte (T5) et de scan QR (T7) est
    contraint par A4, A5, A6, I2 et I3.
-   Un besoin d'arrière-plan maître peut peser sur la décision une ou deux
    applications.

## À TESTER pendant le LOT 0

-   Comportement avec `targetSdk` 37 et `ACCESS_LOCAL_NETWORK` : serveur
    maître en écoute, client joueur, refus puis acceptation, hotspot.
-   Découverte avec le sélecteur système `NsdManager` (`FLAG_SHOW_PICKER`),
    qui peut éviter la permission pour la découverte et la connexion du
    joueur, mais pas les connexions entrantes du maître.
-   Invite réseau local iOS : moment d'apparition, refus, Bonjour réel.
-   Permissions réellement ajoutées par les dépendances candidates.
-   Besoin effectif d'arrière-plan pour le maître (audio et serveur).

## Non décidé par cet ADR

-   `targetSdk` de chaque build du POC et calendrier de passage à l'API 37 ;
-   choix des dépendances réseau, découverte, QR et audio ;
-   nom définitif du type de service Bonjour ;
-   nombre de binaires distribués ;
-   textes définitifs des invites.

## Sources

-   [Local network permission — Android Developers](https://developer.android.com/privacy-and-security/local-network-permission)
-   [Behavior changes: apps targeting Android 17](https://developer.android.com/about/versions/17/behavior-changes-17)
