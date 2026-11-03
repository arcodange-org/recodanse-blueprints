# La combinaison « un secret tourné part au coffre dans le même apply » pour
# TOUTES les applications d'un tiers, à un rythme commun.
#
# ⚠ Hydra ne garde qu'UN secret par client : l'ancien cesse de valoir à l'instant
# de la rotation. Le seul ordre sûr est donc celui d'un même apply — tourner, puis
# écrire au coffre — et des consommateurs qui RELISENT le coffre (agent Vault,
# External Secrets) plutôt qu'une copie au démarrage.

resource "time_rotating" "rythme" {
  rotation_days = var.rotation_jours

  lifecycle {
    precondition {
      condition     = var.connexion != null || var.service != null
      error_message = "Donne `connexion`, `service`, ou les deux : sans application, rien ne tourne."
    }
  }
}

locals {
  rotation = merge(var.rotation, { planifiee = time_rotating.rythme.id })
}

module "connexion" {
  source = "../se-connecter-avec-recodanse"
  count  = var.connexion == null ? 0 : 1

  nom          = var.connexion.nom
  redirections = var.connexion.redirections
  portees      = var.connexion.portees
  webhook_url  = var.connexion.webhook_url
  publique     = false # un client public n'a pas de secret à faire tourner
  rotation     = local.rotation
}

module "service" {
  source = "../publier-des-evenements"
  count  = var.service == null ? 0 : 1

  nom            = var.service.nom
  portees        = var.service.portees
  rotation_jours = 0              # le rythme est celui de ce module…
  rotation       = local.rotation # …transmis ici
}

resource "vault_kv_secret_v2" "connexion" {
  count = var.coffre != null && var.connexion != null ? 1 : 0

  mount = var.coffre.mount
  name  = "${var.coffre.prefixe}/connexion"
  data_json = jsonencode({
    client_id      = module.connexion[0].client_id
    client_secret  = module.connexion[0].client_secret
    webhook_secret = module.connexion[0].webhook_secret
  })
  custom_metadata {
    data = {
      application = module.connexion[0].application_id
      tourne_le   = time_rotating.rythme.rfc3339
    }
  }
}

resource "vault_kv_secret_v2" "service" {
  count = var.coffre != null && var.service != null ? 1 : 0

  mount = var.coffre.mount
  name  = "${var.coffre.prefixe}/service"
  data_json = jsonencode({
    client_id     = module.service[0].client_id
    client_secret = module.service[0].client_secret
  })
  custom_metadata {
    data = {
      application = module.service[0].application_id
      tourne_le   = time_rotating.rythme.rfc3339
    }
  }
}
