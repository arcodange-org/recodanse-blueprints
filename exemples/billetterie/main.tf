# Exemple : la billetterie « Billets du Quai » (un nom fictif), avec la connexion de ses clients.
#
# Ici le module est lu dans ce dépôt (chemin relatif). Depuis un autre dépôt :
#   source = "git::https://github.com/arcodange-org/recodanse-blueprints.git//modules/billetterie?ref=v0.1.0"
#
# Se connecter d'abord : recodanse-connexion connexion --environnement qa
# (le fournisseur lit ~/.config/recodanse/jeton, ou RECODANSE_JETON en CI).

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    recodanse = { source = "arcodange-org/recodanse", version = ">= 0.2.0, < 1.0.0" }
    time      = { source = "hashicorp/time", version = ">= 0.9.0" }
    vault     = { source = "hashicorp/vault", version = ">= 4.0.0" }
  }
}

provider "recodanse" {
  environnement = "qa"
}

module "billets_du_quai" {
  source = "../../modules/billetterie"

  nom         = "Billets du Quai"
  site_web    = "https://billets-du-quai.example"
  webhook_url = "https://billets-du-quai.example/webhooks/recodanse"

  connexion = {
    redirections = ["https://billets-du-quai.example/retour"]
  }
}

output "dates" {
  value = module.billets_du_quai.dates
}
