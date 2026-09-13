# LOT 0 — Préparation de l'architecture technique locale

> Statut : préparation globalement validée, intégrant les arbitrages humains
> ci-dessous. Les conventions ACTÉES POUR LE LOT 0 ne figent pas le produit.
> Aucune stack ni dépendance concrète n'est définitivement choisie.
> Références : [architecture](ARCHITECTURE.md),
> [plan de validation](../specifications/LOT0_POC.md),
> [fonctionnel](../specifications/APPLICATION_COMPAGNON.md) et [ADR](../decisions/).

## 1. Périmètre et environnement observé

Le socle documentaire a été publié par le commit `60c6b4b`. L'inventaire
matériel, les versions, les sources officielles et l'ordre d'installation
proposé sont dans [DEV_ENVIRONMENT.md](../operations/DEV_ENVIRONMENT.md).
Ce document distingue inventaire préalable et suivi des installations réelles.
Au 13 septembre 2026 : Flutter 3.47.4/Dart 3.13.3, Studio Quail 4 et SDK
Android installés ; doctor sans problème, APK debug du projet temporaire
hors dépôt généré puis installé et lancé sur le Pixel 8a Android 17/API 37.
Après redémarrage supervisé, WHP/Hyper-V/VBS et accélération WHPX vérifiés.
Aucun code du POC 24 implémenté. Après allègement de la session, un AVD
API 37 de 4 Go a été créé et lancé, et l'application temporaire y a été
construite et exécutée : **1 AVD classé VIABLE MAIS CONTRAIGNANT** (marge
d'environ 1,5 Gio au repos, mémoire quasi épuisée pendant un build).

Les paragraphes matériels suivants décrivent l'inventaire préalable.

Le poste Windows 11 Pro 25H2 x64 possède un Core Ultra 7 165U (12 cœurs,
14 processeurs logiques), 16 Gio de RAM, un GPU Intel intégré et un SSD NVMe.
C: dispose d'environ 97,2 Gio libres ; seulement 1,09 à 1,22 Gio de RAM
étaient disponibles pendant l'inventaire. Hyper-V/VMP sont actifs, WHP est
désactivée : un premier AVD reste À TESTER après préparation autorisée.
Quatre ou six AVD simultanés sont déconseillés ; les téléphones complètent
le banc. Les indicateurs CIM CPU ne justifient aucun changement BIOS.

Node/npm, Java, Git et VS Code sont présents. Flutter/Dart, Android Studio
et SDK Android sont absents. Seuls des téléphones Android physiques sont
actuellement disponibles ; leur matrice à compléter est dans l'inventaire.
Aucune détection de téléphone n'a été tentée. Aucun iPhone ni Mac local :
cela ne bloque pas le début Android du LOT 0.

**Banc recommandé sur ce poste : 1 AVD simultané maximum en usage courant**,
complété par les appareils Android physiques. L'AVD peut jouer le rôle
maître ou joueur selon le parcours. Avant les campagnes AVD, alléger les
applications utilisateur non nécessaires et mesurer la mémoire disponible,
selon [DEV_ENVIRONMENT.md](../operations/DEV_ENVIRONMENT.md).
Les essais virtuels couvrent flux,
concurrence, projections, curseurs, persistance, reprise et charge, sans
remplacer les validations matérielles LAN/mDNS, permissions, QR, audio,
arrière-plan, hotspot et suspension. Le nombre d'AVD ne remplace pas le
nombre total de clients des campagnes.

Baseline de préparation vérifiée : Android 17/API 37, Studio Quail 4
2026.1.4 et Emulator 37.1.11 stables, image téléphone API 37 avec au moins
4 Go. Distinguer cette version d'exécution du SDK API 36 encore demandé
par le guide Flutter consulté. Révisions et compatibilités finales seront
contrôlées avant installation ; ni preview ni sous-version imposée sans besoin.

La future étude iOS est élargie dans DEV_ENVIRONMENT.md : BrowserStack,
Corellium, TestingBot et Sauce Labs en priorité, autres offres secondaires,
Mac/Xcode distant conforme et iPhone local ultérieur. Aucune offre choisie.
Séparer compilation, exécution, IP/WebSocket, tunnel éventuel, permissions,
Bonjour/mDNS LAN réel et comportement réseau/background matériel. Un cloud
ne vaut pas un iPhone sur le LAN. La validation iOS physique reste nécessaire
avant validation finale de stack. Référence observée : Xcode 26.6 / SDK iOS
26.5 ; Xcode 27 RC exclu du départ stable. Aucun besoin d'installer iOS ici.

Flutter et React Native restent finalistes. Flutter est seulement le premier
candidat recommandé pour expérimentation. Après son POC, une décision humaine
précisera si la comparaison React Native reste nécessaire ; ne pas installer
les deux écosystèmes dès le départ. Les prérequis de chacun sont documentés
sans choisir définitivement de stack.

## 2. Frontières proposées — RECOMMANDATION

| Composant logique | Responsabilité | Frontière à vérifier |
|---|---|---|
| Domaine artificiel | Résolution déterministe, état, échéances | Aucun accès UI, réseau ou stockage système |
| Service de session maître | Authentifier, autoriser, ordonner les commandes | Seul point de mutation officielle |
| Persistance maître | État, journal et déduplication durables | Commit avant diffusion ou confirmation acquise |
| Projection | Construire explicitement les données autorisées | Jamais de sérialisation directe d'un objet maître |
| Transport et découverte | Trouver puis authentifier le maître, échanger | La découverte ne constitue pas une preuve d'identité |
| Client joueur | Intentions, projection, cache privé et reprise | Aucun état officiel localement inventé |
| Adaptateurs mobiles | Caméra QR, audio, cycle de vie, réseau et fichiers 24 | Permissions finales conformes à l'ADR-0002 |
| Diagnostic local | Erreurs et mesures de campagne | Aucun secret dans les logs joueurs ou service tiers |

Ces frontières sont logiques ; elles ne prescrivent ni dossiers logiciels,
ni bibliothèques, ni un nombre de binaires. SQLite reste une recommandation.
Un codebase commun et probablement une application à deux rôles restent à tester.

## 3. INTERVENTION_ALPHA — valeurs ACTÉES POUR LE LOT 0

P1 et P2 participent à une intervention fictive. Chaque personnage possède
une information initiale privée, une petite réserve artificielle de points
d'action de 2 et un état propre. Ils peuvent appartenir à
des groupes destinataires distincts, sans partage automatique des informations.
Les groupes et destinataires des tests complémentaires seront précisés
pendant la conception/implémentation initiale, avant le test concerné.

Le scénario contient un secret MJ, un indice physique identifié par QR,
une image associée, une information privée, une échéance temporelle, un
événement public et un asset audio. Toutes ces données sont synthétiques,
avec des noms et valeurs neutres ; aucune règle réelle ni secret de Drive.

### État initial et ressources synthétiques

| Élément | Valeur |
|---|---|
| Nom technique provisoire | INTERVENTION_ALPHA |
| fictionalTime / tension | 14:00 / 2 |
| P1 | actionPoints = 2 ; INFO_P1_INITIAL |
| P2 | actionPoints = 2 ; INFO_P2_INITIAL |
| Secret MJ | SECRET_MJ_ALPHA |
| Objet identifié par QR | OBJET_ALPHA |
| Information privée associée | INDICE_ALPHA |
| Image | OBJET_ALPHA_IMAGE |
| Échéance | 14:10 |
| Événement public | ALERTE_ALPHA |
| Tension après événement | 4 |
| Audio maître | ALERTE_ALPHA_AUDIO |

À 14:00, la session est démarrée. Parmi les informations privées, P1 ne
connaît que INFO_P1_INITIAL et P2 que INFO_P2_INITIAL ; le MJ connaît
l'ensemble. Temps et tension sont publics. Ces identifiants sont des données
de test, pas un format réseau définitif.

### Parcours principal et oracles

1. P1 scanne le QR : il identifie seulement OBJET_ALPHA, sans INDICE_ALPHA
   ni conséquence secrète.
2. P1 envoie EXAMINER(OBJET_ALPHA), avec le commandId unique C1.
3. Le maître authentifie P1, vérifie son autorisation et sa réserve,
   exécute la résolution déterministe, consomme 1 point et persiste mutation
   et événement correspondant avant diffusion.
4. P1 passe de 2 à 1 point et reçoit INDICE_ALPHA. OBJET_ALPHA_IMAGE peut
   être rendu accessible à P1, uniquement selon son autorisation.
5. P2 ne reçoit ni INDICE_ALPHA ni SECRET_MJ_ALPHA. Les informations
   initiales et celles destinées à un groupe conservent leurs destinataires.
6. La retransmission exacte de C1 ne produit aucune nouvelle mutation,
   aucun coût ni nouvel événement métier ; le résultat reste cohérent avec
   la première exécution.
7. Une deuxième action valide, avec une nouvelle identité de commande,
   fait passer P1 de 1 à 0 point.
8. Une troisième nouvelle action coûtant 1 point est rejetée avec
   RESOURCE_EXHAUSTED, sans mutation officielle.

Le MJ avance explicitement le temps de 14:00 à 14:10. ALERTE_ALPHA est
déclenchée exactement une fois : tension 2 → 4, événement public visible,
ALERTE_ALPHA_AUDIO joué côté maître et état officiel persisté. Une nouvelle
progression ne la déclenche pas une seconde fois. Avant 14:10, aucune donnée
sur les clients ne permet de connaître son contenu futur.

### Incidents et oracles de reprise

**Incident A — joueur déconnecté** : P1 est déconnecté avant 14:10 ; le maître
atteint 14:10 et exécute ALERTE_ALPHA. À son retour, P1 est réauthentifié,
son flux/snapshot resynchronisé, l'état public est à jour et ses informations
privées autorisées sont conservées. Aucun secret P2/MJ n'est reçu ; aucun
événement n'est exécuté deux fois.

**Incident B — maître interrompu** : persister 14:07 puis arrêter le maître.
Au redémarrage, fictionalTime = 14:07 et session = RECOVERY_PAUSED. Aucun
avancement silencieux ni exécution d'ALERTE_ALPHA pendant l'arrêt. Après
reprise explicite MJ et progression jusqu'à 14:10, ALERTE_ALPHA est exécutée
exactement une fois.

Ces résultats sont des **oracles de test**, connus avant exécution. Les
parcours nominal et incidents sont exécutés depuis des états initiaux
réinitialisés et identifiés afin de rendre chaque répétition comparable.

Le parcours exerce les catégories de flux de 24 : temps → intention →
résolution maître → mutation → conséquence → information filtrée → événement.
Il reste entièrement artificiel et déterministe : **il ne valide pas le
moteur réel de résolution de 24**. Les commandes restent synthétiques ;
les détails du banc nécessaires à chaque essai seront précisés avant cet essai.

## 4. Sécurité — principes validés pour le LOT 0

Menace proposée pour les essais : un appareil du LAN peut observer ou
altérer les échanges, annoncer un faux maître, tenter de rejoindre sans
autorisation ou utiliser un client autorisé pour demander un autre personnage.
Le contrôle d'un terminal maître déjà compromis n'est pas démontré par ces essais.

Conserver TLS ou une protection standard équivalente, l'identité du maître
et une donnée de confiance obtenue par QR. Ne pas désactiver la validation
du pair ni inventer de cryptographie. La forme précise de la donnée de
confiance, sa persistance et le mécanisme de vérification restent à préciser.
La faisabilité des API et le choix exact des dépendances restent **À TESTER**,
notamment serveur embarqué, validation de l'identité et permissions sur les
deux stacks. Aucune dépendance concrète n'est imposée.

Séparer le jeton d'enrôlement temporaire du jeton de reprise client.
Le maître associe explicitement le client au personnage ;
le client ne choisit pas seul son autorisation. Examiner durée, usage unique,
révocation et persistance pendant la conception/implémentation initiale,
avant le test qui en dépend. Aucun jeton dans les logs.
Le QR de jeu ne transporte jamais une réponse secrète ; le QR de connexion
peut porter la donnée de confiance et l'authentification temporaire nécessaires.

Essais attendus : faux maître refusé, client inconnu refusé, accès croisé
refusé, trafic protégé contre les attaques retenues, reprise réauthentifiée.
Le mécanisme définitif de production demeure ouvert.

## 5. Synchronisation — ACTÉ POUR LE LOT 0

Conserver une séquence globale dans le journal maître, comme ordre officiel
interne, et un curseur propre au flux autorisé de chaque client/projection.
Le curseur représente la progression de **SON FLUX AUTORISÉ** ; il n'est pas
la séquence globale exposée telle quelle. Cela évite que ses trous révèlent
le nombre ou l'existence d'événements privés des autres.
Cette convention est **ACTÉE POUR LE LOT 0**, pas un format définitif du
protocole produit.

### Raccord conceptuel à préciser pendant la conception/implémentation initiale

- **Événement global vers flux client** : le maître évalue les destinataires
  et construit une information explicitement autorisée. Un événement sans
  effet autorisé pour ce client ne produit pas d'entrée dans son flux.
- **Progression** : le curseur avance sur les entrées de ce flux, jamais sur
  les événements secrets omis. Une retransmission ne crée pas une nouvelle
  progression logique. La persistance de la correspondance reste à concevoir.
- **Snapshot et flux** : produire une projection cohérente associée à un
  point du flux client ; reprendre les entrées suivantes sans perte ni
  duplication, y compris si des commandes arrivent pendant ce raccord.
- **Visibilité tardive** : une révélation ou un changement de groupe doit
  produire une nouvelle information autorisée au moment concerné, sans
  recopier automatiquement l'ancien événement maître complet.
- **Rejeu historique** : ne rejouer que des informations autorisées, jamais
  un ancien payload maître supposé sûr par son seul type ou destinataire.
  Si l'historique ne permet pas de garantir cette autorisation, utiliser un
  snapshot filtré cohérent. Les règles de changement de visibilité et les
  conditions de ce fallback restent à préciser avant le test qui en dépend.

Ces principes décrivent le comportement attendu ; numérotation, stockage,
accusés et format réseau restent des contrats expérimentaux à préparer.

La reprise doit assurer une frontière cohérente entre snapshot et flux :
aucun événement perdu ou appliqué deux fois pendant leur transition.
Proposition de déduplication : identifier une commande dans le contexte de
session et du client authentifié ; conserver son résultat durablement avec
la mutation. Une réutilisation de l'identifiant avec un contenu différent
doit être détectée. Durée de rétention et accusés expérimentaux restent ouverts.

## 6. Reprise et reconnexion

Appliquer les décisions du plan LOT 0 : dernière heure fictive persistée,
récupération en pause, reprise explicite MJ. Aucun ajustement temporel
automatique ; `RECOVERY_PAUSED` reste un nom provisoire.

Maximum cinq tentatives automatiques. La temporisation et le backoff restent
à proposer pendant l'implémentation initiale, avant le test concerné.
Une tentative réussit après authentification et
resynchronisation exacte, jamais au seul retour du socket.
Après épuisement : cache nécessaire conservé, état déconnecté visible,
nouvelle tentative possible. Ne pas rejouer aveuglément une intention dont
le statut est inconnu : réutiliser son identité pour résoudre l'incertitude.

Inclure les coupures avant commit, après commit avant réponse et pendant
snapshot/rejeu, puis les arrêts complets maître/client. Les commandes
concurrentes doivent aboutir à un ordre officiel unique.

## 7. Permissions, données et import

Tester séparément code présent, permissions déclarées, accès effectifs et
données conservées. L'import maître de données 24 est légitime ; il ne
donne aucun droit de parcourir les contenus personnels du téléphone.
Le mécanisme d'import sera comparé selon cette contrainte, sans le choisir ici.

Avant toute qualification d'une stack, contrôler l'artefact final par
allowlist. Les noms précis des permissions et entitlements sont à établir
sur les SDK retenus et les builds observés, sans nouvelle permission implicite.
Demander la caméra au premier besoin pertinent ; scanner le flux sans Photos.
Vérifier sandbox et absence de secrets non autorisés dans caches et journaux.

## 8. Campagnes et ordre de préparation — RECOMMANDATION validée

1. Confirmer les appareils et moyens de build disponibles ; vérifier les
   prérequis officiels et versions des outils avant toute installation.
2. Préciser les conventions expérimentales de sécurité et synchronisation
   selon les principes validés et le curseur par flux acté pour le LOT 0.
3. Définir les états attendus du mini-scénario et les diagnostics d'erreur.
4. Préparer les contrats expérimentaux et le plan d'injection d'incidents.
5. Préparer les charges, durées, répétitions et mesures des campagnes ci-dessous,
   sans seuil artificiel de performance préalable.
6. Après autorisation d'implémenter, réaliser le POC Flutter ; si la comparaison
   React Native est décidée ensuite, réutiliser les mêmes parcours et mesures.
   Confirmer sur matériel les capacités mobiles pour toute stack évaluée.

### Campagnes retenues pour le LOT 0

| Campagne | Configuration | Durée / charge | Répétitions | Couverture |
|---|---|---|---|---|
| A — Fonctionnelle | 1 maître + 2 clients | Parcours complet INTERVENTION_ALPHA, sans durée imposée | 10 parcours complets | Nominal, incidents A/B, secrets, idempotence, reconnexion et récupération |
| B — Endurance | 1 maître + 4 clients | 2 heures ; environ 500 commandes/événements au total par campagne | 3 campagnes | Activité régulière, déconnexions/reconnexions, événements, répétitions et concurrence modérée |
| C — Charge cible | 1 maître + 6 clients | 1 heure ; environ 1 000 opérations par campagne | 3 campagnes | Salves concurrentes, déconnexions/reconnexions, snapshot/rejeu, événements et duplications intentionnelles |

Pour la reproductibilité, consigner et réutiliser entre stacks la même
configuration initiale, le même programme de charge et le même calendrier
d'incidents. Documenter les identités et autorisations des clients additionnels,
le décompte exact commandes/événements/opérations, la réinitialisation et les
moyens de maintenir la charge malgré la réserve limitée du micro-scénario.
Ces détails du banc seront précisés pendant l'implémentation initiale avant
les campagnes B/C, sans modifier implicitement les oracles d'INTERVENTION_ALPHA.
Les totaux approximatifs sont des cibles ; enregistrer les totaux réalisés.

### Mesures de chaque campagne

- stack testée et version de l'application ;
- appareil ou AVD, OS/API et rôle maître/joueur ;
- durée, nombre de clients, commandes et événements ;
- incidents provoqués et pertes de connexion ;
- nombre de tentatives et méthode de récupération (replay ou snapshot) ;
- temps de reconnexion réseau et de resynchronisation complète ;
- duplications, pertes, divergences et fuites observées ;
- erreurs et mémoire/CPU lorsque pertinent.

Définir t0 = perte détectée, t1 = connexion réauthentifiée,
t2 = resynchronisation terminée. Mesurer :

- networkRecoveryTime = t1 − t0 (inclut ici la réauthentification) ;
- fullRecoveryTime = t2 − t0.

En cas d'échec, conserver les tentatives et l'absence de t1/t2, sans inventer
une durée de réussite. Comparer des mesures de durée cohérentes par essai.
Ne fixer aucun seuil artificiel de performance à ce stade : observer d'abord
les résultats des candidates.

### Acceptation fonctionnelle

L'acceptation fonctionnelle reste 100 % des opérations requises correctes
dans les campagnes définies, sans extrapolation statistique universelle.
Cela impose aucune perte d'état, duplication, fuite ou perte d'événement
obligatoire, et un état client autorisé correct après resynchronisation.
Une divergence persistante constitue un échec. Aucun résultat n'est observé
à cette étape. Les tests matériels et de sécurité ne sont pas remplacés par
des tests de domaine ou des simulateurs.

## 9. État de sortie de cette préparation

Les frontières logiques et l'ordre de préparation restent recommandés.
Le micro-scénario et les principes de sécurité sont validés ; le curseur par
flux est acté pour le LOT 0. Les détails ouverts ne bloquent pas cette mise à jour.
L'inventaire et le plan minimal d'installation sont maintenant disponibles dans
[DEV_ENVIRONMENT.md](../operations/DEV_ENVIRONMENT.md). Les modèles Android
restent à compléter sans bloquer l'installation. Les limites AVD et la faible RAM
libre sont documentées dans l'inventaire et le suivi d'installation.
L'installation réelle a depuis validé doctor et le build Android temporaire ;
WHP a été activée et validée après redémarrage supervisé. Le premier AVD a
été qualifié VIABLE MAIS CONTRAIGNANT, ce qui confirme la recommandation d'un
seul AVD simultané et le recours prioritaire aux téléphones physiques.
L'étude iOS reste à faire avant les essais concernés ; l'absence d'iPhone
ne bloque pas le démarrage Android du LOT 0.

**À préciser pendant la conception/implémentation initiale du LOT 0, avant
le test qui en dépend** : cycle de vie exact des jetons, persistance détaillée
des curseurs, raccord exact snapshot/flux, visibilité tardive, déduplication,
temporisations et contrats réseau expérimentaux. Ces détails ne doivent plus
être entièrement finalisés avant tout codage. Les invariants sont suffisants
pour préparer l'implémentation ; Codex proposera les solutions concrètes au
fur et à mesure, sans en faire un protocole produit définitif.
Ne pas rouvrir le choix du
curseur par flux ni la limite des cinq tentatives déjà retenus pour le POC.
La progression interscénarios, la distribution définitive et la récupération
produit restent ouvertes. Aucun de ces sujets n'est décidé par ce document.
