# Exemple : « Studio Parquet Clair » (un nom fictif) : ses cours réguliers et la connexion de ses élèves.
#
# Ici le module est lu dans ce dépôt (chemin relatif). Depuis un autre dépôt :
#   source = "git::https://github.com/arcodange-org/recodanse-blueprints.git//modules/studio-creneaux?ref=v0.1.0"
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

module "studio" {
  source = "../../modules/studio-creneaux"

  nom = "Studio Parquet Clair"
  connexion = {
    redirections = ["https://studio.example/retour"]
  }
  # dac7_suspendu = true (défaut) : le plan avertit que les créneaux sont rangés, pas montrés.
}

output "creneaux_visibles" {
  value = module.studio.creneaux_visibles
}
