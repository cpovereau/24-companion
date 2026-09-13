# 24 --- Architecture cible exploratoire du LOT 0

> Statut : document de travail. Il décrit la cible actuellement
> recommandée afin de permettre les prototypes. Il ne transforme pas les
> choix technologiques encore ouverts en décisions définitives.

La [référence fonctionnelle](../specifications/APPLICATION_COMPAGNON.md)
décrit le besoin. Les [ADR ACTÉS](../decisions/) prévalent sur les
recommandations. Les arbitrages humains **ACTÉS POUR LE LOT 0** sont
consignés dans [LOT0_POC.md](../specifications/LOT0_POC.md) ; leur portée
expérimentale n'acte pas une politique produit définitive.

## 1. Topologie

``` text
┌─────────────────────────────────────────────┐
│                  MAÎTRE                     │
│                                             │
│  UI MJ                                      │
│  Moteur métier / résolution                 │
│  Horloge fictive autoritaire                │
│  Scheduler                                  │
│  Package scénario COMPLET                   │
│  Base locale autoritaire                    │
│  Journal d'événements                       │
│  Projection / filtrage par joueur           │
│  Serveur local de session                   │
└───────────────────┬─────────────────────────┘
                    │
          LAN / protocole de session
                    │
        ┌───────────┼────────────┐
        v           v            v
   Joueur P1    Joueur P2    Affichage
   vue P1       vue P2       horloge
   filtrée      filtrée      lecture seule
```

Le système est local-first et master-authoritative.

## 2. Frontières de responsabilité

### Maître

Responsable de :

-   création/reprise de session ;
-   package scénario complet ;
-   validation OFFLINE_READY ;
-   moteur de résolution ;
-   état officiel ;
-   horloge fictive ;
-   planification des événements ;
-   autorisations ;
-   projections joueurs ;
-   association appareil/joueur/personnage ;
-   journal et persistance ;
-   serveur réseau local ;
-   déduplication des commandes ;
-   resynchronisation des clients.

### Joueur

Responsable de :

-   interface du personnage ;
-   saisie des intentions/commandes ;
-   affichage de `ClientPlayerView` ;
-   messages 24 autorisés ;
-   scan QR ;
-   cache local minimal ;
-   mémorisation de la progression de synchronisation ;
-   reconnexion.

Le joueur n'est jamais autorité sur l'état de session.

## 3. Modèle de données initial

``` text
ScenarioPackage
  Manifest
  ScenarioDefinition
  CharacterTemplate[]
  ActionDefinition[]
  EventDefinition[]
  ObjectDefinition[]
  MessageDefinition[]
  QrMapping[]
  AssetManifest[]

Session
  id
  scenarioId
  scenarioVersion
  packageDigest
  status
  fictionalClock
  tension
  characters[]
  groups[]
  activeActions[]
  lastEventSequence

CharacterTemplate
  id
  archetype
  characteristics
  knowHow
  backgroundTemplate
  scenarioSecrets
  objectives
  startingState

CharacterProfile
  id
  chosenName
  chosenSex
  experience
  persistentProgression
  scars
  unlockedHistory

SessionCharacter
  id
  templateId
  profileId
  playerId
  gauges
  groupId
  availability
  currentAction
  sessionSecrets

ClientPlayerView
  sessionId
  character
  knownInformation[]
  availableActions[]
  messages[]
  publicSessionState
  revision

ActionExecution
  id
  definitionId
  actors[]
  targetId
  requestedTimeBudget
  secretResolutionState
  createdAt
  completionDeadline
  status
  result

DomainEvent
  id
  sequence
  fictionalTime
  type
  visibility
  payload

Message
  id
  source
  recipients
  fictionalTime
  type
  content
  status

QrMapping
  schemeVersion
  codeId
  entityType
  entityId
  ruleVersion

Asset
  id
  type
  path
  hash
  requiredOffline
```

Ces structures sont un point de départ, pas encore un schéma de
sérialisation figé.

**ACTÉ fonctionnellement** : caractéristiques/aptitude naturelle,
savoir-faire, expérience et état actuel ne sont pas interchangeables.
Cette distinction ne prescrit pas les structures `CharacterTemplate`,
`CharacterProfile` et `SessionCharacter`, qui restent **RECOMMANDÉES /
EXPLORATOIRES**. Leurs champs de progression ne décident pas sa persistance
entre scénarios.

