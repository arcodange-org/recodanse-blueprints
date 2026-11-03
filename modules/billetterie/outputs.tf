output "dates" {
  description = "Le compte de service qui publie les dates : application_id, client_id, statut, prochaine_rotation."
  value = {
    application_id     = module.dates.application_id
    client_id          = module.dates.client_id
    statut             = module.dates.statut
    prochaine_rotation = module.dates.prochaine_rotation
  }
}

output "dates_client_secret" {
  description = "Le secret du compte de service. SENSIBLE."
  value       = module.dates.client_secret
  sensitive   = true
}

output "webhook_publication_retiree" {
  description = "Le webhook « publication.retiree » : id et clé de signature whsec_… (SENSIBLE)."
  value = {
    id     = recodanse_webhook.publication_retiree.id
    secret = recodanse_webhook.publication_retiree.secret
  }
  sensitive = true
}

output "connexion" {
  description = "L'application de connexion (application_id, client_id, statut), ou null."
  value = var.connexion == null ? null : {
    application_id = module.connexion[0].application_id
    client_id      = module.connexion[0].client_id
    statut         = module.connexion[0].statut
  }
}

output "connexion_client_secret" {
  description = "Le secret de connexion (nul pour un client public, ou sans connexion). SENSIBLE."
  value       = var.connexion == null ? null : module.connexion[0].client_secret
  sensitive   = true
}
