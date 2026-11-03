variable "nom" {
  description = "Le nom du studio (2 à 49 caractères) : le compte de service s'appelle « <nom> — créneaux »."
  type        = string

  validation {
    condition     = length(var.nom) >= 2 && length(var.nom) <= 49 && trimspace(var.nom) == var.nom
    error_message = "nom : 2 à 49 caractères (le compte de service s'appelle « <nom> — créneaux », 60 au plus), sans espace au bord."
  }
}

variable "site_web" {
  description = "L'adresse du studio (https:// seulement), ou vide."
  type        = string
  default     = ""

  validation {
    condition     = var.site_web == "" || startswith(var.site_web, "https://")
    error_message = "site_web : https:// seulement."
  }
}

variable "publie_aussi_des_evenements" {
  description = "Le studio publie aussi des stages et des soirées (« evenements.publier »), en plus de ses cours réguliers. Défaut false : les créneaux seulement."
  type        = bool
  default     = false
}

variable "dac7_suspendu" {
  description = "Vrai tant que ReCoDanse range les créneaux sans les MONTRER (avis juridique DAC7 attendu ; l'API répond publies: false, raison publication_suspendue_dac7). Le plan le rappelle par un avertissement. Passe à false quand dev.recodanse.fr annonce la levée."
  type        = bool
  default     = true
}

variable "rotation_jours" {
  description = "Tous les combien de jours le secret du compte de service tourne (0 à 365 ; 0 : à la main seulement). Défaut 90."
  type        = number
  default     = 90
}

variable "rotation" {
  description = "Rotation à la main du secret (une valeur qui change fait tourner)."
  type        = map(string)
  default     = {}
}

variable "connexion" {
  description = "Facultatif : les élèves se connectent au site du studio avec ReCoDanse. null (défaut) : aucune application de connexion."
  type = object({
    redirections = list(string)
    publique     = optional(bool, false)
    portees      = optional(set(string), ["openid"])
    webhook_url  = optional(string)
  })
  default = null
}

variable "coffre" {
  description = "Facultatif : où ranger le secret du compte de service dans Vault (KV v2) ; la connexion va à <chemin>/connexion."
  type = object({
    mount  = string
    chemin = string
  })
  default = null

  validation {
    condition     = var.coffre == null || (can(regex("^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)*$", var.coffre.chemin)) && length(var.coffre.mount) > 0)
    error_message = "coffre : un mount non vide et un chemin relatif, sans « / » au bord."
  }
}

variable "soumettre" {
  description = "Soumettre les applications à la revue de ReCoDanse. Une soumission ne se retire pas."
  type        = bool
  default     = false
}

variable "accepte_les_conditions" {
  description = "La version des conditions des développeurs que TU acceptes (AAAA-MM-JJ). Exigée pour soumettre."
  type        = string
  default     = null
}