`ClientPlayerView.character`, ses actions et les autres champs sont des
projections minimales explicites ; ils ne réutilisent pas les objets
complets du domaine contenant des secrets.

## 4. Persistance maître

Cible recommandée :

``` text
SQLite
  +
transactions
  +
journal d'événements séquencés
```

Éviter pour le MVP un event sourcing complet si ses bénéfices ne sont
pas démontrés.

Tables conceptuelles minimales :

``` text
sessions
characters
action_executions
events
messages
device_bindings
used_qr_items
event_log
```

`event_log` contient conceptuellement :

``` text
sequence
eventId
type
payload
createdAt
```

## 5. Cycle d'une commande

``` text
commande joueur
     |
     v
authentification
     |
     v
validation
     |
     v
déduplication commandId
     |
     v
moteur de domaine
     |
     v
mutation état officiel
     |
     v
événement(s) de domaine + sequence
     |
     v
COMMIT
     |
     v
projection par destinataire
     |
     v
diffusion
```

L'enregistrement officiel doit précéder la considération d'une commande
comme acquise.

## 6. Reconnexion

Le protocole précis reste à concevoir, mais doit permettre :

``` text
RESUME
  sessionId
  clientId
  authToken
  lastReceivedSequence
```

Réponse maître :

``` text
si journal suffisant :
    replay des événements autorisés
sinon :
    snapshot filtré
puis :
    reprise du flux
```

Les commandes doivent être idempotentes vis-à-vis d'une retransmission.

**ACTÉ POUR LE LOT 0** : cinq tentatives automatiques au maximum ; la
réussite inclut réauthentification et resynchronisation complète, pas le
seul retour du socket. Le comportement après échec et les mesures sont
définis dans le plan de POC. Temporisations, jetons, séquences et curseurs
restent à concevoir, sans figer les contrats définitifs.

**ACTÉ** : aucun avancement silencieux de l'horloge après incident maître.
**ACTÉ POUR LE LOT 0** : dernière heure persistée, état de récupération en
pause (`RECOVERY_PAUSED`, nom provisoire), puis reprise explicite MJ.
La politique produit complète reste **À ARBITRER PLUS TARD** ; l'éventuel
ajustement temporel décidé par le MJ n'est pas spécifié ici.

## 7. Découverte et connexion

Le QR de jeu identifie un élément et ne contient pas de réponse ou de
conséquence secrète. Le QR d'enrôlement ci-dessous sert à rejoindre la
session : une donnée d'authentification temporaire n'est pas un secret de
jeu et ne contrevient pas à cette règle.

Cible LOT 0 :

``` text
Wi-Fi IP
WebSocket
Bonjour/mDNS
QR de connexion
```

Le QR de connexion peut transporter les informations minimales
permettant l'enrôlement, mais son format et sa signature ne sont pas
encore décidés.

Une proposition de contenu conceptuel :

``` text
protocolVersion
sessionId
host/port ou donnée de découverte
enrollmentToken
```

L'`enrollmentToken` devrait être aléatoire, temporaire et idéalement à
usage unique.

## 8. Identités

Ne pas confondre :

``` text
device/client
player
character
session
```

Le client doit utiliser un identifiant aléatoire généré par 24, pas un
identifiant matériel du téléphone.

Association conceptuelle :

``` text
sessionId
  + clientId
  + playerId
  + characterId
  + authToken
```

## 9. Sécurité par projection

Exemple :

``` text
Session complète
  ├── secret P1
  ├── secret P2
  ├── événements futurs
  ├── difficultés réelles
  ├── état MJ
  └── état public
          |
          v
Projection pour P1
          |
          ├── état public autorisé
          ├── secret P1 déjà connu
          ├── actions autorisées P1
          └── messages P1
```

Le code de projection constitue une frontière de sécurité et doit avoir
des tests dédiés.

**ACTÉ POUR LE LOT 0 — périmètre de sécurité** : authentification du maître,
authentification/autorisation des clients, protection du transport local
adaptée à la menace étudiée, contrôle des destinataires et filtrage.
Un client non autorisé ne doit obtenir ni les données d'un autre personnage
ni les secrets maître. Le mécanisme et la menace précise seront définis
pendant la préparation technique ; la sécurité n'est pas reportée après
le POC. Seuls le durcissement et l'industrialisation de production le sont.

