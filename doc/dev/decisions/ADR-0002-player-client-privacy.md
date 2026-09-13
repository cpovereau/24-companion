# ADR-0002 --- Non-intrusion et minimisation du client joueur

-   **Statut** : ACTÉ
-   **Contexte** : LOT 0 --- confiance, confidentialité et permissions
    mobiles

## Décision

Le client joueur de **24** applique un principe de minimisation stricte
des permissions et des données.

Il n'accède à aucun contenu personnel du terminal qui n'est pas
strictement nécessaire au fonctionnement de 24.

Les seules capacités système prévues dans le périmètre courant sont :

-   caméra pour lecture de QR codes ;
-   réseau local pour rejoindre la session ;
-   stockage privé/sandbox de l'application ;
-   sortie audio pour les sons propres à l'application si nécessaire.

Le client ne doit pas demander accès :

-   au microphone ;
-   aux contacts ;
-   aux SMS/messages ;
-   au journal d'appels ;
-   aux photos ou vidéos personnelles ;
-   à la bibliothèque audio personnelle ;
-   aux fichiers personnels ;
-   au calendrier ;
-   à la localisation.

Aucun identifiant matériel du terminal ne doit servir d'identité joueur.

Toute nouvelle permission nécessite une décision d'architecture
explicite.

## Caméra

La permission caméra doit être demandée au moment du premier besoin
pertinent.

La lecture QR s'effectue depuis le flux caméra.

Aucune image n'est sauvegardée dans la photothèque et l'accès à la
photothèque n'est pas requis.

## Stockage

Le client n'utilise que son stockage applicatif privé pour les données
nécessaires à 24.

Il ne parcourt pas les espaces personnels du terminal.

## Dépendances

Le MVP n'intègre par défaut :

-   aucun SDK publicitaire ;
-   aucun tracking comportemental ;
-   aucun SDK analytics tiers.

Toute dépendance susceptible d'ajouter une permission, un entitlement ou
une collecte doit être examinée.

## Vérification

Les builds iOS et Android doivent être contrôlés selon une **allowlist
de permissions**.

La CI doit inspecter l'artefact final afin de détecter également les
permissions ajoutées par les dépendances.

Une permission inattendue constitue un échec de validation.

## Conséquences

Cette décision :

-   réduit la surface d'attaque ;
-   facilite l'explication de confiance faite au joueur ;
-   contraint le choix des plugins Flutter/React Native ;
-   devient un critère de comparaison du LOT 0 ;
-   interdit de résoudre un besoin futur par une permission
    supplémentaire sans arbitrage explicite.
