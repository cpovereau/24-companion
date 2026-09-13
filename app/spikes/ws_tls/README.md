# Spike jetable — serveur WebSocket TLS embarqué

> **Code jetable** : hors workspace Dart, exclu de la CI, jamais réutilisé tel
> quel dans `app/packages/`. Il sert à lever tôt un risque de faisabilité de la
> tranche T4 (`doc/dev/architecture/LOT0_POC_CONCEPTION.md` §4 et §7).

## Questions posées

1. Une application Flutter Android peut-elle générer sur l'appareil une clé et
   un certificat X.509 auto-signé, sans permission supplémentaire ?
2. Peut-elle héberger un serveur WebSocket sur TLS avec ce certificat ?
3. Un client qui épingle strictement l'empreinte SHA-256 du certificat peut-il
   se connecter, et une autre empreinte est-elle refusée ?
4. Quelles permissions l'APK déclare-t-il réellement ?

## Montage (13 septembre 2026)

| Élément | Valeur |
|---|---|
| Serveur | Application Flutter release sur ANDROID_P01 (Pixel 8a, Android 17 / API 37), `targetSdk` 36 |
| Identité TLS | Clé EC P-256, certificat auto-signé (CN `juste-a-temps-spike`, 1 jour), générés au lancement dans un isolate avec `basic_utils` 5.8.2 / `pointycastle` 4.0.0 |
| Serveur | `HttpServer.bindSecure` (dart:io) sur `0.0.0.0:8443`, mise à niveau WebSocket sur `/ws`, écho JSON |
| Client | `tool/ws_client.dart`, Dart VM sur le PC Windows |
| Épinglage | `SecurityContext(withTrustedRoots: false)` et `badCertificateCallback` n'acceptant que le certificat dont l'empreinte SHA-256 est exactement celle attendue |
| Réseaux | A : USB via `adb forward` (127.0.0.1) ; B : réseau local réel, PC en Ethernet 192.168.1.13 et Pixel en Wi-Fi 192.168.1.16 |

## Résultats

| Mesure / scénario | A — USB | B — réseau local |
|---|---|---|
| Génération clé + certificat sur le Pixel | 40,6 ms | (même instance) |
| 1. Empreinte correcte | Connexion TLS + WebSocket en 93 ms ; 100 échanges ; RTT min 3,7 / médiane 5,2 / max 20,0 ms | Connexion en 415 ms (253 ms au second essai) ; 100 échanges ; RTT min 8,0 / médiane 16,3 / max 52,0 ms |
| 2. Empreinte différente (faux maître simulé) | Refusé : `CERTIFICATE_VERIFY_FAILED` | Refusé : `CERTIFICATE_VERIFY_FAILED` |
| 3. Validation standard sans épinglage | Refusé : `self signed certificate` | Refusé : `self signed certificate` |
| WebSocket en clair (`ws://`) sur le port TLS | --- | Refusé (connexion fermée avant en-têtes) |
| Serveur après refus de poignées de main | --- | Toujours opérationnel ; nouvelle connexion épinglée réussie |

Journal serveur : connexions et déconnexions attendues. Les poignées de main
refusées côté client produisent une erreur non fatale sur le flux du serveur
(`SocketException: Broken pipe`), à traiter comme diagnostic réseau en T4.

**Permissions de l'APK release** (`aapt2 dump permissions`) :
`android.permission.INTERNET` (ADR-0003 A2) et la permission interne AndroidX
(A1). `basic_utils` et `pointycastle` n'ajoutent **aucune** permission.

## Conclusions pour T4

-   **Faisabilité confirmée sur Android** : génération d'identité TLS sur
    l'appareil, serveur WebSocket TLS embarqué, connexion sur le réseau local
    réel et épinglage strict par empreinte avec les API standard de `dart:io`.
    Aucune cryptographie maison ; la validation du pair n'est pas désactivée,
    elle est remplacée par une comparaison exacte à la donnée de confiance.
-   L'épinglage ne dépend pas du nom d'hôte ni de l'adresse IP : compatible
    a priori avec le changement d'adresse (T5), **à tester**.
-   Latences du même ordre que celles attendues pour des commandes de jeu
    (quelques ms à quelques dizaines de ms sur le Wi-Fi domestique).
-   **Dépendances** : `basic_utils` tire `http`, `archive`, `logging` et
    `json_annotation`. Pour les packages du POC, préférer une génération
    limitée à `pointycastle` (ou une bibliothèque plus ciblée) après examen,
    conformément à l'ADR-0002.
-   L'aléa de génération est amorcé par `Random.secure()` via `basic_utils` :
    à revoir lors du choix définitif de la dépendance.

## Non couvert par ce spike

-   iOS (serveur et client) ; client sur téléphone Android ou AVD.
-   `targetSdk` 37 et invite `ACCESS_LOCAL_NETWORK` (ADR-0003 A3).
-   Arrière-plan, verrouillage, hotspot, changement d'IP, plusieurs clients.
-   Persistance et rotation de l'identité, protection de la clé privée,
    jetons d'enrôlement et de reprise, QR de connexion.

## Reproduire

``` shell
flutter build apk --release
adb -d install -r build/app/outputs/flutter-apk/app-release.apk
adb -d shell am start -n io.github.cpovereau.spikes.ws_tls_spike/.MainActivity
adb -d logcat -s flutter:I          # lignes SPIKE| : empreinte et adresses
dart run tool/ws_client.dart <ip-du-pixel> 8443 <empreinte> 100
adb -d shell am force-stop io.github.cpovereau.spikes.ws_tls_spike
```

Arrêter l'application après l'essai : le serveur écoute sur le réseau local.
