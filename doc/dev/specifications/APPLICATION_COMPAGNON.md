# 24 --- Application compagnon --- Référence fonctionnelle

> **Statut : document de référence fonctionnelle destiné au
> développement**
>
> Ce document n'est pas une nouvelle source de conception du jeu. Il
> constitue la projection fonctionnelle, destinée au développement, des
> éléments stabilisés dans la documentation de conception de **24** et
> des décisions prises pendant la préparation du LOT 0.
>
> Il décrit principalement **ce que l'application compagnon doit
> permettre et pourquoi**. Les choix d'architecture et d'implémentation
> sont documentés séparément dans `ARCHITECTURE.md` et les ADR. Les
> moyens de validation technique sont documentés dans `LOT0_POC.md`.
>
> En cas d'évolution de la conception du jeu, ce document doit être mis
> à jour explicitement. Il ne remplace pas la documentation de
> conception conservée sur Google Drive.

------------------------------------------------------------------------

## 1. Finalité de l'application compagnon

L'application compagnon de **24** est un outil au service du jeu.

Elle doit automatiser les opérations qui risqueraient autrement de
casser le rythme de la partie, notamment :

-   les résolutions ;
-   les calculs associés aux actions ;
-   la gestion de leur durée ;
-   certaines dépenses ou évolutions de ressources ;
-   la synchronisation des personnages et des groupes ;
-   la progression du temps fictif ;
-   le déclenchement d'événements ;
-   la circulation contrôlée d'informations ;
-   certains messages ou éléments multimédias.

L'application ne doit pas devenir le centre de l'expérience.

Les joueurs doivent continuer à regarder la table, les autres joueurs,
le Conteur et les éléments physiques du jeu plutôt que leur téléphone.

### Principe d'expérience

Le numérique doit principalement :

1.  supprimer les calculs et manipulations mécaniques inutiles ;
2.  maintenir un état cohérent de la partie ;
3.  permettre une circulation individuelle de l'information ;
4.  soutenir la tension temporelle ;
5.  préserver les secrets ;
6.  laisser la narration et les décisions humaines au premier plan.

Le joueur ne doit pas avoir à comprendre la complexité interne du moteur
pour jouer.

------------------------------------------------------------------------

## 2. Deux interfaces, une seule session

L'application compagnon propose deux expériences complémentaires :

-   l'interface **Maître / MJ / Conteur** ;
-   l'interface **Joueur**.

Ces interfaces ne représentent pas deux jeux ni deux moteurs différents.

Elles travaillent sur une même session et utilisent un moteur de règles
commun.

Le maître constitue l'autorité de cette session. Le joueur ne reçoit
qu'une vue adaptée à son personnage et à ce qu'il est autorisé à
connaître.

------------------------------------------------------------------------

## 3. Expérience du joueur

### 3.1 Objectif

L'interface joueur doit rester simple, rapide à comprendre et peu
intrusive.

Elle doit permettre au joueur de disposer immédiatement des informations
utiles à son personnage sans lui exposer les mécanismes internes de
résolution.

### 3.2 Informations accessibles

Selon le personnage, le scénario et l'état courant de la partie, le
joueur peut notamment consulter :

-   son identité de personnage ;
-   son background ;
-   ses objectifs personnels ;
-   ses caractéristiques ;
-   ses savoir-faire ;
-   son expérience et les éléments de progression autorisés ;
-   ses jauges courantes ;
-   les informations de scénario qu'il a effectivement obtenues ;
-   ses messages ;
-   les actions qui lui sont actuellement accessibles ;
-   les résultats qui lui sont destinés.

L'application peut également donner accès aux cartes, éléments
d'Historique, séquelles ou autres ressources numériques propres au
personnage lorsque ces éléments font partie de sa progression.

### 3.3 Ce que le joueur ne voit pas

Le joueur ne doit pas voir :

-   les calculs internes du moteur ;
-   les difficultés réelles cachées ;
-   les tables secrètes ;
-   les conséquences non encore révélées ;
-   les plans des PNJ ;
-   les événements futurs ;
-   les secrets du scénario ;
-   les secrets des autres personnages qui ne lui ont pas été transmis
    en jeu ;
