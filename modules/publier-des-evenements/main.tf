# La rotation PLANIFIÉE : time_rotating change d'identifiant à l'échéance, ce qui
# change `rotation` et fait tourner le secret au prochain apply. La rotation À LA
# MAIN (`var.rotation`) s'y ajoute : changer une de ses valeurs fait tourner aussi.
resource "time_rotating" "secret" {
  count = var.rotation_jours > 0 ? 1 : 0

  rotation_days = var.rotation_jours
}

locals {
  rotation = merge(
    var.rotation,
    var.rotation_jours > 0 ? { planifiee = time_rotating.secret[0].id } : {},
  )
}

resource "recodanse_application" "service" {
  nom         = var.nom
  description = var.description
  site_web    = var.site_web
  categorie   = "service"
  portees     = var.portees
  rotation    = length(local.rotation) > 0 ? local.rotation : null

  soumettre              = var.soumettre
  accepte_les_conditions = var.accepte_les_conditions

  lifecycle {
    precondition {
      condition     = !var.soumettre || var.accepte_les_conditions != null
      error_message = "soumettre : écris dans accepte_les_conditions la version des conditions des développeurs que tu as lue (dev.recodanse.fr). Le module ne l'accepte jamais à ta place."
    }
  }
}

# Le secret tourné part vers le coffre DANS LE MÊME apply : l'ancien a cessé de
# valoir à l'instant de la rotation (Hydra n'en garde qu'un).
resource "vault_kv_secret_v2" "service" {
  count = var.coffre == null ? 0 : 1

  mount = var.coffre.mount
  name  = var.coffre.chemin
  data_json = jsonencode({
    client_id     = recodanse_application.service.client_id
    client_secret = recodanse_application.service.client_secret
  })
  custom_metadata {
    data = {
      application = recodanse_application.service.id
      source      = "recodanse-blueprints/publier-des-evenements"
    }
  }
}
