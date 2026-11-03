# La billetterie publie ses dates par SA référence
# (publier, reporter, annuler, retirer), et ReCoDanse la prévient quand la
# modération retire une de ses dates — pour qu'elle ne la republie pas chaque nuit.

module "dates" {
  source = "../publier-des-evenements"

  nom            = "${var.nom} — dates"
  description    = "Publie les dates de ${var.nom} (prix indicatif, lien de la page de vente)."
  site_web       = var.site_web
  portees        = ["evenements.publier"]
  rotation_jours = var.rotation_jours
  rotation       = var.rotation
  coffre         = var.coffre

  soumettre              = var.soumettre
  accepte_les_conditions = var.accepte_les_conditions
}

# « publication.retiree » est au catalogue des webhooks (data.recodanse_catalogue,
# evenements_des_webhooks). Un compte de service ne reçoit aucune donnée
# personnelle : il n'écoute ni « autorisation.retiree » ni « compte.efface ».
resource "recodanse_webhook" "publication_retiree" {
  application = module.dates.application_id
  url         = var.webhook_url
  evenements  = ["publication.retiree"]
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
  # Le secret de connexion tourne au même rythme que celui du compte de service.
  rotation = var.connexion.publique || length(module.dates.rotation) == 0 ? null : module.dates.rotation

  soumettre              = var.soumettre
  accepte_les_conditions = var.accepte_les_conditions
}

resource "vault_kv_secret_v2" "webhooks" {
  count = var.coffre == null ? 0 : 1

  mount = var.coffre.mount
  name  = "${var.coffre.chemin}/webhooks"
  data_json = jsonencode({
    publication_retiree = recodanse_webhook.publication_retiree.secret
    effacement          = var.connexion == null ? null : module.connexion[0].webhook_secret
  })
}

resource "vault_kv_secret_v2" "connexion" {
  count = var.coffre != null && var.connexion != null ? 1 : 0

  mount = var.coffre.mount
  name  = "${var.coffre.chemin}/connexion"
  data_json = jsonencode({
    client_id     = module.connexion[0].client_id
    client_secret = module.connexion[0].client_secret
  })
}
