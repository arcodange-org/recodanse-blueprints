variable "connexion" {
  description = "Facultatif : une application « connexion » CONFIDENTIELLE dont le secret tourne avec les autres. null : aucune."
  type = object({
    nom          = string
    redirections = list(string)
    portees      = optional(set(string), ["openid"])
    webhook_url  = optional(string)
  })
  default = null
}

variable "service" {
  description = "Facultatif : un compte de service dont le secret tourne avec les autres. null : aucun."
  type = object({
    nom     = string
    portees = optional(set(string), ["evenements.publier"])
  })
  default = null
}

variable "rotation_jours" {
  description = "Le rythme COMMUN de rotation, en jours (1 à 365). Défaut 90."
  type        = number
  default     = 90

  validation {
    condition     = var.rotation_jours == floor(var.rotation_jours) && var.rotation_jours >= 1 && var.rotation_jours <= 365
    error_message = "rotation_jours : un entier de 1 à 365 — ce module existe pour faire tourner."
  }
}

variable "rotation" {
  description = "Rotation À LA MAIN de tous les secrets d'un coup : { fuite = \"2026-11-02\" } (procédure « un jeton a fui » : couper d'abord)."
  type        = map(string)
  default     = {}

  validation {
    condition     = !contains(keys(var.rotation), "planifiee")
    error_message = "rotation : la clé « planifiee » est réservée à la rotation planifiée."
  }
}

variable "coffre" {
  description = "Facultatif : où ranger les secrets tournés dans Vault (KV v2) — <prefixe>/connexion et <prefixe>/service, écrits DANS LE MÊME apply que la rotation. null : les secrets ne sortent que par les sorties SENSIBLES."
  type = object({
    mount   = string
    prefixe = string
  })
  default = null

  validation {
    condition     = var.coffre == null || (can(regex("^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)*$", var.coffre.prefixe)) && length(var.coffre.mount) > 0)
    error_message = "coffre : un mount non vide et un préfixe relatif, sans « / » au bord."
  }
}