-   les informations réservées au MJ.

Une information cachée ne doit pas seulement être masquée dans
l'interface : elle ne doit pas être présente sur le terminal joueur.

### 3.4 Résolution d'une action

L'expérience cible d'une résolution est volontairement concise.

Le joueur doit principalement pouvoir comprendre :

-   ce qu'il envisage de faire ;
-   les choix ou variantes qui lui sont proposés ;
-   éventuellement l'estimation que son personnage peut raisonnablement
    faire ;
-   le temps ou budget de temps qu'il souhaite engager lorsque la
    mécanique le prévoit ;
-   si l'action est possible ;
-   le résultat qui lui est perceptible ;
-   les conséquences que son personnage est en mesure de constater.

Le joueur ne doit pas manipuler lui-même les formules internes.

Le moteur peut prendre en compte davantage de paramètres que ceux
affichés au joueur.

### 3.5 QR codes

Le joueur peut utiliser la caméra de son téléphone pour scanner certains
QR codes associés au jeu.

Un QR de jeu sert à identifier un élément ; il ne contient pas
de réponse ou de conséquence secrète.

Le QR de connexion a un autre usage : rejoindre une session. Il peut
nécessiter une donnée d'authentification temporaire ; son mécanisme relève
de l'architecture, sans remettre en cause la règle des QR de jeu.

Le scan d'un QR de jeu permet au système de déterminer, selon le scénario, le
personnage et l'état de la session, ce que ce QR produit ou révèle.

L'application ne doit pas nécessiter l'accès à la photothèque pour cette
fonction.

### 3.6 Messages

L'application peut recevoir et afficher des messages propres à **24**.

Ces messages sont internes à la session de jeu.

L'application ne doit pas accéder aux SMS, messageries ou autres
communications personnelles du téléphone.

------------------------------------------------------------------------

## 4. Expérience du Maître / MJ

### 4.1 Objectif

L'interface maître constitue le poste de contrôle de la session.

Elle doit permettre au Conteur de piloter les mécanismes nécessaires
sans l'obliger à gérer manuellement les détails calculatoires du moteur.

Le MJ conserve la maîtrise narrative de la partie.

L'automatisation ne doit pas lui retirer la capacité de comprendre
l'état de la session et d'agir lorsque la conception du jeu le prévoit.

### 4.2 Préparation d'une session

Avant le début d'une partie, le maître doit pouvoir notamment :

-   disposer localement du scénario ;
-   vérifier que ses données et ressources nécessaires sont présentes ;
-   créer une nouvelle session ou reprendre une session existante ;
-   préparer les personnages nécessaires ;
-   accueillir les appareils joueurs ;
-   associer joueurs, appareils et personnages ;
-   vérifier que les participants sont prêts ;
-   démarrer la partie.

Une fois cette préparation terminée, le déroulement normal de la partie
ne doit plus dépendre d'Internet.

### 4.3 Pendant la partie

Selon les fonctions effectivement retenues dans le scénario et
l'interface, le maître doit pouvoir suivre ou contrôler notamment :

-   l'horloge fictive ;
-   la tension ;
-   les personnages ;
-   leur état courant ;
-   les groupes de personnages ;
-   les actions en cours ;
-   les résolutions ;
-   les événements ;
-   les échéances ;
-   les informations révélées ;
-   les messages ;
-   certains éléments audio ;
-   la circulation des informations entre les participants.

Le maître dispose des informations complètes nécessaires à l'exécution
du scénario.

------------------------------------------------------------------------

## 5. Fonctionnement général d'une session

Une session peut être représentée fonctionnellement par les étapes
suivantes :

``` text
Préparation du scénario
        ↓
Vérification des ressources
        ↓
Création / reprise de session
        ↓
Connexion des joueurs
        ↓
Association aux personnages
        ↓
Vérification de préparation
        ↓
Démarrage
        ↓
Déroulement de la partie
        ↓
Actions / résolutions / événements / messages
        ↓
Évolution du temps et de l'état
        ↓
Fin ou sauvegarde de la session
```

La session doit pouvoir survivre aux interruptions raisonnables prévues
par le système.

