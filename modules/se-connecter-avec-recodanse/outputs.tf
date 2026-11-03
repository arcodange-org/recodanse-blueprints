output "application_id" {
  description = "L'identifiant ReCoDanse de l'application (appl_…), distinct du client_id."
  value       = recodanse_application.connexion.id
}

output "client_id" {
  description = "L'identifiant de client OAuth2 — à mettre dans la configuration de ton site (pas un secret)."
  value       = recodanse_application.connexion.client_id
}

output "client_secret" {
  description = "Le secret du client confidentiel (nul pour un client public). SENSIBLE : vers ton coffre, jamais vers un journal."
  value       = recodanse_application.connexion.client_secret
  sensitive   = true
}

output "webhook_id" {
  description = "L'identifiant du webhook d'effacement (webh_…), ou null."
  value       = one(recodanse_webhook.effacement[*].id)
}

output "webhook_secret" {
  description = "La clé de signature whsec_… du webhook, pour vérifier chaque envoi. SENSIBLE."
  value       = one(recodanse_webhook.effacement[*].secret)
  sensitive   = true
}

output "statut" {
  description = "developpement, en_revue, publiee, suspendue ou non_verifiee."
  value       = recodanse_application.connexion.statut
}

output "webhook_exige" {
  description = "Vrai si une portée demandée oblige à écouter l'effacement (règle de la revue)."
  value       = local.webhook_exige
}
