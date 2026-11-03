variable "nom" {
  description = "Le nom que la personne lit sur la page « Autoriser » de ReCoDanse (2 à 60 caractères, sans espace au bord)."
  type        = string

  validation {
    condition     = length(var.nom) >= 2 && length(var.nom) <= 60 && trimspace(var.nom) == var.nom
    error_message = "nom : 2 à 60 caractères, sans espace au début ni à la fin."
  }
}

variable "description" {
  description = "Ce que fait l'application, en une phrase (500 caractères au plus)."
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

variable "redirections" {
  description = "Les adresses de retour après « Autoriser » : https://, http://127.0.0.1 (développement local) ou un schéma d'app native à nom de domaine inversé (fr.exemple.app:/retour). Une à dix."
  type        = list(string)

  validation {
    condition     = length(var.redirections) >= 1 && length(var.redirections) <= 10
    error_message = "redirections : une adresse de retour au moins, dix au plus."
  }

  validation {
    condition = alltrue([
      for r in var.redirections :
      can(regex("^(https://[^/]+|http://127\\.0\\.0\\.1(:[0-9]+)?(/|$)|[a-z][a-z0-9+-]*(\\.[a-z0-9+-]+)+:/)", r))
    ])
    error_message = "redirections : https://, http://127.0.0.1, ou un schéma d'app native à nom de domaine inversé (fr.exemple.app:/retour). « http:// » vers un autre hôte est refusé."
  }
}

variable "publique" {
  description = "true : client PUBLIC (app native, page sans serveur), sans secret, PKCE obligatoire. false (défaut) : client CONFIDENTIEL, le secret reste sur ton serveur (PKCE recommandé quand même). Changer recrée l'application (nouveau client_id)."
  type        = bool
  default     = false
}

variable "portees" {
  description = "Les portées DEMANDÉES. Le minimum, « openid », suffit pour « Se connecter avec ReCoDanse » (un sujet stable, rien d'autre). Chaque portée de plus se justifie à la revue."
  type        = set(string)
  default     = ["openid"]

  validation {
    condition     = contains(var.portees, "openid")
    error_message = "portees : « openid » est exigée — c'est elle qui fait de l'application une connexion OpenID Connect."
  }

  validation {
    condition = alltrue([for p in var.portees : contains([
      "openid", "profile", "email", "offline_access", "videos.lire", "videos.ranger",
      "videos.deposer", "videos.annoter", "programmes.poser", "evenements.proposer",
    ], p)])
    error_message = "portees : une portée n'est pas permise à une application « connexion ». Permises : openid, profile, email, offline_access, videos.lire, videos.ranger, videos.deposer, videos.annoter, programmes.poser, evenements.proposer (data.recodanse_catalogue les annonce)."
  }
}

variable "webhook_url" {
  description = "L'adresse publique (https://) où ReCoDanse envoie « autorisation.retiree » et « compte.efface », signés Standard Webhooks. EXIGÉE dès qu'une portée gardée par l'effacement est demandée (profile, email, offline_access, videos.lire : la revue l'exige) ; facultative sinon (« openid » seul ne donne qu'un sujet pseudonyme)."
  type        = string
  default     = null

  validation {
    condition     = var.webhook_url == null || can(regex("^https://[^/]+", var.webhook_url))
    error_message = "webhook_url : https:// seulement (ReCoDanse refuse d'envoyer vers une adresse privée ou locale)."
  }

  validation {
    condition     = var.webhook_url == null || !can(regex("^https://(localhost|127\\.|10\\.|192\\.168\\.|\\[::1\\])", var.webhook_url))
    error_message = "webhook_url : un hôte public — localhost et les adresses privées sont refusés par l'API au moment de l'envoi."
  }
}

variable "rotation" {
  description = "Des valeurs libres : quand l'une change, le secret TOURNE (l'ancien cesse de valoir à l'instant). Exemple : { quand = time_rotating.x.id }. Sans objet pour un client public."
  type        = map(string)
  default     = null
}

variable "soumettre" {
  description = "Demander la revue de ReCoDanse (developpement → en_revue). Une soumission ne se retire pas. Avec une portée gardée par l'effacement, le webhook doit répondre 2xx à un essai signé ET 4xx au même essai mal signé (la revue le vérifie)."
  type        = bool
  default     = false
}

variable "accepte_les_conditions" {
  description = "La version des conditions des développeurs que TU acceptes (lue sur dev.recodanse.fr, écrite de ta main, AAAA-MM-JJ). Exigée pour soumettre ; jamais remplie à ta place."
  type        = string
  default     = null

  validation {
    condition     = var.accepte_les_conditions == null || can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", var.accepte_les_conditions))
    error_message = "accepte_les_conditions : une version de la forme AAAA-MM-JJ (celle que dev.recodanse.fr affiche)."
  }
}
