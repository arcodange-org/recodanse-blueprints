variable "nom" {
  description = "Le nom de l'application d'essai (2 à 60 caractères)."
  type        = string

  validation {
    condition     = length(var.nom) >= 2 && length(var.nom) <= 60 && trimspace(var.nom) == var.nom
    error_message = "nom : 2 à 60 caractères, sans espace au bord."
  }
}

variable "redirections" {
  description = "Les adresses de retour de l'application d'essai. Au bac à sable, http://127.0.0.1 suffit pour un site lancé sur ton poste."
  type        = list(string)
  default     = ["http://127.0.0.1:8080/retour"]
}

variable "portees" {
  description = "Les portées demandées. Défaut openid + profile : de quoi recevoir un prénom fictif, et donc devoir écouter l'effacement."
  type        = set(string)
  default     = ["openid", "profile"]
}

variable "webhook_url" {
  description = "L'adresse publique (https://) de ton webhook d'essai — là où arrivent « autorisation.retiree » et « compte.efface » déclenchés à la demande."
  type        = string

  validation {
    condition     = can(regex("^https://[^/]+", var.webhook_url)) && !can(regex("^https://(localhost|127\\.|10\\.|192\\.168\\.|\\[::1\\])", var.webhook_url))
    error_message = "webhook_url : https:// vers un hôte public (même au bac à sable, ReCoDanse n'envoie pas vers une adresse privée)."
  }
}

variable "compte" {
  description = "La `cle` du compte fictif au nom duquel l'événement est déclenché (data.recodanse_comptes_fictifs). null : le premier de la liste."
  type        = string
  default     = null
}

variable "evenement" {
  description = "L'événement à déclencher : « compte.efface » (défaut) ou « autorisation.retiree ». « publication.retiree » ne se déclenche pas au bac à sable."
  type        = string
  default     = "compte.efface"

  validation {
    condition     = contains(["compte.efface", "autorisation.retiree"], var.evenement)
    error_message = "evenement : « compte.efface » ou « autorisation.retiree » seulement — le bac à sable ne déclenche pas « publication.retiree »."
  }
}

variable "declencher" {
  description = "false (défaut) au premier apply : l'application et son webhook naissent, puis tu réponds « Autoriser » au nom du compte fictif (« Continuer en tant que »). true ensuite : l'événement part (sinon l'API répond 409 pas_autorisee)."
  type        = bool
  default     = false
}

variable "essai" {
  description = "Changer cette valeur REDÉCLENCHE l'événement (le compte fictif doit d'abord autoriser de nouveau l'application : l'événement retire vraiment l'accord)."
  type        = string
  default     = "1"
}