La manière technique dont cette reprise est assurée relève de
l'architecture.

------------------------------------------------------------------------

## 6. Temps fictif

### 6.1 Une horloge commune

Une session de **24** possède une seule horloge fictive faisant
autorité.

Les personnages peuvent être séparés, effectuer des actions différentes
ou agir dans des lieux différents : ils restent néanmoins inscrits dans
une même chronologie.

Un éventuel téléphone dédié ou affichage physique de l'horloge ne
constitue qu'une représentation de cette heure commune.

### 6.2 Durée des actions

Les actions peuvent consommer du temps fictif.

Le moteur doit pouvoir gérer des actions de durées différentes et leur
articulation avec :

-   les autres personnages ;
-   les groupes ;
-   les événements du scénario ;
-   les échéances importantes.

### 6.3 Échéances significatives

Une progression du temps ne doit pas franchir silencieusement une
échéance significative du scénario.

Le système doit être capable de faire émerger les événements qui
deviennent pertinents lorsque le temps progresse.

### 6.4 Groupes séparés

Les personnages peuvent se séparer en plusieurs groupes.

Cette séparation n'entraîne pas la création de plusieurs chronologies
indépendantes.

Les groupes évoluent dans la même timeline fictive, même lorsque leurs
actions et informations diffèrent.

### 6.5 Interruption du maître

**ACTÉ** : une interruption ne provoque jamais de progression silencieuse
du temps fictif. La récupération en pause et la reprise explicite par le
MJ sont **ACTÉES POUR LE LOT 0**, selon [LOT0_POC.md](LOT0_POC.md).
La politique produit définitive, notamment un éventuel ajustement temporel
décidé explicitement par le MJ, reste **À ARBITRER PLUS TARD**.

------------------------------------------------------------------------

## 7. Personnages

### 7.1 Dimensions du personnage

**ACTÉ — distinction fonctionnelle** : aptitude naturelle/caractéristiques,
savoir-faire, expérience et état actuel sont des dimensions distinctes et
non interchangeables, ainsi que les autres dimensions documentées ci-dessous.
Cette décision ne prescrit pas le découpage logiciel.

La représentation numérique d'un personnage doit pouvoir prendre en
compte plusieurs dimensions complémentaires, notamment :

-   les caractéristiques ;
-   les savoir-faire ;
-   l'expérience ;
-   l'état courant ;
-   les informations narratives personnelles ;
-   les objectifs ;
-   les éléments de progression.

Les structures techniques exactes sont décrites ou explorées dans la
documentation d'architecture.

### 7.2 État courant

L'état du personnage évolue pendant la partie.

Les jauges actuellement identifiées comprennent notamment :

-   **Constitution** ;
-   **Endurance** ;
-   **Sang-froid**.

Le moteur peut utiliser cet état lors des résolutions et le mettre à
jour selon les conséquences de la partie.

### 7.3 Progression

L'application doit pouvoir représenter les éléments de progression
prévus par le jeu, notamment lorsque cela devient pertinent :

-   expérience ;
-   savoir-faire acquis ou développés ;
-   cartes débloquées ;
-   éléments d'Historique ;
-   séquelles ou conséquences persistantes.

La persistance d'une progression d'un scénario à un autre n'est pas
considérée comme définitivement arbitrée dans le LOT 0.

### 7.4 Identité personnalisée

Le modèle technique recommandé/exploratoire distingue la définition du personnage fournie
par le scénario de l'identité éventuellement personnalisée par le joueur
et de son état dans une session.

Cette distinction doit permettre de ne pas confondre :

-   l'archétype ou modèle ;
-   le profil du personnage ;
-   son état courant dans une partie précise.

`CharacterTemplate`, `CharacterProfile` et `SessionCharacter` restent des
structures proposées dans l'architecture, pas une décision fonctionnelle
ACTÉE ni un schéma définitif.

------------------------------------------------------------------------

## 8. Résolution des actions

### 8.1 Rôle du moteur

Le moteur de résolution est commun à la session.

Il doit pouvoir combiner les éléments nécessaires à la mécanique de
**24** sans exposer au joueur les paramètres qui doivent rester cachés.

