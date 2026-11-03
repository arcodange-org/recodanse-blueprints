variable "nom" {
  description = "Le nom de l'application de service (2 à 60 caractères, sans espace au bord) — celui que la revue et « Mes applications » affichent."
  type        = string

  validation {
    condition     = length(var.nom) >= 2 && length(var.nom) <= 60 && trimspace(var.nom) == var.nom
    error_message = "nom : 2 à 60 caractères, sans espace au début ni à la fin."
  }
}

variable "description" {
  description = "Ce que publie l'application, en une phrase (500 caractères au plus)."
  type        = string
  default     = ""

  validation {
    condition     = length(var.description) <= 500
    error_message = "description : 500 caractères au plus."
  }
}

variable "site_web" {
  description = "L'adresse du site (https:// seulement), ou vide."
  type        = string
  default     = ""

  validation {
    condition     = var.site_web == "" || startswith(var.site_web, "https://")
    error_message = "site_web : https:// seulement."
  }
}

variable "portees" {
  description = "Ce que le compte de service publie, pour le compte qui l'a déclaré : « evenements.publier » (défaut — soirées, stages, festivals) et/ou « creneaux.publier » (cours réguliers ; publication SUSPENDUE, DAC7). Rien d'autre n'existe pour un service."
  type        = set(string)
  default     = ["evenements.publier"]

  validation {
    condition     = length(var.portees) >= 1
    error_message = "portees : une portée au moins."
  }

  validation {
    condition     = alltrue([for p in var.portees : contains(["evenements.publier", "creneaux.publier"], p)])
    error_message = "portees : un compte de service ne demande que « evenements.publier » ou « creneaux.publier » (data.recodanse_catalogue les annonce)."
  }
}

variable "rotation_jours" {
  description = "Tous les combien de jours le secret TOURNE (time_rotating) : de 1 à 365, ou 0 pour ne faire tourner qu'à la main (`rotation`). Défaut 90. ⚠ L'ancien secret cesse de valoir à l'instant : avec `coffre`, le nouveau y arrive dans le même apply."
  type        = number
  default     = 90

  validation {
    condition     = var.rotation_jours == floor(var.rotation_jours) && var.rotation_jours >= 0 && var.rotation_jours <= 365
    error_message = "rotation_jours : un nombre entier de 0 (pas de rotation planifiée) à 365."
  }
}

variable "rotation" {
  description = "Des valeurs libres qui font tourner le secret quand l'une change — la rotation À LA MAIN, par exemple { fuite = \"2026-11-02\" } quand un secret a fui (procédure « un jeton a fui »)."
  type        = map(string)
  default     = {}
}

variable "coffre" {
  description = "Facultatif : où ranger client_id et client_secret dans Vault (moteur KV v2). null (défaut) : le secret ne sort que par la sortie SENSIBLE `client_secret`. Le fournisseur `vault` se configure chez l'appelant (VAULT_ADDR, une identité de CI)."
  type = object({
    mount  = string
    chemin = string
  })
  default = null

  validation {
    condition     = var.coffre == null || (can(regex("^[A-Za-z0-9_.-]+(/[A-Za-z0-9_.-]+)*$", var.coffre.chemin)) && length(var.coffre.mount) > 0)
    error_message = "coffre : un mount non vide et un chemin relatif (segments [A-Za-z0-9_.-] séparés par « / », sans « / » au bord)."
  }
}

variable "soumettre" {
  description = "Demander la revue de ReCoDanse (developpement → en_revue). Une soumission ne se retire pas."
  type        = bool
  default     = false
}

variable "accepte_les_conditions" {
  description = "La version des conditions des développeurs que TU acceptes (AAAA-MM-JJ, lue sur dev.recodanse.fr). Exigée pour soumettre ; jamais remplie à ta place."
  type        = string
  default     = null

  validation {
    condition     = var.accepte_les_conditions == null || can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", var.accepte_les_conditions))
    error_message = "accepte_les_conditions : une version de la forme AAAA-MM-JJ (celle que dev.recodanse.fr affiche)."
  }
}
