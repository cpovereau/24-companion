# 24 --- LOT 0 --- Plan de POC technique

## Objectif

> Statut : plan expérimental consolidé par arbitrages humains. Les mentions
> **ACTÉ POUR LE LOT 0** fixent le périmètre du POC, pas les choix produit
> définitifs. Les invariants des [ADR](../decisions/) restent applicables ;
> la [référence fonctionnelle](APPLICATION_COMPAGNON.md) décrit le besoin.

Valider les risques d'architecture avant de choisir définitivement la
stack mobile et avant d'industrialiser le protocole maître/joueur.

Le même scénario de test doit autant que possible être exécuté avec les
deux finalistes technologiques afin de comparer des résultats
équivalents.

Flutter et React Native restent les finalistes ; Flutter est le premier
candidat **RECOMMANDÉ pour expérimentation**. Aucune stack définitive
n'est choisie. Les capacités techniques restent **À TESTER** même lorsque
l'exigence qu'elles doivent satisfaire est **ACTÉE**.

## Matériel minimal

-   1 terminal maître ;
-   1 iPhone joueur ;
-   1 Android joueur.

**ACTÉ POUR LE LOT 0 — configurations minimales à rendre testables :**

| Maître | Joueur |
|---|---|
| Android | Android |
| Android | iOS |
| iOS | Android |

Les essais de développement peuvent utiliser simulateurs/émulateurs.
Ils ne remplacent pas la confirmation physique des capacités dépendantes
du système ou du réseau : LAN, Bonjour/mDNS, permissions, caméra/QR,
arrière-plan, audio, hotspot, changement de réseau et reprise après
suspension. Consigner les appareils, versions OS et la nature de chaque
essai ; ne pas présenter une configuration non exécutée comme validée.

Prévoir :

-   un Wi-Fi local sans Internet ;
-   un test hotspot ;
-   si disponible, un petit routeur Wi-Fi dédié sans accès Internet.

## Mini scénario

**ACTÉ POUR LE LOT 0 — option A** : mécaniques artificielles et
déterministes. Le POC démontre la faisabilité technique, **pas le moteur
de résolution réel de 24**. Le scénario exact sera défini pendant la
conception technique, avec états et résultats attendus explicites.

Il doit exercer le flux : commande → résolution maître → mutation d'état
→ événement → projection filtrée. Il couvre autorité, communication locale,
hors Internet, filtrage, persistance, reconnexion, idempotence, événements,
QR, audio, stabilité et permissions.

Créer un `.24scenario` de test contenant :

-   2 personnages ;
-   1 secret propre à chaque personnage ;
-   1 secret MJ ;
-   1 événement futur ;
-   1 QR de jeu ;
-   1 image ;
-   1 audio ;
-   au moins une action nécessitant une résolution maître.

Le format `.24scenario` est expérimental, sans figer le package définitif.
Prévoir les données artificielles cachées nécessaires aux tests de
confidentialité et une échéance synthétique ; ne pas en déduire les règles
narratives ou les formules de résolution du produit.

## Sécurité dès le LOT 0

**ACTÉ POUR LE LOT 0 — option B** :

- authentification du maître ;
- authentification et autorisation des clients ;
- protection du transport local adaptée à la menace étudiée ;
- contrôle des destinataires et filtrage des projections ;
- impossibilité pour un client non autorisé d'obtenir les données d'un
  autre personnage ou les secrets maître.

Pendant la préparation technique, définir la menace étudiée, le mécanisme
de confiance, les jetons et les essais correspondants. Tester notamment
le refus d'un faux maître, d'un client non autorisé, d'une tentative
d'accès à un autre personnage et les protections du transport contre les
attaques retenues. Documenter chaque résultat et limitation.

Le QR de jeu ne contient pas de réponse/conséquence secrète ; le QR de
connexion peut porter une donnée d'authentification temporaire. Son format
et son mécanisme restent à concevoir.

Le LOT 0 doit prouver qu'une architecture sécurisable et suffisamment
robuste est réalisable. Le durcissement, les choix définitifs et
l'industrialisation de sécurité de production viennent après le LOT 0 ;
ils ne dispensent d'aucun des contrôles ci-dessus.

