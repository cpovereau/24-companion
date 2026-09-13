# 24 --- Contexte de développement pour Codex

## Objet de ce fichier

Ce document est la base de travail de Codex pour le projet **24**. Il
fixe les contraintes et décisions d'architecture déjà stabilisées ou
recommandées pendant l'exploration du LOT 0.

Codex doit préserver ces principes lors de toute proposition, génération
de code ou refactorisation. Une solution techniquement élégante qui
contredit un principe **ACTÉ** n'est pas acceptable sans décision
explicite de l'équipe.

## Légende de maturité

-   **ACTÉ** : décision ou invariant à respecter.
-   **RECOMMANDATION** : direction privilégiée à ce stade.
-   **À TESTER** : hypothèse qui doit être validée par prototype.
-   **À ARBITRER** : décision volontairement laissée ouverte.

## Documents de référence

Lire `doc/dev/specifications/APPLICATION_COMPAGNON.md` pour le besoin
fonctionnel, les ADR ACTÉS pour les décisions, `ARCHITECTURE.md` dans
`doc/dev/architecture/` pour la cible exploratoire et
`doc/dev/specifications/LOT0_POC.md` pour les conventions et validations
du POC. Un ADR ACTÉ prévaut sur une recommandation, y compris ici.
Signaler toute contradiction entre sources de même niveau.

Google Drive reste la source humaine de conception ; son accès n'est pas
un prérequis pour le LOT 0. Signaler un besoin métier absent des sources
locales sans le déduire des fichiers `.gdoc` ou `.gsheet`.
**ACTÉ POUR LE LOT 0** désigne une convention expérimentale approuvée,
sans l'étendre à la politique produit définitive.

------------------------------------------------------------------------

## 1. Finalité de l'application compagnon

24 est un jeu dans lequel l'application compagnon automatise les
mécaniques sans devenir le centre de l'attention.

Le smartphone remplace notamment les dés, certains calculs, la
synchronisation et une partie de la circulation d'informations. Le
joueur doit voir les informations utiles à son personnage, les choix qui
lui sont ouverts, le temps et les résultats, mais pas la complexité
interne du moteur.

L'application comporte deux rôles complémentaires :

-   **Maître / MJ** : contrôle de la session, horloge fictive, tension,
    personnages/groupes, résolution, événements, messages, audio et
    informations secrètes.
-   **Joueur** : fiche du personnage, informations narratives
    autorisées, état courant, actions/résolution, messages et lecture de
    QR codes.

Les deux rôles reposent sur **un moteur de règles commun et une session
unique**.

------------------------------------------------------------------------

## 2. Invariants d'architecture

### ACTÉ --- Fonctionnement hors Internet

Une fois la partie démarrée, toutes les fonctions nécessaires au
déroulement normal de la session doivent fonctionner **sans accès
Internet**.

Internet peut être utilisé avant la partie pour :

-   installer ou mettre à jour l'application ;
-   récupérer/importer un scénario ;
-   récupérer les ressources nécessaires.

Le scénario et toutes les ressources nécessaires doivent être présents
localement avant le démarrage.

### ACTÉ --- Autorité unique

Le terminal maître est l'autorité de la session.

Il détient :

-   l'état officiel ;
-   l'horloge fictive officielle ;
-   le package scénario complet ;
-   les événements futurs ;
-   les secrets ;
-   les paramètres cachés ;
-   le moteur de résolution ;
-   la persistance officielle.

Les clients joueurs ne modifient jamais directement l'état officiel.

### ACTÉ --- Architecture logique client/serveur locale

Même si tous les appareils se trouvent dans la même pièce, la session
est conçue comme un système **client/serveur local**, et non comme un
système pair-à-pair symétrique.

Flux conceptuel :

``` text
Client joueur
    |
    | Commande / intention
    v
Maître
    |
    | validation
    | moteur de règles
    | mutation de l'état officiel
    v
Projection filtrée / événement autorisé
    |
    v
Client(s) concerné(s)
```

### ACTÉ --- Une seule horloge fictive

La session possède une seule horloge fictive faisant autorité.

Aucun affichage externe ou client joueur ne constitue une seconde source
de vérité. Un téléphone dédié ou une horloge physique peut afficher
l'heure commune, mais uniquement comme projection de l'état maître.

------------------------------------------------------------------------

## 3. Confidentialité du scénario

### ACTÉ --- Le secret doit être absent du client

