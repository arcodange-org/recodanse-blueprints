output "application_id" {
  description = "L'identifiant ReCoDanse de l'application de service (appl_…)."
  value       = recodanse_application.service.id
}

output "client_id" {
  description = "L'identifiant de client OAuth2 (client_credentials) — pas un secret."
  value       = recodanse_application.service.client_id
}

output "client_secret" {
  description = "Le secret du compte de service, après sa dernière rotation. SENSIBLE : vers un coffre, jamais vers un journal."
  value       = recodanse_application.service.client_secret
  sensitive   = true
}

output "statut" {
  description = "developpement, en_revue, publiee, suspendue ou non_verifiee."
  value       = recodanse_application.service.statut
}

output "prochaine_rotation" {
  description = "Quand le secret tournera de lui-même (RFC 3339), ou null sans rotation planifiée. ⚠ La rotation a lieu au premier apply APRÈS cette date."
  value       = one(time_rotating.secret[*].rotation_rfc3339)
}

output "chemin_dans_le_coffre" {
  description = "« <mount>/<chemin> » où le secret est rangé, ou null sans coffre."
  value       = var.coffre == null ? null : "${var.coffre.mount}/${var.coffre.chemin}"
}

output "rotation" {
  description = "La carte de rotation effective (planifiée + à la main) : une autre application peut la reprendre pour tourner au même rythme."
  value       = local.rotation
}
