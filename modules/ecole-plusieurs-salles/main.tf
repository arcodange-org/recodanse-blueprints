# Une école à plusieurs salles : UNE application de service publie pour
# toutes les salles. Une salle n'est pas une ressource de ReCoDanse : c'est le
# LIEU d'un créneau. L'école préfixe la référence de chaque cours par la clé de
# sa salle, puis modifie un cours en reprenant sa référence (PUT, même cours) et
# l'annule (DELETE : ReCoDanse le garde « retiré »).

module "studio" {
  source = "../studio-creneaux"

  nom                         = var.nom
  site_web                    = var.site_web
  publie_aussi_des_evenements = false
  dac7_suspendu               = var.dac7_suspendu
  rotation_jours              = var.rotation_jours
  connexion                   = var.connexion
  coffre                      = var.coffre

  soumettre              = var.soumettre
  accepte_les_conditions = var.accepte_les_conditions
}

resource "recodanse_webhook" "publication_retiree" {
  count = var.webhook_url == null ? 0 : 1

  application = module.studio.creneaux.application_id
  url         = var.webhook_url
  evenements  = ["publication.retiree"]
}

locals {
  salles = { for s in var.salles : s.cle => {
    nom                  = s.nom
    prefixe_de_reference = "${s.cle}/"
  } }
}