La sécurité ne doit pas reposer sur le masquage visuel d'une donnée déjà
envoyée au téléphone du joueur.

**Une information que le joueur ne doit pas connaître ne doit pas être
transférée sur son terminal.**

Le client joueur ne doit notamment jamais recevoir :

-   le package scénario complet ;
-   les événements futurs ;
-   les difficultés réelles cachées ;
-   les paramètres internes de résolution ;
-   les plans ou alternatives des PNJ ;
-   les secrets d'autres personnages ;
-   les messages réservés au MJ ;
-   la base complète des QR ;
-   les conséquences futures non révélées.

Éviter le modèle « objet complet + champs cachés ». Construire
explicitement une projection autorisée.

### Modèle recommandé

``` text
Session officielle
        |
        v
Autorisation / Projection
        |
        v
ClientPlayerView
```

`ClientPlayerView` est un contrat dédié et minimal.

------------------------------------------------------------------------

## 4. Non-intrusion du client joueur

### ACTÉ --- Minimisation stricte

Le client joueur ne doit accéder à **aucun contenu personnel du
téléphone** qui n'est pas strictement nécessaire à 24.

Il ne doit pas demander accès :

-   au microphone ;
-   aux contacts ;
-   aux SMS ou messages ;
-   au journal d'appels ;
-   à la photothèque ;
-   aux vidéos personnelles ;
-   à la bibliothèque musicale ;
-   aux fichiers personnels ;
-   au calendrier ;
-   à la localisation ;
-   aux données des autres applications.

Il ne doit utiliser aucun identifiant matériel du téléphone pour
identifier un joueur.

### Permissions fonctionnelles prévues

Le client peut utiliser :

-   la **caméra**, uniquement pour lire les QR codes ;
-   le **réseau local**, pour communiquer avec le maître ;
-   son **stockage applicatif privé** ;
-   la sortie audio si l'application doit jouer ses propres sons.

La permission caméra doit être demandée au premier besoin pertinent du scanner QR,
et non arbitrairement au démarrage.

La lecture d'un QR doit se faire depuis le flux caméra sans enregistrer
la photo dans la photothèque.

### ACTÉ --- Stockage privé uniquement

Les données du client sont stockées dans le sandbox de 24.

Le client ne doit pas parcourir `Documents`, `Downloads`, `Photos`,
`Music`, `DCIM` ou les espaces d'autres applications.

### ACTÉ --- Dépendances minimales (ADR-0002)

Pour le MVP, par défaut :

-   aucun SDK publicitaire ;
-   aucun tracking comportemental ;
-   aucun SDK analytics tiers.

Le crash reporting tiers reste **À ARBITRER**, non obligatoire et non acté
pour le LOT 0. La gestion des erreurs est néanmoins requise dès le POC.

### ACTÉ --- Allowlist de permissions (ADR-0002)

La CI doit contrôler le **binaire final** et échouer si une permission
ou un entitlement non autorisé apparaît.

Le contrôle doit porter sur le manifeste/artefact produit, pas seulement
sur le code source, car une dépendance peut ajouter des permissions.

Toute nouvelle permission nécessite une décision d'architecture
explicite.

La non-intrusion concerne les contenus personnels du terminal. Elle
n'interdit pas les données internes de 24. Leur confidentialité relève
séparément de l'ADR-0001 : seules les données de jeu autorisées peuvent
être transmises au joueur. Voir l'architecture pour le binaire commun.

------------------------------------------------------------------------

## 5. Réseau local

### RECOMMANDATION actuelle

Base du LOT 0 :

``` text
Wi-Fi IP
+ WebSocket
+ Bonjour/mDNS pour la découverte
+ QR comme mécanisme de connexion/fallback
```

Le maître héberge le service local de session.

L'adresse IP n'est pas l'identité du maître. La session doit pouvoir
retrouver le même hôte après un changement d'adresse.

### Réseaux physiques

Ordre de préférence actuel :

1.  Wi-Fi local commun ;
2.  petit routeur Wi-Fi dédié sans Internet comme solution robuste ;
3.  hotspot Android à tester ;
4.  hotspot iPhone à tester ;
5.  technologies P2P spécifiques comme pistes secondaires.

Ne pas baser le LOT 0 sur Bluetooth ou une technologie P2P spécifique à
un seul OS.

------------------------------------------------------------------------

## 6. Synchronisation et reprise

### RECOMMANDATION

Le maître utilise :

