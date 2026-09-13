# 24 — Application compagnon

## Objet

Ce dépôt est destiné à la conception puis au développement de l'application compagnon du jeu **24**.

24 est un jeu d'aventure narrative à mi-chemin entre jeu de rôle, jeu de plateau et escape game. Les joueurs incarnent des personnages engagés dans un scénario contemporain sous forte contrainte temporelle. Un joueur tient le rôle de **Maître du Temps / Conteur**.

L'application compagnon a pour rôle d'automatiser les mécaniques qui interrompraient autrement le rythme de jeu, tout en laissant la narration, les décisions et les interactions au premier plan.

## Principes fonctionnels

L'application devra notamment permettre de gérer :

- le temps global de la partie ;
- des groupes de personnages pouvant agir simultanément ;
- des chronomètres individuels ou collectifs ;
- l'estimation et le calcul de la durée des actions ;
- l'investissement de ressources pour influer sur cette durée ;
- la synchronisation des actions et groupes dans une chronologie fictive commune ;
- à terme, certaines informations propres aux personnages, communications de jeu ou événements secrets.

La complexité mécanique doit rester aussi discrète que possible pour les joueurs.

## État du projet

Le projet est en phase de conception.

Les documents fonctionnels et de conception existants sont conservés dans Google Drive. Le répertoire local `doc/conception` est prévu comme **liaison locale** vers le dossier Google Drive synchronisé ; son contenu ne doit pas être publié dans ce dépôt Git.

La documentation propre au développement de l'application est versionnée en Markdown dans `doc/dev`.

La référence fonctionnelle locale est
[`APPLICATION_COMPAGNON.md`](doc/dev/specifications/APPLICATION_COMPAGNON.md).
Elle décrit le quoi/pourquoi issu de la conception ; les ADR portent les
décisions, l'architecture les orientations techniques et le LOT 0 les
conventions expérimentales et leurs tests. Google Drive reste une source
humaine, sans être un prérequis d'accès pour préparer le POC.

## Structure

```text
24/
├── README.md
├── .gitignore
├── .editorconfig
├── doc/
│   ├── README.md
│   ├── conception/          # liaison locale vers Google Drive, non versionnée
│   └── dev/
│       ├── README.md
│       ├── architecture/
│       ├── decisions/
│       ├── specifications/
│       ├── mvp/
│       ├── ui-ux/
│       ├── testing/
│       └── operations/
└── scripts/
    └── link-conception.ps1
```

## Documentation

### `doc/conception`

Documentation de conception du jeu et de l'application déjà maintenue dans Google Drive.

Ce chemin est volontairement exclu de Git : chaque poste de développement peut le relier à son dossier Google Drive synchronisé avec `scripts/link-conception.ps1`.

### `doc/dev`

Documentation technique versionnée avec le code :

- **architecture** : architecture applicative, flux, stockage, communications, fonctionnement hors ligne ;
- **decisions** : décisions d'architecture (ADR) et arbitrages techniques ;
- **specifications** : référence fonctionnelle et plan de validation technique du POC ;
- **mvp** : découpage des lots, backlog et critères d'acceptation du MVP ;
- **ui-ux** : parcours, écrans, ergonomie et règles d'interface ;
- **testing** : stratégie de tests, jeux d'essai et validation ;
- **operations** : build, distribution, publication, maintenance et exploitation.

## Dépôt public

Ce projet a vocation à être publié dans un dépôt Git public.

En conséquence :

- aucun document privé ou synchronisé depuis Google Drive ne doit être commité ;
- aucun secret, jeton, mot de passe ou configuration locale ne doit être versionné ;
- les décisions et spécifications utiles au développement public doivent être reformulées dans `doc/dev` lorsque nécessaire.

## Stack technique

La stack technique n'est pas figée dans ce dépôt à ce stade. Les choix de framework mobile, architecture, stockage et communications devront être documentés dans `doc/dev/decisions` avant leur mise en œuvre.

Flutter et React Native restent les finalistes. Flutter est seulement le
premier candidat recommandé pour expérimentation ; aucune stack définitive
n'est choisie. Les conventions du LOT 0 ne figent pas les choix produit.
