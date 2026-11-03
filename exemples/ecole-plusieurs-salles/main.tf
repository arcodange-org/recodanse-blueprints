# Exemple : « L'École des Trois Salles » (un nom fictif) : une application pour trois salles.
#
# Ici le module est lu dans ce dépôt (chemin relatif). Depuis un autre dépôt :
#   source = "git::https://github.com/arcodange-org/recodanse-blueprints.git//modules/ecole-plusieurs-salles?ref=v0.1.0"
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

module "ecole" {
  source = "../../modules/ecole-plusieurs-salles"

  nom = "L'École des Trois Salles"
  salles = [
    { cle = "grande", nom = "La grande salle" },
    { cle = "miroirs", nom = "La salle des miroirs" },
    { cle = "jardin", nom = "Le jardin d'hiver" },
  ]
  webhook_url = "https://ecole.example/webhooks/recodanse"
  # dac7_suspendu = true (défaut) : le plan avertit que les créneaux sont rangés, pas montrés.
}

output "salles" {
  value = module.ecole.salles
}
