output "application_id" {
  description = "L'application d'essai (appl_…)."
  value       = module.application.application_id
}

output "client_id" {
  description = "Son client_id."
  value       = module.application.client_id
}

output "client_secret" {
  description = "Son secret. SENSIBLE — même au bac à sable, un secret se garde."
  value       = module.application.client_secret
  sensitive   = true
}

output "webhook_secret" {
  description = "La clé whsec_… du webhook d'essai, pour vérifier les envois. SENSIBLE."
  value       = module.application.webhook_secret
  sensitive   = true
}

output "comptes_fictifs" {
  description = "Les comptes fictifs (cle, prénom, titre) au nom desquels répondre « Autoriser »."
  value       = data.recodanse_comptes_fictifs.tous.comptes
}

output "compte" {
  description = "Le compte fictif visé."
  value       = local.compte
}

output "evenement_declenche" {
  description = "Ce qui est parti : sujet (le pseudonyme que le webhook reçoit) et instant, ou null."
  value = var.declencher ? {
    evenement    = var.evenement
    sujet        = recodanse_evenement_du_bac_a_sable.effacement[0].sujet
    declenche_le = recodanse_evenement_du_bac_a_sable.effacement[0].declenche_le
  } : null
}
