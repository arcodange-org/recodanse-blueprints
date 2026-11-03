# Exemple : tous les secrets d'un tiers tournent ensemble et partent dans Vault.
#
# Ici le module est lu dans ce dépôt (chemin relatif). Depuis un autre dépôt :
#   source = "git::https://github.com/arcodange-org/recodanse-blueprints.git//modules/rotation-vers-un-coffre?ref=v0.1.0"
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

# VAULT_ADDR et l'identité viennent de l'environnement (en CI : JWT/OIDC).
provider "vault" {}

variable "fuite" {
  description = "Une date (AAAA-MM-JJ) pour tout faire tourner tout de suite — procédure « un jeton a fui »."
  type        = string
  default     = null
}

module "secrets" {
  source = "../../modules/rotation-vers-un-coffre"

  connexion = {
    nom          = "Billets du Quai"
    redirections = ["https://billets-du-quai.example/retour"]
  }
  service = {
    nom = "Billets du Quai — dates"
  }
  rotation_jours = 90
  rotation       = var.fuite == null ? {} : { fuite = var.fuite }
  coffre         = { mount = "kv", prefixe = "recodanse/billets-du-quai" }
}

output "chemins_dans_le_coffre" {
  value = module.secrets.chemins_dans_le_coffre
}
