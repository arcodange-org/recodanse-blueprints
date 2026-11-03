variable "nom" {
  description = "Le nom de la billetterie (2 à 60 caractères) : il nomme le compte de service (« <nom> — dates ») et, si `connexion` est donné, l'application de connexion."
  type        = string

  validation {
    # « — dates » ajoute 8 caractères au nom du compte de service : 52 au plus ici.
    condition     = length(var.nom) >= 2 && length(var.nom) <= 52 && trimspace(var.nom) == var.nom
    error_message = "nom : 2 à 52 caractères (le compte de service s'appelle « <nom> — dates », 60 au plus), sans espace au bord."
  }
}

variable "site_web" {
  description = "L'adresse de la billetterie (https:// seulement), ou vide."
  type        = string
  default     = ""

  validation {
    condition     = var.site_web == "" || startswith(var.site_web, "https://")
    error_message = "site_web : https:// seulement."
  }
}

variable "webhook_url" {
  description = "L'adresse publique (https://) où ReCoDanse prévient la billetterie qu'une de ses dates a été RETIRÉE par la modération (« publication.retiree ») — pour qu'elle cesse de la republier."
  type        = string

  validation {
    condition     = can(regex("^https://[^/]+", var.webhook_url)) && !can(regex("^https://(localhost|127\\.|10\\.|192\\.168\\.|\\[::1\\])", var.webhook_url))
    error_message = "webhook_url : https:// vers un hôte public (ReCoDanse refuse d'envoyer vers une adresse privée ou locale)."
  }
}

variable "rotation_jours" {
  description = "Tous les combien de jours le secret du compte de service tourne (0 à 365 ; 0 : à la main seulement). Défaut 90."
  type        = number
  default     = 90
}

variable "rotation" {
  description = "Rotation à la main du secret du compte de service (une valeur qui change fait tourner)."
  type        = map(string)
  default     = {}
}

variable "connexion" {
  description = "Facultatif : « Se connecter avec ReCoDanse » sur la billetterie (le module se-connecter-avec-recodanse). null (défaut) : aucune application de connexion."
  type = object({
    redirections = list(string)
    publique     = optional(bool, false)
    portees      = optional(set(string), ["openid"])
    webhook_url  = optional(string)
  })
  default = null
}

variable "coffre" {
  description = "Facultatif : où ranger les secrets dans Vault (KV v2). Le compte de service va à <chemin>, les clés des webhooks à <chemin>/webhooks, la connexion à <chemin>/connexion."
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
