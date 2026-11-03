variable "nom" {
  description = "Le nom de l'école (2 à 49 caractères) : le compte de service s'appelle « <nom> — créneaux »."
  type        = string

  validation {
    condition     = length(var.nom) >= 2 && length(var.nom) <= 49 && trimspace(var.nom) == var.nom
    error_message = "nom : 2 à 49 caractères, sans espace au bord."
  }
}

variable "site_web" {
  description = "L'adresse de l'école (https:// seulement), ou vide."
  type        = string
  default     = ""
}

variable "salles" {
  description = "Les salles (lieux) de l'école : 2 à 20, chacune une `cle` courte et stable (minuscules, chiffres, tirets) et un `nom` lisible. UNE seule application publie pour toutes : la clé préfixe la référence de chaque créneau (« <cle>/<référence du cours> »)."
  type = list(object({
    cle = string
    nom = string
  }))

  validation {
    condition     = length(var.salles) >= 2 && length(var.salles) <= 20
    error_message = "salles : de 2 à 20 salles (une seule salle : prends le module studio-creneaux)."
  }

  validation {
    condition     = alltrue([for s in var.salles : can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", s.cle)) && length(s.cle) <= 24])
    error_message = "salles : chaque `cle` est faite de minuscules, de chiffres et de tirets (24 caractères au plus) — elle entre dans la référence des créneaux."
  }

  validation {
    condition     = length(distinct([for s in var.salles : s.cle])) == length(var.salles)
    error_message = "salles : deux salles ont la même `cle` — leurs créneaux se confondraient."
  }

  validation {
    condition     = alltrue([for s in var.salles : length(trimspace(s.nom)) >= 2])
    error_message = "salles : chaque salle a un `nom` lisible (2 caractères au moins)."
  }
}

variable "dac7_suspendu" {
  description = "Vrai tant que ReCoDanse range les créneaux sans les montrer (DAC7). Voir studio-creneaux."
  type        = bool
  default     = true
}

variable "webhook_url" {
  description = "Facultatif : où ReCoDanse prévient l'école qu'un de ses créneaux a été retiré par la modération (« publication.retiree »)."
  type        = string
  default     = null

  validation {
    condition     = var.webhook_url == null || (can(regex("^https://[^/]+", var.webhook_url)) && !can(regex("^https://(localhost|127\\.|10\\.|192\\.168\\.|\\[::1\\])", var.webhook_url)))
    error_message = "webhook_url : https:// vers un hôte public."
  }
}

variable "connexion" {
  description = "Facultatif : les élèves se connectent avec ReCoDanse. Voir studio-creneaux."
  type = object({
    redirections = list(string)
    publique     = optional(bool, false)
    portees      = optional(set(string), ["openid"])
    webhook_url  = optional(string)
  })
  default = null
}

variable "rotation_jours" {
  description = "Tous les combien de jours le secret tourne (0 à 365). Défaut 90."
  type        = number
  default     = 90
}

variable "coffre" {
  description = "Facultatif : où ranger les secrets dans Vault (KV v2)."
  type = object({
    mount  = string
    chemin = string
  })
  default = null
}

variable "soumettre" {
  description = "Soumettre les applications à la revue de ReCoDanse."
  type        = bool
  default     = false
}

variable "accepte_les_conditions" {
  description = "La version des conditions des développeurs que TU acceptes (AAAA-MM-JJ). Exigée pour soumettre."
  type        = string
  default     = null
}
