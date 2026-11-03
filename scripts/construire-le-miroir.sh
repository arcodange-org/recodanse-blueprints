#!/usr/bin/env bash
# Construit le fournisseur ReCoDanse depuis son dépôt et le range dans un miroir
# local (.outils/miroir), au chemin que lit `filesystem_mirror`. Écrit aussi la
# configuration du CLI propre au dépôt (.outils/tofurc). Ne touche ni
# ~/.terraformrc ni ~/.terraform.d.
#
#   FOURNISSEUR_SRC      le dépôt du fournisseur (défaut ~/Work/Kadans/terraform-provider-recodanse)
#   FOURNISSEUR_VERSION  la version annoncée au miroir (défaut 0.2.0)
#
# Codes : 0 construit ; 1 la construction a échoué ; 2 un outil ou le dépôt manque (rien n'est mesuré).
set -uo pipefail

RACINE="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${FOURNISSEUR_SRC:-$HOME/Work/Kadans/terraform-provider-recodanse}"
V="${FOURNISSEUR_VERSION:-0.2.0}"
OUTILS="$RACINE/.outils"

command -v go >/dev/null || { echo "construire-le-miroir : go est introuvable" >&2; exit 2; }
[ -f "$SRC/go.mod" ] || { echo "construire-le-miroir : le dépôt du fournisseur est introuvable ($SRC) — donne FOURNISSEUR_SRC" >&2; exit 2; }

PLATEFORME="$(go env GOOS)_$(go env GOARCH)"
DEST="$OUTILS/miroir/registry.opentofu.org/arcodange-org/recodanse/$V/$PLATEFORME"
mkdir -p "$DEST" "$OUTILS/cache"

echo "construire-le-miroir : fournisseur $V ($PLATEFORME) depuis $SRC ($(git -C "$SRC" rev-parse --short HEAD 2>/dev/null || echo '?'))" >&2
( cd "$SRC" && nice -n 15 go build -ldflags "-X main.version=$V" -o "$DEST/terraform-provider-recodanse_v$V" . ) || {
  echo "construire-le-miroir : la construction a échoué" >&2
  exit 1
}

# La même adresse courte (`arcodange-org/recodanse`) se lit registry.opentofu.org
# chez tofu et registry.terraform.io chez terraform : le binaire va dans les deux.
DEST_TF="$OUTILS/miroir/registry.terraform.io/arcodange-org/recodanse/$V/$PLATEFORME"
mkdir -p "$DEST_TF" && cp "$DEST/terraform-provider-recodanse_v$V" "$DEST_TF/"

sed -e "s#@MIROIR@#$OUTILS/miroir#" -e "s#@CACHE@#$OUTILS/cache#" "$RACINE/outils/tofurc.modele" > "$OUTILS/tofurc"
echo "construire-le-miroir : prêt — export TF_CLI_CONFIG_FILE=$OUTILS/tofurc" >&2