La complexité interne peut notamment dépendre :

-   du personnage ;
-   de ses caractéristiques ;
-   de ses savoir-faire ;
-   de son expérience ;
-   de son état courant ;
-   de l'action ;
-   du contexte ;
-   du temps engagé ;
-   de paramètres propres au scénario.

Cette liste exprime les catégories fonctionnelles possibles et ne
constitue pas un schéma de données définitif.

### 8.2 Intention puis résolution

Le joueur exprime une intention ou un choix.

Le maître et le moteur déterminent le résultat officiel.

Fonctionnellement :

``` text
Intention du joueur
        ↓
Contexte de la session
        ↓
Moteur de résolution
        ↓
Mise à jour de l'état officiel
        ↓
Résultat perceptible
        ↓
Information adaptée à chaque destinataire
```

### 8.3 Informations cachées

Le moteur peut connaître une information que le joueur ne connaît pas.

Par exemple, une action peut dépendre d'une difficulté ou d'une
conséquence cachée.

L'interface joueur ne doit donc jamais être considérée comme la source
complète des paramètres d'une résolution.

------------------------------------------------------------------------

## 9. Information, connaissance et secrets

### 9.1 L'information appartient aux personnages

Une information de jeu n'est pas automatiquement connue de tous les
joueurs parce qu'elle existe dans la session.

Elle doit être associée aux personnages qui l'ont effectivement obtenue
ou auxquels elle a été transmise.

### 9.2 Personnages séparés

Lorsque des personnages sont séparés, une information découverte par un
groupe n'est pas automatiquement connue par les autres.

Le système doit pouvoir maintenir cette différence de connaissance.

La communication entre personnages reste un acte de jeu et ne doit pas
être remplacée automatiquement par une synchronisation universelle des
informations.

### 9.3 Révélation progressive

Une information peut passer de :

``` text
secrète
    ↓
connue du MJ uniquement
    ↓
connue d'un personnage ou groupe
    ↓
éventuellement communiquée à d'autres
```

L'application doit permettre cette circulation contrôlée sans exposer
prématurément les étapes suivantes.

### 9.4 Principe de minimisation

Le client joueur ne reçoit que ce dont il a besoin pour présenter l'état
autorisé de son personnage.

Le filtrage des informations constitue une exigence fonctionnelle et de
sécurité.

------------------------------------------------------------------------

## 10. Scénario et causalité

Le scénario ne doit pas être considéré comme une simple suite linéaire
d'écrans ou de scènes.

La conception de **24** repose sur une évolution causale dans le temps.

Le scénario peut notamment comporter :

-   des situations initiales ;
-   des événements ;
-   des échéances ;
-   des actions ou plans de PNJ ;
-   des conséquences ;
-   des alternatives ;
-   des informations ;
-   des objets ou indices ;
-   des messages ;
-   des ressources multimédias.

Le système doit pouvoir distinguer une chronologie théorique prévue par
le scénario de la chronologie réellement produite par les actions des
joueurs.

Les décisions des joueurs peuvent modifier le déroulement effectif.

L'application doit soutenir cette causalité sans transformer la partie
en parcours scripté rigide.

------------------------------------------------------------------------

## 11. PNJ et événements

Les personnages non joueurs peuvent poursuivre des objectifs et agir
dans le temps.

Le scénario doit pouvoir représenter, lorsque nécessaire :

-   un plan initial ;
-   des actions prévues ;
-   des échéances ;
-   des réactions ;
-   des alternatives ou plans de repli.

Les événements ne sont donc pas nécessairement de simples alarmes
déclenchées à une heure fixe.

Ils peuvent dépendre du temps, de l'état de la session et des
conséquences des actions précédentes.

Le niveau exact d'automatisation des décisions narratives du MJ n'est
pas figé par ce document.

------------------------------------------------------------------------

## 12. Messages et circulation d'information

Le système peut transmettre des informations à :

-   un personnage ;
-   plusieurs personnages ;
-   un groupe ;
-   tous les joueurs ;
-   le maître.

Le destinataire effectif fait partie du sens de l'information.

