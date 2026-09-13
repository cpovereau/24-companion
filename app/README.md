# app/ — POC LOT 0 « Juste à temps »

Code du POC technique du LOT 0 de 24. La conception, les tranches et les
règles de dépendance sont décrites dans
[LOT0_POC_CONCEPTION.md](../doc/dev/architecture/LOT0_POC_CONCEPTION.md).

> Flutter est le premier candidat **expérimental** : ce code ne constitue pas
> un choix de stack produit. Les ADR ([ADR-0001](../doc/dev/decisions/ADR-0001-local-session-authority.md),
> [ADR-0002](../doc/dev/decisions/ADR-0002-player-client-privacy.md)) et
> [AGENTS.md](../AGENTS.md) s'appliquent.

## Contenu

| Chemin | Rôle |
|---|---|
| `pubspec.yaml` | Racine du workspace Dart |
| `companion/` | Application Flutter `juste_a_temps` (Android, iOS), rôles maître et joueur à venir |
| `packages/domain/` | `juste_a_temps_domain` : domaine artificiel INTERVENTION_ALPHA, Dart pur (T1) |
| `fixtures/intervention_alpha/` | Données synthétiques du micro-scénario (JSON expérimental) |
| `tool/ci/` | Contrôle des permissions des artefacts (ADR-0002) |
| `packages/` | Packages Dart par frontière logique, créés au fil des tranches |
| `spikes/` | Explorations jetables : hors workspace Dart, exclues de la CI, jamais réutilisées telles quelles |

Identité : package `juste_a_temps`, identifiant Android/iOS
`io.github.cpovereau.justeatemps`, nom affiché « Juste à temps ».

## Prérequis

Flutter 3.47.4 stable (Dart 3.13.3) et chaîne Android décrite dans
[DEV_ENVIRONMENT.md](../doc/dev/operations/DEV_ENVIRONMENT.md).

## Commandes

Depuis `app/` :

``` shell
flutter pub get
dart format --output=none --set-exit-if-changed companion/lib companion/test packages
```

Depuis `app/packages/domain/` :

``` shell
dart analyze --fatal-infos
dart test
```

Depuis `app/companion/` :

``` shell
flutter analyze --fatal-infos
flutter test
flutter build apk --release
```

Contrôle des permissions de l'APK release (bash, `ANDROID_HOME` défini) :

``` shell
tool/ci/check-android-permissions.sh \
  companion/build/app/outputs/flutter-apk/app-release.apk \
  tool/ci/android-permissions.allowlist
```

Toute modification de `tool/ci/android-permissions.allowlist` est une
décision d'architecture (ADR-0002, ADR-0003 à venir). Après un build, arrêter
le daemon Gradle si un AVD doit être lancé (`android/gradlew --stop`).

## CI

Workflow [`app-ci`](../.github/workflows/app-ci.yml) sur `main` et les pull
requests touchant `app/` (hors `app/spikes/`) :

1. format, frontière du domaine (ni `dart:io`, ni Flutter), analyse
   (`--fatal-infos`) et tests du domaine et de l'application ;
2. APK release et comparaison stricte de ses permissions à l'allowlist.

Le build iOS sur runner macOS est reporté.

## État des tranches

| Tranche | État |
|---|---|
| T0 — Socle et CI | Validé le 13 septembre 2026 : CI verte au premier passage ; APK release sans permission système (seule entrée : permission interne AndroidX, à confirmer par l'ADR-0003) |
| T1 — Domaine INTERVENTION_ALPHA | Réalisé : 32 tests d'oracle verts ; étape 6 reportée en T2 (déduplication) ; précisions à valider (`packages/domain/README.md`) |
| Spike WebSocket TLS (`spikes/ws_tls`) | Concluant sur Android le 13 septembre 2026 : identité TLS générée sur le Pixel, serveur WSS, épinglage strict validé par USB et sur le réseau local |
| T2 à T8 | À faire |