## Parcours nominal

1.  Importer le package scénario sur le maître.
2.  Vérifier le package.
3.  Obtenir l'état `OFFLINE_READY`.
4.  Couper physiquement l'accès Internet.
5.  Créer la session.
6.  Publier la session sur le LAN.
7.  Faire rejoindre le joueur 1 par découverte locale.
8.  Faire rejoindre le joueur 2 via QR de connexion.
9.  Associer les deux appareils aux personnages.
10. Vérifier que P1 ne reçoit aucune donnée privée de P2.
11. Modifier un état maître, par exemple tension `2 -> 4`.
12. Vérifier la propagation aux deux projections.
13. Envoyer une commande depuis P1.
14. Résoudre la commande côté maître.
15. Envoyer uniquement le résultat autorisé à P1/P2 selon la visibilité.
16. Jouer un asset audio.
17. Passer temporairement le maître en arrière-plan.
18. Observer indépendamment audio et réseau.

La découverte et le QR ne remplacent pas l'authentification : appliquer
les contrôles de la section sécurité avant les échanges autorisés.
Scanner aussi le QR de jeu et vérifier son résultat autorisé. Déclencher
l'échéance synthétique sans la franchir silencieusement et vérifier que
son événement est traité une seule fois.

## Convention de reconnexion

**ACTÉ POUR LE LOT 0** : maximum **5 tentatives automatiques**.
Temporisations et backoff seront définis pendant la conception technique.
Après cinq échecs : conserver l'état local nécessaire, ne pas prétendre
être synchronisé, signaler clairement la perte de connexion et permettre
une nouvelle tentative ou une action appropriée.

Une reconnexion réussit seulement après réauthentification, reconnaissance
de la session et resynchronisation terminée : l'état autorisé est cohérent
avec le maître, sans double exécution ni information interdite reçue.
Le retour du socket seul ne constitue pas une réussite.

Définir avant les campagnes les points de départ/fin des mesures et les
répétitions. Mesurer les délais jusqu'à cet état final et le nombre de
tentatives ; tester l'épuisement des cinq tentatives et la reprise ensuite.

## Test de coupure/reconnexion

1.  Couper le Wi-Fi de P1.
2.  Continuer la session côté maître.
3.  Générer plusieurs événements.
4.  Réactiver le Wi-Fi de P1.
5.  Reconnecter P1.
6.  Vérifier :
    -   reconnaissance de la session ;
    -   reprise depuis `lastReceivedSequence` ou snapshot ;
    -   état final exact ;
    -   absence de fuite d'informations.
7.  Retransmettre volontairement une commande déjà traitée.
8.  Vérifier qu'elle n'est pas exécutée deux fois.

Couvrir séparément rejeu et snapshot filtrés, avec des événements privés
de P2 pendant l'absence de P1. Le sens des séquences et curseurs sera défini
pendant la conception : une séquence invisible ne doit pas être confondue
avec un événement perdu. Tester une retransmission après commit mais avant
réception de la réponse, puis après redémarrage du maître.

## Test de changement d'adresse

1.  Faire changer l'adresse IP du maître ou recréer le réseau.
2.  Conserver la même session.
3.  Vérifier que le client peut retrouver la session via son
    identité/découverte et non une IP considérée comme identité
    permanente.

## Test de redémarrage client

1.  Tuer complètement le client.
2.  Le relancer.
3.  Vérifier la restauration de :
    -   `sessionId` ;
    -   `clientId` ;
    -   binding personnage ;
    -   token si encore valide ;
    -   dernière séquence reçue.
4.  Vérifier la resynchronisation.

## Test de redémarrage maître

1.  Persister une session active.
2.  Tuer complètement le maître.
3.  Le relancer.
4.  Restaurer la session.
5.  Vérifier que l'horloge fictive n'a pas avancé silencieusement.
6.  Vérifier la récupération automatique en pause à la dernière heure
    persistée (`RECOVERY_PAUSED`, nom technique provisoire).
