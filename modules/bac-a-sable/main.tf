# Le bac à sable des développeurs : une application
# d'essai, les comptes fictifs (les personas), et un événement d'effacement
# déclenché À LA DEMANDE pour éprouver son webhook avant la revue.
#
# ⚠ Le fournisseur de l'APPELANT doit être configuré `environnement = "bac-a-sable"`
# (avec `api` et `emetteur` tant que ses adresses ne sont pas confirmées) : ailleurs,
# la source des comptes fictifs et l'événement se refusent dès le plan, sans un appel.

module "application" {
  source = "../se-connecter-avec-recodanse"

  nom          = var.nom
  redirections = var.redirections
  portees      = var.portees
  webhook_url  = var.webhook_url
}

data "recodanse_comptes_fictifs" "tous" {}

locals {
  compte = coalesce(var.compte, try(data.recodanse_comptes_fictifs.tous.comptes[0].cle, null))
}

# Créer déclenche UNE fois ; changer `essai` redéclenche ; détruire ne fait rien
# (un envoi parti ne se reprend pas).
resource "recodanse_evenement_du_bac_a_sable" "effacement" {
  count = var.declencher ? 1 : 0

  application = module.application.application_id
  compte      = local.compte
  evenement   = var.evenement
  triggers    = { essai = var.essai }

  lifecycle {
    precondition {
      condition     = contains([for c in data.recodanse_comptes_fictifs.tous.comptes : c.cle], local.compte)
      error_message = "compte : « ${coalesce(local.compte, "(aucun)")} » n'est pas un compte fictif de ce bac à sable — voir la sortie comptes_fictifs."
    }
  }
}