## 10. Privacy / permissions

Le client joueur doit rester minimal :

``` text
CAMÉRA QR       autorisée si nécessaire
RÉSEAU LOCAL    autorisé
SANDBOX 24      autorisé
SORTIE AUDIO    autorisée pour les sons de 24 si nécessaire

MICROPHONE      interdit
CONTACTS        interdit
MESSAGES/SMS    interdit
PHOTOS          interdit
MÉDIAS PERSO    interdits
FICHIERS USER   interdit
CALENDRIER      interdit
LOCALISATION    interdite
```

Toute dépendance mobile doit être évaluée aussi sur les permissions
qu'elle introduit dans le binaire final.

L'[ADR-0002](../decisions/ADR-0002-player-client-privacy.md) fait autorité
pour la liste complète des interdictions, la caméra au premier besoin
pertinent sans Photos, le sandbox, les dépendances et l'allowlist CI sur
les artefacts finaux iOS/Android. Ces exigences sont **ACTÉES**.
L'[ADR-0003](../decisions/ADR-0003-permission-mapping.md) (**ACTÉ**) fixe
les permissions et clés concrètes correspondant à chaque capacité, dont
`ACCESS_LOCAL_NETWORK` pour les builds Android ciblant l'API 37.

### Deux frontières indépendantes et rôles

La non-intrusion protège les contenus personnels du téléphone. La
confidentialité du jeu (ADR-0001) protège les données 24 non autorisées.
Les échanges de session, personnage, messages 24, QR, projections, assets
autorisés et synchronisation sont légitimes.

**RECOMMANDATION / À TESTER** : un codebase commun, probablement une
application à deux rôles. Distinguer :

- présence de code : moteur et import maître de données 24 ne constituent
  pas à eux seuls une intrusion ou une fuite ;
- permissions OS déclarées : le binaire reste soumis à l'ADR-0002, même
  si une fonction n'est pas visible dans l'interface joueur ;
- accès effectifs : aucun accès personnel interdit ne devient légitime
  du fait du rôle ;
- données présentes : le client joueur ne reçoit aucun secret de jeu non
  autorisé. Les éventuels changements de rôle et données conservées sont
  à examiner si ce parcours entre dans le POC, sans fixer sa politique ici.

Le procédé d'import maître et la conformité du binaire seront mesurés ;
manipuler un package propre à 24 n'autorise pas à parcourir les fichiers
personnels. Le nombre définitif de binaires reste **À ARBITRER**.

### Diagnostic du POC

La gestion des erreurs est requise dès le LOT 0 ; voir son plan pour les
catégories à diagnostiquer. Une journalisation locale maîtrisée est
**RECOMMANDÉE**, sans collecte personnelle ni envoi de secret de scénario
à un tiers. Le crash reporting tiers reste non obligatoire et non acté.

## 11. Background

Ne pas supposer qu'un OS mobile autorise le maître à continuer
indéfiniment son serveur local lorsque l'application est en arrière-plan
ou l'écran verrouillé.

Hypothèse MVP à tester :

-   maître en premier plan pendant la partie ;
-   écran maintenu éveillé ;
-   verrouillage automatique empêché pendant une session active.

Audio + serveur + passage temporaire en arrière-plan est un test
obligatoire du LOT 0.

## 12. Décisions encore ouvertes

-   Flutter vs React Native ;
-   une app distribuée vs deux binaires ;
-   protocole maître/joueur exact ;
-   mécanisme précis de sécurité du transport local (périmètre LOT 0 déjà fixé en section 9) ;
-   format/signature du QR de connexion ;
-   signature cryptographique des packages scénario ;
-   politique produit définitive de récupération (convention LOT 0 fixée en section 6) ;
-   progression entre scénarios ;
-   routeur dédié : recommandation officielle ou simple fallback ;
-   notifications du client ;
-   affichage physique/dédié de l'horloge.

Flutter et React Native restent les finalistes. Flutter est seulement le
premier candidat **RECOMMANDÉ pour expérimentation** ; aucune stack
définitive n'est choisie. Le détail du mini-scénario artificiel, des jetons,
curseurs, contrats expérimentaux et temporisations relève de la prochaine
préparation technique, pas de cette consolidation documentaire.