Une donnée destinée à un personnage ne doit pas être envoyée aux autres
clients en comptant uniquement sur l'interface pour la masquer.

Les messages peuvent être immédiats ou liés à un événement du scénario
selon les besoins fonctionnels.

------------------------------------------------------------------------

## 13. Éléments physiques et numériques

### 13.1 Complémentarité

Le matériel physique et l'application ne doivent pas se dupliquer
inutilement.

Le physique sert notamment à donner de la présence, de la manipulation
et de la matérialité au jeu.

Le numérique est mieux adapté à :

-   l'état détaillé et évolutif ;
-   les calculs ;
-   la synchronisation ;
-   les informations privées ;
-   les événements ;
-   les données qui changent fréquemment.

### 13.2 Support physique du personnage

Un support physique peut représenter l'archétype ou certains éléments
immédiatement utiles à table.

La fiche numérique conserve les informations détaillées et évolutives.

Un QR peut permettre d'identifier ou d'ouvrir le personnage
correspondant dans l'application sans encoder l'intégralité de sa fiche.

### 13.3 Horloge

Une horloge commune peut être affichée sur :

-   le terminal maître ;
-   un téléphone dédié ;
-   éventuellement un dispositif physique piloté par le système.

Ces affichages ne sont jamais la source de vérité de l'heure fictive.

------------------------------------------------------------------------

## 14. Audio et ambiance

Le maître peut disposer de fonctions permettant de jouer certains
éléments audio associés à la session ou au scénario.

L'audio doit rester un soutien à l'ambiance et à la narration.

Le comportement technique de l'audio lorsque l'application maître passe
en arrière-plan fait partie des éléments à tester dans le LOT 0.

Le client joueur n'a pas besoin d'accéder au microphone ni à la
bibliothèque audio personnelle du téléphone pour les fonctions
actuellement prévues.

------------------------------------------------------------------------

## 15. Non-intrusion du téléphone joueur

L'application joueur doit inspirer une confiance forte.

Elle n'accède à aucun contenu personnel du terminal qui n'est pas
nécessaire à **24**.

### Capacités prévues

-   caméra pour les QR codes ;
-   réseau local pour rejoindre la session ;
-   stockage privé de l'application ;
-   sortie audio pour les sons propres à 24 si nécessaire.

### Accès interdits dans le périmètre courant — ADR-0002

-   microphone ;
-   contacts ;
-   SMS ou messages ;
-   journal d'appels ;
-   photos et vidéos personnelles ;
-   bibliothèque audio personnelle ;
-   fichiers personnels ;
-   calendrier ;
-   localisation ;
-   données des autres applications.

L'identité du joueur ne doit pas dépendre d'un identifiant matériel du
téléphone.

Les exigences techniques et les contrôles de permissions associés sont
détaillés dans l'ADR consacré à la non-intrusion et dans le LOT 0.

Deux exigences indépendantes s'appliquent :

- **Non-intrusion du terminal (ADR-0002)** : ne pas accéder aux contenus
  personnels du téléphone ; les données nécessaires à 24 restent dans le
  stockage applicatif privé.
- **Confidentialité du jeu (ADR-0001)** : ne transmettre au joueur que les
  informations de jeu qu'il est autorisé à connaître.

Manipuler les données internes de 24 est légitime : session, personnage,
état, messages 24, QR 24, projections autorisées, assets du scénario et
données de synchronisation. Cela n'autorise aucun accès personnel interdit.
La présence de fonctions maître d'import ou de manipulation de données 24
dans un binaire commun n'est donc pas, à elle seule, une violation de
l'ADR-0002. Permissions OS et confidentialité restent applicables ; une
application commune n'est pas définitivement choisie.

------------------------------------------------------------------------

## 16. Fonctionnement hors Internet

Internet peut être utilisé avant la partie pour les opérations qui le
nécessitent, par exemple :

-   installation ;
-   mise à jour ;
-   récupération ou import d'un scénario ;
-   récupération des ressources.

Avant le démarrage, le système doit pouvoir s'assurer que les éléments
nécessaires sont disponibles localement.

Une fois la session démarrée, le fonctionnement normal de la partie doit
être possible sans Internet.