7.  Reconnecter les clients.
8.  Vérifier l'absence de duplication des événements.

**ACTÉ** : l'interruption ne provoque jamais d'avancement silencieux.
**ACTÉ POUR LE LOT 0 — option A** : dernière heure persistée → récupération
en pause → reprise explicite MJ. Vérifier qu'aucune reprise temporelle ne
se produit avant cette intervention, y compris avec une échéance en attente.
La politique produit définitive reste **À ARBITRER PLUS TARD** ; un éventuel
ajustement explicite du temps par le MJ n'est ni développé ni spécifié ici.

## Test de confidentialité scénario

Après utilisation du client joueur, inspecter son stockage applicatif.
Examiner aussi les données reçues et les journaux locaux éventuels.

Les éléments suivants doivent être **absents**, pas simplement cachés
dans l'UI :

-   secret P2 depuis P1 ;
-   secret MJ ;
-   événements futurs ;
-   difficulté réelle cachée ;
-   temps réel de complétion caché ;
-   tables secrètes ;
-   package scénario complet ;
-   données de résolution non autorisées.

Le test échoue si une donnée interdite est présente, même chiffrée, sauf
décision d'architecture explicite justifiant sa présence.

## Test de non-intrusion

### Principe

Inspecter le binaire final produit par chaque stack.

Le client joueur ne doit pas demander ou déclarer de permission pour :

-   microphone ;
-   contacts ;
-   SMS/messages ;
-   journal d'appels ;
-   photos ;
-   vidéos ;
-   bibliothèque audio ;
-   fichiers personnels ;
-   calendrier ;
-   localisation.

Le client ne doit pas proposer d'accès aux fichiers ou photos personnels.
Cette exigence n'interdit pas l'import ou la manipulation par le maître
des données propres à 24. Distinguer :

- **non-intrusion du terminal — ADR-0002** : contenus personnels interdits,
  permissions OS et stockage privé ;
- **confidentialité du jeu — ADR-0001** : seules les données 24 autorisées
  atteignent le joueur.

Sessions, personnages, messages 24, QR, projections autorisées, assets et
synchronisation sont des données légitimes du jeu. Un binaire commun n'est
pas une violation simplement parce qu'il contient le moteur ou l'import
maître. Tester séparément code présent, permissions déclarées, accès
effectifs et données présentes. Le binaire reste soumis à l'ADR-0002.
Si un changement de rôle est inclus dans le POC, examiner aussi les données
conservées sans fixer maintenant la politique produit de ce parcours.
Un codebase commun/probablement une application à deux rôles reste une
**RECOMMANDATION À TESTER**, pas un choix définitif de distribution.

### Caméra

Tester que :

1.  la permission caméra n'est demandée qu'au moment pertinent ;
2.  le QR est décodé depuis le flux ;
3.  aucune photo n'est sauvegardée dans la photothèque ;
4.  l'application ne demande pas accès à la photothèque.

### CI

Mettre en place une allowlist de permissions.

Toute permission/entitlement inattendu doit faire échouer le build de
validation.

Contrôler l'artefact final afin de détecter les permissions ajoutées
transitivement par les plugins/dépendances.

## Test 4--6 clients

Après validation à 2 clients :

-   monter progressivement à 4 puis 6 clients ;
-   générer des commandes concurrentes ;
-   provoquer des déconnexions temporaires ;
-   mesurer les temps de reconnexion ;
-   vérifier les séquences et duplications ;
-   vérifier la stabilité mémoire/CPU du maître.

## Acceptation fonctionnelle et mesures de stabilité

**ACTÉ POUR LE LOT 0** : 100 % des opérations requises doivent aboutir
correctement dans les campagnes définies, sans perte d'état, duplication
d'action, fuite d'information, divergence entre état maître et projection
client après synchronisation, corruption de session ou événement perdu
nécessitant une correction manuelle.

Ce critère signifie **aucune erreur fonctionnelle tolérée dans le parcours
testé** ; ce n'est pas une affirmation statistique universelle de fiabilité.
Les rejets attendus et pertes de connexion provoquées doivent produire le
comportement prévu, sans être maquillés en succès ni comptés comme des
actions valides à exécuter.

