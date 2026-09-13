# ADR-0001 --- Modèle d'autorité de la session

-   **Statut** : ACTÉ
-   **Contexte** : LOT 0 --- architecture hors ligne

## Décision

Une session de **24** suit une architecture **client/serveur locale**.

Le poste maître :

-   détient l'état officiel ;
-   détient le package scénario complet ;
-   détient les secrets et événements futurs ;
-   exécute le moteur de résolution ;
-   maintient l'horloge fictive autoritaire ;
-   persiste la session ;
-   produit les projections autorisées destinées aux clients.

Les applications joueurs :

-   émettent des commandes ou intentions ;
-   reçoivent des projections filtrées ;
-   ne modifient jamais directement l'état officiel ;
-   ne détiennent ni l'état complet du scénario ni les paramètres
    secrets.

Le système ne repose sur aucun service Internet pendant une session déjà
préparée.

## Conséquences

-   le maître constitue le point d'autorité et de persistance ;
-   la reprise après incident maître doit être explicitement traitée ;
-   les clients peuvent être reconstruits à partir de l'état maître ;
-   le protocole doit gérer reconnexion, séquences et déduplication ;
-   les données joueurs doivent être produites par projection côté
    autorité ;
-   une architecture de réplication symétrique/CRDT n'est pas nécessaire
    pour le MVP.

## Non-décidé par cet ADR

-   Flutter vs React Native ;
-   format exact du protocole ;
-   sécurité exacte du transport ;
-   une ou deux applications distribuées ;
-   mécanisme final de découverte/fallback.
