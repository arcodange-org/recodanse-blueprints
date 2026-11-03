# Joué par `tofu test` (OpenTofu ≥ 1.8) avec un fournisseur SIMULÉ : aucun appel à
# ReCoDanse, aucun jeton. Ce qui est éprouvé ici est le MODULE (ses entrées, ses
# règles, ce qu'il déclare) ; le fournisseur a ses propres essais.

mock_provider "recodanse" {}

variables {
  nom          = "Le Bal des Soirées"
  redirections = ["https://soirees.example/retour"]
}

run "openid_seul_ne_pose_aucun_webhook" {
  command = apply

  assert {
    condition     = recodanse_application.connexion.categorie == "connexion"
    error_message = "l'application doit être une connexion"
  }

  assert {
    condition     = recodanse_application.connexion.portees == toset(["openid"])
    error_message = "le minimum est « openid », et rien d'autre"
  }

  assert {
    condition     = length(recodanse_webhook.effacement) == 0 && output.webhook_exige == false
    error_message = "sans portée gardée par l'effacement, aucun webhook n'est exigé ni posé (« openid » seul : rien à effacer)"
  }
}

run "profile_avec_webhook_pose_l_ecoute_de_l_effacement" {
  command = apply

  variables {
    portees     = ["openid", "profile"]
    webhook_url = "https://soirees.example/webhooks/recodanse"
  }

  assert {
    condition     = length(recodanse_webhook.effacement) == 1
    error_message = "le webhook d'effacement doit être posé"
  }

  assert {
    condition     = recodanse_webhook.effacement[0].evenements == toset(["autorisation.retiree", "compte.efface"])
    error_message = "le webhook écoute exactement autorisation.retiree et compte.efface"
  }

  assert {
    condition     = output.webhook_exige
    error_message = "« profile » est gardée par l'effacement"
  }
}

run "client_public_sans_secret" {
  command = plan

  variables {
    publique     = true
    redirections = ["fr.exemple.app:/retour"]
  }

  assert {
    condition     = recodanse_application.connexion.publique
    error_message = "le client doit être public (PKCE)"
  }
}

# ── Les refus ──────────────────────────────────────────────────────────────────

run "profile_sans_webhook_est_refuse" {
  command = plan

  variables {
    portees = ["openid", "profile"]
  }

  expect_failures = [recodanse_application.connexion]
}

run "une_portee_de_service_est_refusee" {
  command = plan

  variables {
    portees = ["openid", "evenements.publier"]
  }

  expect_failures = [var.portees]
}

run "openid_absente_est_refusee" {
  command = plan

  variables {
    portees = ["profile"]
  }

  expect_failures = [var.portees]
}

run "une_redirection_http_vers_un_hote_est_refusee" {
  command = plan

  variables {
    redirections = ["http://soirees.example/retour"]
  }

  expect_failures = [var.redirections]
}

run "un_webhook_local_est_refuse" {
  command = plan

  variables {
    webhook_url = "https://localhost/webhooks"
  }

  expect_failures = [var.webhook_url]
}

run "soumettre_sans_conditions_est_refuse" {
  command = plan

  variables {
    soumettre = true
  }

  expect_failures = [recodanse_application.connexion]
}

run "rotation_sur_un_client_public_est_refusee" {
  command = plan

  variables {
    publique = true
    rotation = { quand = "2026-11-02" }
  }

  expect_failures = [recodanse_application.connexion]
}
