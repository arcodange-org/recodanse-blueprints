#!/usr/bin/env bash
# Tout ce que la CI joue, dans l'ordre, chaque code de sortie relevé :
#   1. le miroir local du fournisseur (scripts/construire-le-miroir.sh) ;
#   2. tofu fmt -check -recursive ;
#   3. scripts/aucune-cuisine.sh (la documentation publique ne renvoie à rien d'interne) ;
#   4. pour chaque module : tofu init, tofu validate, tofu test (fournisseurs simulés) ;
#   5. pour chaque exemple : tofu init, tofu validate (aucun plan : aucun jeton).
#
#   scripts/tester.sh                       tout
#   scripts/tester.sh --sans-construire     réutilise .outils/miroir (déjà construit)
#   scripts/tester.sh <module>…             seulement ces modules (et leurs exemples)
#
# Codes : 0 tout est vert ; 1 au moins une étape rouge (le tableau la nomme) ;
#         2 rien n'a été mesuré (outil absent, miroir introuvable). Un 2 n'est
#         jamais un vert ni un rouge du code.
set -uo pipefail

RACINE="$(cd "$(dirname "$0")/.." && pwd)"
cd "$RACINE"

CONSTRUIRE=1
CHOIX=()
for a in "$@"; do
  case "$a" in
    --sans-construire) CONSTRUIRE=0 ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    *) CHOIX+=("$a") ;;
  esac
done

TOFU="${TOFU:-tofu}"
command -v "$TOFU" >/dev/null || { echo "tester : $TOFU est introuvable (OpenTofu ≥ 1.8)" >&2; exit 2; }

if [ "$CONSTRUIRE" = 1 ]; then
  scripts/construire-le-miroir.sh
  c=$?
  [ $c -eq 0 ] || { echo "tester : le miroir n'a pas été construit (code $c) — rien n'est mesuré" >&2; exit 2; }
fi
[ -f .outils/tofurc ] || { echo "tester : .outils/tofurc absent — lance sans --sans-construire" >&2; exit 2; }
export TF_CLI_CONFIG_FILE="$RACINE/.outils/tofurc"
export TF_IN_AUTOMATION=1
export CHECKPOINT_DISABLE=1
# Aucun jeton n'est utile ici : le retirer garantit qu'aucun essai ne parle à ReCoDanse.
unset RECODANSE_JETON RECODANSE_JETON_FICHIER VAULT_TOKEN

JOURNAL="$RACINE/.outils/journaux"
rm -rf "$JOURNAL" && mkdir -p "$JOURNAL"
RESULTATS=()
ROUGE=0

etape() { # etape <nom> <dossier> <commande…> — journal complet dans .outils/journaux, jamais tronqué
  local nom="$1" dossier="$2"; shift 2
  local f="$JOURNAL/$(echo "$nom" | tr ' /' '__').log"
  ( cd "$dossier" && "$@" ) > "$f" 2>&1
  local c=$?
  # Témoin d'instrument : un `tofu test` vert doit avoir JOUÉ au moins un run.
  if [ $c -eq 0 ] && [ "${2:-}" = "test" ] && ! grep -Eq 'Success! [1-9][0-9]* passed, 0 failed' "$f"; then
    echo "tester : « $nom » rend 0 sans avoir joué un seul run — instrument aveugle" >> "$f"
    c=1
  fi
  RESULTATS+=("$(printf '%-4s %-46s %s' "$c" "$nom" "${f#$RACINE/}")")
  if [ $c -ne 0 ]; then
    ROUGE=1
    echo "── ROUGE ($c) : $nom — $f" >&2
    cat "$f" >&2
  fi
  return $c
}

etape "fmt -check -recursive" . "$TOFU" fmt -check -recursive -no-color
etape "aucune cuisine" . scripts/aucune-cuisine.sh

modules=()
if [ ${#CHOIX[@]} -gt 0 ]; then
  modules=("${CHOIX[@]}")
else
  for d in modules/*/; do modules+=("$(basename "$d")"); done
fi

for m in "${modules[@]}"; do
  d="modules/$m"
  [ -d "$d" ] || { echo "tester : module inconnu « $m »" >&2; exit 2; }
  etape "$m · init" "$d" "$TOFU" init -backend=false -input=false -no-color || continue
  etape "$m · validate" "$d" "$TOFU" validate -no-color
  if ls "$d"/tests/*.tftest.hcl >/dev/null 2>&1; then
    etape "$m · test" "$d" "$TOFU" test -no-color
  else
    RESULTATS+=("$(printf '%-4s %-46s %s' "1" "$m · test" "aucun essai : un module sans essai est refusé")")
    ROUGE=1
  fi
  e="exemples/$m"
  if [ -d "$e" ]; then
    etape "exemple $m · init" "$e" "$TOFU" init -backend=false -input=false -no-color || continue
    etape "exemple $m · validate" "$e" "$TOFU" validate -no-color
  fi
done

echo
echo "code étape                                          journal"
printf '%s\n' "${RESULTATS[@]}"
echo
if [ $ROUGE -eq 0 ]; then echo "tester : VERT (${#RESULTATS[@]} étapes)"; else echo "tester : ROUGE"; fi
exit $ROUGE
