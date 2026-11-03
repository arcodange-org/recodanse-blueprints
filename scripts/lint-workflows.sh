#!/usr/bin/env bash
# actionlint sur les workflows de la forge. Un seul message est ignoré, nommé :
# upload-artifact@v3, imposé par Gitea Actions (voir ci.yml).
# Codes : 0 vert ; 1 actionlint rouge ; 2 actionlint introuvable (rien n'est mesuré).
set -uo pipefail
cd "$(dirname "$0")/.."
AL="${ACTIONLINT:-$(command -v actionlint || echo "$HOME/go/bin/actionlint")}"
[ -x "$AL" ] || { echo "lint-workflows : actionlint introuvable" >&2; exit 2; }
"$AL" -ignore 'the runner of "actions/upload-artifact@v3" action is too old' .gitea/workflows/*.yml