Pour chaque campagne, documenter nombre d'opérations, durée, nombre de
clients, appareils/OS, incidents provoqués et résultat. Définir pendant
la conception les charges et durées reproductibles, points de mesure et
seuils de performance avant de comparer les résultats. Mesurer mémoire,
CPU et délais de reconnexion ; distinguer ces mesures de l'exactitude
fonctionnelle et indiquer toute capacité non testée.

## Gestion des erreurs et diagnostic

**Requis dès le LOT 0** : diagnostiquer erreurs réseau, échecs de
reconnexion, erreurs de persistance, commandes rejetées, erreurs de
synchronisation, erreurs de package/scénario et événements/séquences
incohérents. Inclure des cas provoqués et vérifier que le diagnostic ne
cache pas une perte d'état ou une fausse réussite.

**RECOMMANDATION** : journalisation locale maîtrisée, compatible avec la
confidentialité. Aucune donnée personnelle du téléphone n'est collectée ;
aucun secret de scénario n'est envoyé à un service tiers. Les journaux
joueurs ne doivent pas contenir de secrets non autorisés.
Le crash reporting tiers reste non obligatoire et non acté ; une éventuelle
évaluation est reportée, sans reporter la gestion des erreurs.

## À définir pendant la conception technique

- mini-scénario artificiel exact et résultats attendus ;
- menace étudiée et mécanisme de sécurité correspondant au périmètre acté ;
- mécanisme de jetons ;
- séquences et curseurs de synchronisation ;
- stratégie précise de reprise respectant la récupération en pause ;
- temporisations de reconnexion dans la limite de cinq tentatives ;
- contrats expérimentaux du protocole ;
- campagnes, durées, charges et mesures reproductibles.

Ces éléments ne bloquent pas la consolidation documentaire. Restent
**À ARBITRER** après les résultats pertinents : stack définitive, nombre de
binaires, contrats et sécurité de production, formats/signatures définitifs
des packages et QR, politique produit de récupération. Progression
interscénarios, automatisation narrative complète, notifications, affichage
physique et crash reporting tiers ne sont pas nécessaires au premier POC.
La recommandation officielle éventuelle d'un routeur attend les tests réseau.

## Grille comparative Flutter / React Native

Noter chaque critère sur 5.

  Critère                                     Poids
  ----------------------------------------- -------
  Serveur local embarqué                          5
  Stabilité maître iOS                            5
  Stabilité maître Android                        5
  Reconnexion                                     5
  Testabilité du domaine                          5
  Bonjour/mDNS                                    4
  Audio + background                              4
  Persistance                                     4
  Quantité de code natif spécifique               4
  Code partagé maître/joueur                      3
  Facilité de travail avec Codex                  3
  Distribution                                    2
  Sobriété des permissions du build final         5

Documenter pour chaque note :

-   résultat observé ;
-   version OS ;
-   terminal ;
-   dépendances utilisées ;
-   code natif ajouté ;
-   permissions/entitlements finaux ;
-   anomalie ou limitation.

## Critères de sortie du LOT 0

Le LOT 0 est concluant si au moins une stack démontre :

-   fonctionnement complet sans Internet après préparation ;
-   maître local fiable ;
-   connexion iOS + Android ;
-   séparation effective des secrets ;
-   authentification du maître et des clients, autorisations et protection
    du transport validées face à la menace documentée ;
-   reconnexion déterministe ;
-   commandes idempotentes ;
-   restauration après arrêt ;
-   QR fonctionnel sans accès Photos ;
-   absence de permissions personnelles interdites ;
-   aucune erreur fonctionnelle sur les opérations requises des campagnes
    définies, avec mesures de stabilité multiclient documentées ;
-   résultats sur les trois configurations minimales, avec confirmation
    physique des capacités qui la nécessitent ;
-   diagnostic des erreurs prévu, conforme à la confidentialité.

Le choix technologique ne doit être acté qu'après collecte de ces
résultats.
