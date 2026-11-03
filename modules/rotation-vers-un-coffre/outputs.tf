output "prochaine_rotation" {
  description = "Quand tous les secrets tourneront (RFC 3339) — au premier apply après cette date."
  value       = time_rotating.rythme.rotation_rfc3339
}

output "chemins_dans_le_coffre" {
  description = "Les chemins écrits dans Vault, ou une liste vide sans coffre."
  value = compact([
    length(vault_kv_secret_v2.connexion) > 0 ? "${var.coffre.mount}/${vault_kv_secret_v2.connexion[0].name}" : "",
    length(vault_kv_secret_v2.service) > 0 ? "${var.coffre.mount}/${vault_kv_secret_v2.service[0].name}" : "",
  ])
}

output "client_ids" {
  description = "Les client_id (pas des secrets) : connexion et service, null s'ils n'existent pas."
  value = {
    connexion = var.connexion == null ? null : module.connexion[0].client_id
    service   = var.service == null ? null : module.service[0].client_id
  }
}

output "secrets" {
  description = "Les secrets tournés (client_secret de chaque application, clé du webhook de connexion). SENSIBLE : quand `coffre` est donné, préfère le coffre."
  value = {
    connexion         = var.connexion == null ? null : module.connexion[0].client_secret
    connexion_webhook = var.connexion == null ? null : module.connexion[0].webhook_secret
    service           = var.service == null ? null : module.service[0].client_secret
  }
  sensitive = true
}
