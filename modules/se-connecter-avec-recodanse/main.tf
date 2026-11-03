locals {
  # Les portées qui donnent au tiers une donnée qu'il devra EFFACER quand la
  # personne retire son accord ou efface son compte (règle de la revue ReCoDanse).
  # « openid » seul ne donne qu'un sujet pseudonyme ; les portées d'écriture
  # n'apportent rien au tiers à garder.
  portees_gardees_par_l_effacement = ["profile", "email", "offline_access", "videos.lire"]

  portees_gardees = setintersection(var.portees, local.portees_gardees_par_l_effacement)
  webhook_exige   = length(local.portees_gardees) > 0
}

resource "recodanse_application" "connexion" {
  nom          = var.nom
  description  = var.description
  site_web     = var.site_web
  categorie    = "connexion"
  portees      = var.portees
  redirections = var.redirections
  publique     = var.publique
  rotation     = var.rotation

  soumettre              = var.soumettre
  accepte_les_conditions = var.accepte_les_conditions

  lifecycle {
    precondition {
      condition     = !local.webhook_exige || var.webhook_url != null
      error_message = "Les portées ${join(", ", sort(tolist(local.portees_gardees)))} donnent une donnée à effacer : donne webhook_url, où ReCoDanse enverra « autorisation.retiree » et « compte.efface » (la revue l'exige pour ces portées). Sans elles, « openid » seul n'exige aucun webhook."
    }

    precondition {
      condition     = !(var.publique && var.rotation != null)
      error_message = "rotation : un client public n'a pas de secret, rien à faire tourner."
    }

    precondition {
      condition     = !var.soumettre || var.accepte_les_conditions != null
      error_message = "soumettre : écris dans accepte_les_conditions la version des conditions des développeurs que tu as lue (dev.recodanse.fr). Le module ne l'accepte jamais à ta place."
    }
  }
}

# Le webhook dépend de l'identifiant de l'application : il naît APRÈS elle. Avec
# soumettre = true et une portée gardée, le premier apply déclare et avertit
# (portee_sans_webhook_d_effacement), le second soumet : la revue exige le webhook.
resource "recodanse_webhook" "effacement" {
  count = var.webhook_url == null ? 0 : 1

  application = recodanse_application.connexion.id
  url         = var.webhook_url
  evenements  = ["autorisation.retiree", "compte.efface"]
}
