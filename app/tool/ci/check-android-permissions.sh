#!/usr/bin/env bash
# Contrôle des permissions déclarées par un APK Android (ADR-0002).
#
# Usage : check-android-permissions.sh <fichier.apk> <allowlist>
#
# Compare strictement les entrées `uses-permission*` et `permission` du
# manifeste final (dépendances comprises) à l'allowlist :
#   - entrée observée absente de l'allowlist -> échec (code 1) ;
#   - entrée de l'allowlist non observée     -> échec (code 1), pour garder
#     l'allowlist exacte.
#
# Format de l'allowlist : une entrée par ligne, `<type> <nom>`, où <type> vaut
# `uses-permission`, `uses-permission-sdk-23` ou `permission`. `${applicationId}`
# est remplacé par l'identifiant du package. `#` introduit un commentaire.
#
# aapt2 : variable AAPT2, sinon version la plus récente sous
# $ANDROID_HOME/build-tools (ou $ANDROID_SDK_ROOT).
set -euo pipefail
export LC_ALL=C

if [[ $# -ne 2 ]]; then
  echo "Usage : $0 <fichier.apk> <allowlist>" >&2
  exit 2
fi
apk=$1
allowlist=$2
[[ -f "$apk" ]] || { echo "APK introuvable : $apk" >&2; exit 2; }
[[ -f "$allowlist" ]] || { echo "Allowlist introuvable : $allowlist" >&2; exit 2; }

aapt2=${AAPT2:-}
if [[ -z "$aapt2" ]]; then
  sdk=${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}
  [[ -n "$sdk" ]] || { echo "ANDROID_HOME ou AAPT2 requis" >&2; exit 2; }
  aapt2=$(ls -d "$sdk"/build-tools/*/aapt2 "$sdk"/build-tools/*/aapt2.exe 2>/dev/null | sort -V | tail -n 1 || true)
fi
[[ -n "$aapt2" && -x "$aapt2" ]] || { echo "aapt2 introuvable" >&2; exit 2; }

package=$("$aapt2" dump packagename "$apk" | tr -d '\r')
dump=$("$aapt2" dump permissions "$apk" | tr -d '\r')

observed=$(printf '%s\n' "$dump" | sed -nE \
  -e "s/^(uses-permission(-sdk-23)?): name='([^']+)'.*/\1 \3/p" \
  -e "s/^permission: ([^ ]+).*/permission \1/p" | sort -u)

allowed=$(sed -e 's/#.*$//' -e 's/[[:space:]]\+/ /g' -e 's/^ //' -e 's/ $//' "$allowlist" \
  | tr -d '\r' | { grep -v '^$' || true; } | sed "s/\${applicationId}/$package/g" | sort -u)

unexpected=$(comm -23 <(printf '%s\n' "$observed") <(printf '%s\n' "$allowed") | grep -v '^$' || true)
missing=$(comm -13 <(printf '%s\n' "$observed") <(printf '%s\n' "$allowed") | grep -v '^$' || true)

echo "APK        : $apk"
echo "Package    : $package"
echo "aapt2      : $aapt2"
echo "Observées  :"
printf '%s\n' "$observed" | sed '/^$/d; s/^/  /'

status=0
if [[ -n "$unexpected" ]]; then
  echo "ÉCHEC — entrées absentes de l'allowlist (décision explicite requise, ADR-0002) :"
  printf '%s\n' "$unexpected" | sed 's/^/  + /'
  status=1
fi
if [[ -n "$missing" ]]; then
  echo "ÉCHEC — entrées de l'allowlist non observées (mettre l'allowlist à jour) :"
  printf '%s\n' "$missing" | sed 's/^/  - /'
  status=1
fi
[[ $status -eq 0 ]] && echo "OK — permissions conformes à l'allowlist."
exit $status
