output "creneaux" {
  description = "Le compte de service unique qui publie pour toutes les salles."
  value       = module.studio.creneaux
}

output "creneaux_client_secret" {
  description = "Le secret du compte de service. SENSIBLE."
  value       = module.studio.creneaux_client_secret
  sensitive   = true
}

output "salles" {
  description = "Pour la configuration du site : chaque salle, son nom et le préfixe de la référence de ses créneaux."
  value       = local.salles
}

output "creneaux_visibles" {
  description = "false tant que la publication des créneaux est suspendue (DAC7)."
  value       = module.studio.creneaux_visibles
}

output "webhook_publication_retiree" {
  description = "Le webhook « publication.retiree » (id, clé whsec_…), ou null. SENSIBLE."
  value = var.webhook_url == null ? null : {
    id     = recodanse_webhook.publication_retiree[0].id
    secret = recodanse_webhook.publication_retiree[0].secret
  }
  sensitive = true
}

output "connexion" {
  description = "L'application de connexion des élèves, ou null."
  value       = module.studio.connexion
}