-   une base transactionnelle locale, probablement SQLite ;
-   un journal append-only d'événements de domaine séquencés.

Une commande possède un `commandId` unique afin de permettre la
déduplication.

Un événement possède au minimum un identifiant et un numéro de séquence.

Le client conserve au minimum :

``` text
sessionId
clientId
characterId
authToken
lastReceivedSequence
```

Lors d'une reconnexion, le maître :

1.  authentifie le client ;
2.  lit son dernier numéro de séquence ;
3.  rejoue les événements autorisés si possible ;
4.  sinon envoie un snapshot filtré ;
5.  reprend ensuite le flux normal.

Le protocole détaillé n'est **pas encore acté**. Ne pas figer
prématurément les formats `Command`, `Event`, `Snapshot` et `Ack`.

------------------------------------------------------------------------

## 7. Persistance et incident maître

### RECOMMANDATION

Chaque commande validée doit produire atomiquement :

1.  validation ;
2.  mutation de l'état officiel ;
3.  événement(s) de domaine ;
4.  nouveau numéro de séquence ;
5.  commit.

### Horloge après crash --- statuts distincts

**ACTÉ** : aucune progression silencieuse de l'horloge après interruption.
**ACTÉ POUR LE LOT 0** : dernière heure persistée, récupération en pause
(`RECOVERY_PAUSED`, nom provisoire), puis reprise explicite du MJ.
La politique produit définitive et un éventuel ajustement explicite par
le MJ restent **À ARBITRER PLUS TARD**. Voir `LOT0_POC.md` pour les tests.

------------------------------------------------------------------------

## 8. Package scénario

### RECOMMANDATION

Distinguer le format d'édition du scénario du package d'exécution.

Extension de travail :

``` text
.24scenario
```

Archive conceptuelle :

``` text
manifest.json
scenario.json
characters/
actions/
events/
objects/
messages/
qr/mappings.json
assets/audio/
assets/images/
checksums.json
```

Le manifeste doit permettre au minimum :

``` text
packageFormat
scenarioId
scenarioVersion
minimumAppVersion
minimumEngineVersion
contentRevision / digest
assets
```

Une session est épinglée sur :

``` text
scenarioId
scenarioVersion
packageDigest
```

Ne jamais mettre à jour silencieusement un scénario pendant une session.

### OFFLINE_READY

Avant le démarrage, le maître doit pouvoir vérifier :

-   manifeste ;
-   version et compatibilité ;
-   schémas ;
-   références internes ;
-   personnages ;
-   actions/tables ;
-   événements ;
-   mappings QR ;
-   présence et intégrité des assets ;
-   espace local nécessaire.

------------------------------------------------------------------------

## 9. Personnages

La distinction des dimensions fonctionnelles est **ACTÉE** ; elle ne
prescrit pas les structures logicielles ci-dessous. Voir la référence
fonctionnelle, section 7.

### RECOMMANDATION

Séparer trois concepts :

``` text
CharacterTemplate
    -> CharacterProfile
        -> SessionCharacter
```

`CharacterTemplate` : définition issue du scénario/archetype.

`CharacterProfile` : identité personnalisable et éventuelle progression
persistante.

`SessionCharacter` : état du personnage dans une session précise.

La progression entre scénarios reste **À ARBITRER**.

Les jauges courantes incluent notamment Constitution, Endurance et
Sang-froid.

------------------------------------------------------------------------

## 10. QR codes

### ACTÉ --- QR de jeu

Un QR de jeu est un **identifiant**, pas un conteneur de secret de jeu.

Il ne doit jamais encoder la réponse secrète ou la conséquence cachée.

Le maître résout l'identifiant à partir du scénario et de l'état
officiel.

Exemples conceptuels :

``` text
CHAR:ARCHETYPE:ENQUETEUR:001
CARD:PERSONAL:SECOND_SOUFFLE:V1
```

La syntaxe définitive reste **À ARBITRER**.

Le QR d'enrôlement/connexion sert à rejoindre une session et peut contenir
une donnée d'authentification temporaire. Ce n'est pas une réponse secrète
de jeu. Son format et sa sécurité restent à concevoir ; voir l'architecture.

------------------------------------------------------------------------

## 11. Distribution

### RECOMMANDATION LOT 0

-   Android : APK direct pour le développement, puis pistes de test
    Google Play.
-   iOS : TestFlight.
-   Production : stores officiels.

