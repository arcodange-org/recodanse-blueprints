# Exemple : un compte de service qui publie des soirées, son secret tourne tous les 90 jours et part dans Vault.
#
# Ici le module est lu dans ce dépôt (chemin relatif). Depuis un autre dépôt :
#   source = "git::https://github.com/arcodange-org/recodanse-blueprints.git//modules/publier-des-evenements?ref=v0.1.0"
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

# VAULT_ADDR et l'identité viennent de l'environnement (jamais un jeton écrit ici).
provider "vault" {}

module "soirees" {
  source = "../../modules/publier-des-evenements"

  nom            = "Le Bal des Soirées — agenda"
  rotation_jours = 90
  coffre         = { mount = "kv", chemin = "recodanse/bal-des-soirees/service" }
}

output "prochaine_rotation" {
  value = module.soirees.prochaine_rotation
}
