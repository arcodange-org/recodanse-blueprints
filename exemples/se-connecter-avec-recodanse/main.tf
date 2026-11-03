# Exemple : « Se connecter avec ReCoDanse » sur le site d'un agrégateur de soirées.
#
# Ici le module est lu dans ce dépôt (chemin relatif). Depuis un autre dépôt :
#   source = "git::https://github.com/arcodange-org/recodanse-blueprints.git//modules/se-connecter-avec-recodanse?ref=v0.1.0"
#
# Se connecter d'abord : recodanse-connexion connexion --environnement qa
# (le fournisseur lit ~/.config/recodanse/jeton, ou RECODANSE_JETON en CI).

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    recodanse = { source = "arcodange-org/recodanse", version = ">= 0.2.0, < 1.0.0" }
  }
}

provider "recodanse" {
  environnement = "qa"
}

module "connexion" {
  source = "../../modules/se-connecter-avec-recodanse"

  nom          = "Le Bal des Soirées"
  site_web     = "https://soirees.example"
  redirections = ["https://soirees.example/retour"]
  # « profile » donne le prénom public : la revue exige d'écouter l'effacement.
  portees     = ["openid", "profile"]
  webhook_url = "https://soirees.example/webhooks/recodanse"
}

output "client_id" {
  value = module.connexion.client_id
}