Cette contrainte concerne notamment :

-   les résolutions ;
-   l'horloge ;
-   les événements ;
-   les personnages ;
-   les messages internes ;
-   les QR ;
-   les ressources nécessaires ;
-   la communication maître/joueurs.

------------------------------------------------------------------------

## 17. Ce que l'application ne doit pas devenir

L'application compagnon n'a pas vocation à :

-   remplacer le Conteur ;
-   raconter automatiquement toute la partie ;
-   transformer le jeu en jeu vidéo multijoueur ;
-   obliger les joueurs à rester les yeux sur leur écran ;
-   rendre visibles les mécaniques internes au détriment de l'immersion
    ;
-   distribuer automatiquement toutes les informations à tous les
    personnages ;
-   dépendre d'un serveur Internet pendant la partie ;
-   aspirer des données personnelles du téléphone ;
-   utiliser la technologie comme finalité plutôt que comme support du
    jeu.

Lorsqu'un choix d'interface ou d'architecture augmente fortement
l'attention demandée au joueur sans bénéfice de jeu clair, il doit être
remis en question.

------------------------------------------------------------------------

## 18. Frontière entre fonctionnel et technique

Ce document définit la référence fonctionnelle nécessaire au
développement.

Les documents suivants ont des responsabilités différentes :

### `APPLICATION_COMPAGNON.md`

Décrit :

> **ce que l'application doit permettre et pourquoi.**

### `ARCHITECTURE.md`

Décrit :

> **comment le système est actuellement envisagé techniquement pour
> satisfaire ces besoins.**

Les éléments de ce document peuvent rester exploratoires lorsque leur
statut l'indique.

### `decisions/ADR-*.md`

Décrivent :

> **les décisions d'architecture explicitement prises et leurs
> conséquences.**

Un ADR ACTÉ prévaut sur une simple recommandation d'architecture
lorsqu'ils traitent du même sujet.

### `LOT0_POC.md`

Décrit :

> **comment les hypothèses techniques importantes doivent être testées
> avant le choix définitif de la stack.**

### Documentation de conception Google Drive

Conserve :

> **la conception complète du jeu, des règles, des personnages, du
> matériel, des scénarios et l'historique de réflexion.**

Elle reste la source humaine de conception. Elle n'a pas vocation à être
intégralement dupliquée dans le dépôt de développement.

------------------------------------------------------------------------

## 19. Points volontairement non figés ici

Ce document ne choisit pas :

-   Flutter ou React Native ;
-   une application distribuée ou deux binaires ;
-   le protocole réseau exact ;
-   la technologie précise de persistance ;
-   la sécurité exacte du transport local ;
-   le format définitif des packages scénario ;
-   le format définitif des QR ;
-   le mécanisme final de progression entre scénarios ;
-   le comportement définitif de récupération de l'horloge après
    incident ;
-   le niveau final d'intégration d'un affichage physique ;
-   le niveau exact d'automatisation de certains événements narratifs.

Ces questions doivent rester dans leurs documents d'architecture, ADR ou
travaux d'expérimentation respectifs.

------------------------------------------------------------------------

## 20. Règle de lecture pour les agents de développement

Lorsqu'un agent tel que Codex travaille sur **24**, il doit utiliser ce
document pour comprendre l'intention fonctionnelle de l'application.

Il ne doit pas déduire d'une description fonctionnelle une décision
technique qui n'a pas été prise.

En cas de doute :

1.  consulter les ADR pour les décisions actées ;
2.  consulter `ARCHITECTURE.md` pour l'orientation technique courante ;
3.  consulter `LOT0_POC.md` pour les hypothèses devant encore être
    validées ;
4.  signaler les contradictions plutôt que les arbitrer silencieusement
    ;
5.  demander un arbitrage lorsqu'une implémentation nécessiterait de
    figer un point encore ouvert.

Le but est de préserver une séparation claire entre :

``` text
INTENTION DU JEU
      ↓
BESOINS FONCTIONNELS
      ↓
DÉCISIONS D'ARCHITECTURE
      ↓
EXPÉRIMENTATION
      ↓
IMPLÉMENTATION
```