Une installation ou mise à jour peut nécessiter Internet. Une partie
déjà préparée ne doit pas en dépendre.

------------------------------------------------------------------------

## 12. Choix technologique

### À ARBITRER

La technologie mobile n'est pas encore choisie.

Finalistes actuels :

-   Flutter ;
-   React Native.

Flutter est actuellement le candidat n°1 à prototyper, mais **ce n'est
pas une décision**.

PWA est considérée comme mal adaptée au rôle maître si celui-ci doit
héberger un serveur LAN fiable.

Le natif Swift/Kotlin reste un fallback si les solutions cross-platform
rencontrent un blocage structurel.

### Critères de sélection

Évaluer notamment :

-   serveur local embarqué ;
-   fiabilité iOS ;
-   fiabilité Android ;
-   WebSocket ;
-   Bonjour/mDNS ;
-   reconnexion ;
-   QR ;
-   audio ;
-   comportement en arrière-plan ;
-   persistance ;
-   quantité de code natif spécifique ;
-   partage de code maître/joueur ;
-   testabilité du domaine ;
-   maintenabilité ;
-   simplicité de travail avec Codex ;
-   permissions réellement présentes dans le build final.

------------------------------------------------------------------------

## 13. Une application ou deux

### RECOMMANDATION actuelle

Pour LOT 0/MVP :

-   **un codebase** ;
-   probablement **une application distribuée** ;
-   deux rôles d'exécution : maître et joueur.

La présence du code du moteur dans le binaire joueur n'est pas
considérée comme une fuite de scénario si aucune donnée secrète de la
session n'est présente.

La séparation future en `24 Maître` et `24 Joueur` reste **À ARBITRER**.

------------------------------------------------------------------------

## 14. Règles de développement pour Codex

Lorsqu'il travaille sur ce dépôt, Codex doit :

1.  préserver les invariants **ACTÉS** ;
2.  signaler explicitement toute proposition qui les remet en cause ;
3.  ne pas transformer une **RECOMMANDATION** en décision implicite ;
4.  marquer les hypothèses techniques non vérifiées comme **À TESTER** ;
5.  éviter les abstractions distribuées inutiles : le maître est
    l'autorité ;
6.  ne jamais répliquer le scénario complet vers les clients ;
7.  utiliser des DTO/projections joueurs explicitement minimaux ;
8.  considérer la reconnexion, l'idempotence et la persistance dès la
    conception ;
9.  maintenir le fonctionnement sans Internet comme critère de test ;
10. maintenir la non-intrusion du client comme critère de test ;
11. éviter toute dépendance ajoutant des permissions inutiles ;
12. privilégier un domaine testable indépendamment de l'UI et du réseau
    ;
13. demander/arbitrer avant de figer une décision marquée **À
    ARBITRER**.

Quand plusieurs solutions sont possibles, produire les compromis avant
d'engager une modification structurante.

Le LOT 0 utilise des mécaniques artificielles déterministes : il ne valide
pas le moteur réel de 24. Ses arbitrages humains (sécurité dès le POC,
récupération, cinq tentatives automatiques au maximum, matrice matérielle,
acceptation et diagnostic) sont consignés dans `LOT0_POC.md` ; ne pas les
remplacer par des hypothèses moins exigeantes.

------------------------------------------------------------------------

## 15. Poste de développement local et émulateur

L'environnement réellement installé et ses limites sont consignés dans
`doc/dev/operations/DEV_ENVIRONMENT.md`. Sur le poste actuel (16 Gio),
**1 AVD simultané est VIABLE MAIS CONTRAIGNANT** : privilégier le téléphone
Android physique pour les cycles de build et de lancement.

Avant de lancer l'émulateur, la session doit être allégée avec le script
local, **non versionné** car propre au poste :

``` text
C:\dev\scripts\prepare-avd-session.ps1
```

Règles :

1.  ne l'exécuter réellement qu'avec l'accord explicite de l'utilisateur :
    il ferme des applications et arrête des services ;
2.  commencer par `-WhatIf` pour présenter ce qui serait arrêté ;
3.  ne pas modifier les types de démarrage ni fermer VS Code, Codex,
    Android Studio, les protections Windows ou Hyper-V/WHP ;
4.  ne pas ajouter ce script, ses noms de services ni d'autres données
    propres au poste dans ce dépôt public ;
5.  arrêter le daemon Gradle après un build lorsqu'un AVD est lancé.
