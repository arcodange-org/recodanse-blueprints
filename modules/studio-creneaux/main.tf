# Le studio publie ses cours réguliers (créneaux, tarifs) ; ses élèves se
# connectent au site avec ReCoDanse, sans compte de plus.

module "creneaux" {
  source = "../publier-des-evenements"

  nom            = "${var.nom} — créneaux"
  description    = "Publie les cours réguliers de ${var.nom} (horaires, tarifs)."
  site_web       = var.site_web
  portees        = var.publie_aussi_des_evenements ? ["creneaux.publier", "evenements.publier"] : ["creneaux.publier"]
  rotation_jours = var.rotation_jours
  rotation       = var.rotation
  coffre         = var.coffre

  soumettre              = var.soumettre
  accepte_les_conditions = var.accepte_les_conditions
}

module "connexion" {
  source = "../se-connecter-avec-recodanse"
  count  = var.connexion == null ? 0 : 1

  nom          = var.nom
  site_web     = var.site_web
  redirections = var.connexion.redirections
  publique     = var.connexion.publique
  portees      = var.connexion.portees
  webhook_url  = var.connexion.webhook_url
  rotation     = var.connexion.publique || length(module.creneaux.rotation) == 0 ? null : module.creneaux.rotation

  soumettre              = var.soumettre
  accepte_les_conditions = var.accepte_les_conditions
}

resource "vault_kv_secret_v2" "connexion" {
  count = var.coffre != null && var.connexion != null ? 1 : 0

  mount = var.coffre.mount
  name  = "${var.coffre.chemin}/connexion"
  data_json = jsonencode({
    client_id      = module.connexion[0].client_id
    client_secret  = module.connexion[0].client_secret
    webhook_secret = module.connexion[0].webhook_secret
  })
}

# Un AVERTISSEMENT, pas une erreur : la déclaration se fait, les créneaux se
# rangent — ils ne se montrent pas encore aux danseurs.
check "creneaux_suspendus_dac7" {
  assert {
    condition     = !var.dac7_suspendu
    error_message = "Les créneaux publiés sont RANGÉS par ReCoDanse mais pas encore MONTRÉS : la publication des créneaux est suspendue le temps d'un avis juridique (DAC7). L'API le dit (publies: false, raison publication_suspendue_dac7). Passe dac7_suspendu à false quand dev.recodanse.fr annonce la levée."
  }
}
