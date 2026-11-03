output "creneaux" {
  description = "Le compte de service qui publie les créneaux : application_id, client_id, statut, prochaine_rotation, portees."
  value = {
    application_id     = module.creneaux.application_id
    client_id          = module.creneaux.client_id
    statut             = module.creneaux.statut
    prochaine_rotation = module.creneaux.prochaine_rotation
  }
}

output "creneaux_client_secret" {
  description = "Le secret du compte de service. SENSIBLE."
  value       = module.creneaux.client_secret
  sensitive   = true
}

output "creneaux_visibles" {
  description = "false tant que la publication des créneaux est suspendue (DAC7) : ils sont rangés, pas montrés."
  value       = !var.dac7_suspendu
}

output "connexion" {
  description = "L'application de connexion des élèves (application_id, client_id, statut), ou null."
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
