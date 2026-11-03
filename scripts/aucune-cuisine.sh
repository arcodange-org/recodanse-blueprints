#!/usr/bin/env bash
# Garde la documentation publique : aucun renvoi à l'organisation interne du
# projet (tickets, lots, règles d'une spécification interne, hôtes privés, notes
# de travail) dans les fichiers suivis. Balaie `git ls-files`, hors `.gitea/`
# (la CI de la forge d'origine, dont l'hôte est fonctionnel) et hors ce script.
#
#   scripts/aucune-cuisine.sh
#
# Codes : 0 propre ; 1 au moins une ligne trouvée (la liste suit, motif par motif) ;
#         2 rien n'a été mesuré (outil absent, aucun fichier lu, un motif aveugle
#         à son propre témoin). Un 2 n'est jamais un vert.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

command -v git >/dev/null || { echo "aucune-cuisine : git est introuvable" >&2; exit 2; }
command -v grep >/dev/null || { echo "aucune-cuisine : grep est introuvable" >&2; exit 2; }

# Chaque motif a ses options de grep et un TÉMOIN : une phrase qu'il DOIT trouver.
# Un motif qui ne trouve pas son témoin serait vert pour toujours : le script
# s'arrête alors en 2. Les motifs s'écrivent en ERE portable (ni \b ni \d : la
# CI tourne sous GNU grep, un poste sous BSD grep), et une lettre accentuée
# s'écrit dans ses deux casses : `-i` ne replie pas « É » sur « é » partout.
NOMS=()
OPTIONS=()
MOTIFS=()
TEMOINS=()
motif() { NOMS+=("$1"); OPTIONS+=("$2"); MOTIFS+=("$3"); TEMOINS+=("$4"); }

motif "fondateur"            "-i" 'fondat(eur|rice)'                                     "après le oui du fondateur"
motif "numéro de lot"        ""   '(^|[^[:alnum:]_])L[0-9]{2,4}([^[:alnum:]_]|$)'        "(lot L263)"
motif "dépôt interne"        "-i" 'kadans(-api|-dossier|-admin|-jobs|#)'                 "(kadans-api#407)"
motif "ticket d'un dépôt"    ""   '[[:alnum:]_-]#[0-9]+'                                 "(factory#107)"
motif "fiche de spec"        "-i" 'fiche [0-9]'                                          "(fiche 52 § H)"
motif "règle de spec"        ""   '(^|[^[:alnum:]_])RG-[0-9]'                            "(RG-94)"
motif "étude de cas"         "-i" '[ÉéEe]tudes? de cas|etude-de-cas'                    "| Étude de cas |"
motif "cas numéroté"         "-i" '(^|[^[:alnum:]_])cas [0-9]'                            "cas 6 « Billets du Quai »"
motif "agent"                "-i" 'haiku'                                                "testé par un agent Haiku"
motif "session de travail"   "-i" '(^|[^[:alnum:]_])sessions?([^[:alnum:]_]|$)'          "la session qui implémente"
motif "passation"            "-i" 'passation'                                            "voir la passation"
motif "recette"              "-i" 'recette'                                              "en recette"
motif "hôte privé"           "-i" 'arcodange\.lab'                                       "https://gitea.arcodange.lab/x"
motif "run de CI"            "-i" 'run [0-9]{4,}'                                        "(run 14429)"
motif "état daté"            "-i" '([ÉéEe]tat|[Dd][ée]cision|[Aa]rbitrage) (au|du) 20[0-9]{2}-[01][0-9]-[0-3][0-9]' "État au 2026-11-02"

# Le témoin d'abord : un motif qui ne mord pas sur sa propre phrase est un instrument mort.
for i in "${!MOTIFS[@]}"; do
  # shellcheck disable=SC2086 # OPTIONS[i] est vide ou une seule option
  printf '%s\n' "${TEMOINS[$i]}" | grep -Eq ${OPTIONS[$i]} -e "${MOTIFS[$i]}"
  c=$?
  [ $c -eq 0 ] || { echo "aucune-cuisine : le motif « ${NOMS[$i]} » ne trouve pas son témoin (code $c) — instrument aveugle" >&2; exit 2; }
done

FICHIERS=()
while IFS= read -r f; do
  [ -f "$f" ] && [ -r "$f" ] && FICHIERS+=("$f")
done < <(git ls-files -- . ':(exclude).gitea/' ':(exclude)scripts/aucune-cuisine.sh')
[ ${#FICHIERS[@]} -gt 0 ] || { echo "aucune-cuisine : aucun fichier suivi lu — rien n'est mesuré" >&2; exit 2; }

TROUVE=0
for i in "${!MOTIFS[@]}"; do
  # shellcheck disable=SC2086
  sortie="$(grep -nHE ${OPTIONS[$i]} -e "${MOTIFS[$i]}" -- "${FICHIERS[@]}")"
  c=$?
  case $c in
    0) TROUVE=1; echo "── ${NOMS[$i]} (${MOTIFS[$i]})"; printf '%s\n' "$sortie" ;;
    1) ;;
    *) echo "aucune-cuisine : grep a échoué sur « ${NOMS[$i]} » (code $c) — rien n'est mesuré" >&2; exit 2 ;;
  esac
done

if [ $TROUVE -eq 0 ]; then
  echo "aucune-cuisine : propre (${#FICHIERS[@]} fichiers, ${#MOTIFS[@]} motifs, chaque témoin trouvé)"
  exit 0
fi
echo "aucune-cuisine : ROUGE — reformule ces lignes pour un lecteur extérieur au projet" >&2
exit 1
