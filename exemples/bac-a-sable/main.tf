# Exemple : le bac à sable : éprouver son webhook d'effacement avant la revue.
#
# Ici le module est lu dans ce dépôt (chemin relatif). Depuis un autre dépôt :
#   source = "git::https://github.com/arcodange-org/recodanse-blueprints.git//modules/bac-a-sable?ref=v0.1.0"
#
# Se connecter d'abord : recodanse-connexion connexion --environnement qa
# (le fournisseur lit ~/.config/recodanse/jeton, ou RECODANSE_JETON en CI).

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    recodanse = { source = "arcodange-org/recodanse", version = ">= 0.2.0, < 1.0.0" }
  }
}

# Le bac à sable SEULEMENT — ailleurs, les comptes fictifs et l'événement se
# refusent dès le plan. Ses adresses sont à confirmer : on les donne.
provider "recodanse" {
  environnement = "bac-a-sable"
  api           = "https://bac-a-sable.recodanse.fr"           # à confirmer
  emetteur      = "https://connexion.bac-a-sable.recodanse.fr" # à confirmer
  jeton_fichier = pathexpand("~/.config/recodanse/jeton-bac")
}

module "essai" {
  source = "../../modules/bac-a-sable"

  nom         = "Essai de mon site"
  webhook_url = "https://mon-site.example/webhooks/recodanse"
  # 1er apply : declencher = false. Puis « Autoriser » au nom du compte fictif.
  # 2e apply : -var declencher=true.
  declencher = var.declencher
}

variable "declencher" {
  type    = bool
  default = false
}

output "comptes_fictifs" {
  value = module.essai.comptes_fictifs
}
