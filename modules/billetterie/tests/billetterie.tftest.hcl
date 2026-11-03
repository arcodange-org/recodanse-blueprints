# La billetterie « Billets du Quai » (un nom fictif), jouée avec des fournisseurs SIMULÉS.

mock_provider "recodanse" {}
mock_provider "time" {}
mock_provider "vault" {}

variables {
  nom         = "Billets du Quai"
  webhook_url = "https://billets-du-quai.example/webhooks/recodanse"
}

run "un_service_qui_publie_et_ecoute_les_retraits" {
  command = apply

  assert {
    condition     = recodanse_webhook.publication_retiree.evenements == toset(["publication.retiree"])
    error_message = "le service écoute « publication.retiree », et rien d'autre"
  }

  assert {
    condition     = length(module.connexion) == 0 && output.connexion == null
    error_message = "sans `connexion`, aucune application de connexion"
  }

  assert {
    condition     = output.dates.application_id == recodanse_webhook.publication_retiree.application
    error_message = "le webhook doit être posé sur le compte de service"
  }
}

run "avec_la_connexion_et_un_coffre" {
  command = apply

  variables {
    connexion = {
      redirections = ["https://billets-du-quai.example/retour"]
      portees      = ["openid", "profile"]
      webhook_url  = "https://billets-du-quai.example/webhooks/effacement"
    }
    coffre = { mount = "kv", chemin = "recodanse/billets-du-quai" }
  }

  assert {
    condition     = length(module.connexion) == 1
    error_message = "l'application de connexion doit exister"
  }

  assert {
    condition     = length(vault_kv_secret_v2.webhooks) == 1 && length(vault_kv_secret_v2.connexion) == 1
    error_message = "les secrets des webhooks et de la connexion vont au coffre"
  }

  assert {
    condition     = vault_kv_secret_v2.webhooks[0].name == "recodanse/billets-du-quai/webhooks"
    error_message = "les clés des webhooks vont à <chemin>/webhooks"
  }
}

# ── Les refus ──────────────────────────────────────────────────────────────────

run "un_webhook_sur_une_adresse_privee_est_refuse" {
  command = plan

  variables {
    webhook_url = "https://192.168.1.10/webhooks"
  }

  expect_failures = [var.webhook_url]
}

run "un_nom_trop_long_pour_le_compte_de_service_est_refuse" {
  command = plan

  variables {
    nom = "La Grande Billetterie des Quais et des Ponts de la Ville"
  }

  expect_failures = [var.nom]
}
