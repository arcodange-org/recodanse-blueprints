# `tofu test` avec des fournisseurs SIMULÉS : aucun appel à ReCoDanse ni à Vault.

mock_provider "recodanse" {}
mock_provider "time" {}
mock_provider "vault" {}

variables {
  nom = "Billets du Quai"
}

run "un_service_qui_publie_des_evenements_et_tourne_tous_les_90_jours" {
  command = apply

  assert {
    condition     = recodanse_application.service.categorie == "service"
    error_message = "l'application doit être un compte de service"
  }

  assert {
    condition     = recodanse_application.service.portees == toset(["evenements.publier"])
    error_message = "le minimum est « evenements.publier »"
  }

  assert {
    condition     = length(time_rotating.secret) == 1 && time_rotating.secret[0].rotation_days == 90
    error_message = "la rotation planifiée par défaut est de 90 jours"
  }

  assert {
    condition     = recodanse_application.service.rotation["planifiee"] == time_rotating.secret[0].id
    error_message = "la rotation de l'application doit suivre time_rotating"
  }

  assert {
    condition     = length(vault_kv_secret_v2.service) == 0 && output.chemin_dans_le_coffre == null
    error_message = "sans coffre, rien ne part vers Vault"
  }
}

run "sans_rotation_planifiee_ni_a_la_main_aucune_rotation" {
  command = plan

  variables {
    rotation_jours = 0
  }

  assert {
    condition     = length(time_rotating.secret) == 0 && recodanse_application.service.rotation == null
    error_message = "rotation_jours = 0 sans rotation à la main : aucune rotation"
  }
}

run "la_rotation_a_la_main_s_ajoute" {
  command = plan

  variables {
    rotation_jours = 0
    rotation       = { fuite = "2026-11-02" }
  }

  assert {
    condition     = recodanse_application.service.rotation == tomap({ fuite = "2026-11-02" })
    error_message = "la rotation à la main doit passer telle quelle"
  }
}

run "avec_un_coffre_le_secret_part_vers_vault" {
  command = apply

  variables {
    coffre = { mount = "kv", chemin = "recodanse/billetterie" }
  }

  assert {
    condition     = length(vault_kv_secret_v2.service) == 1 && vault_kv_secret_v2.service[0].name == "recodanse/billetterie"
    error_message = "le secret doit être rangé au chemin demandé"
  }

  assert {
    condition     = output.chemin_dans_le_coffre == "kv/recodanse/billetterie"
    error_message = "la sortie doit nommer le chemin du coffre"
  }
}

# ── Les refus ──────────────────────────────────────────────────────────────────

run "une_portee_de_connexion_est_refusee" {
  command = plan

  variables {
    portees = ["evenements.publier", "profile"]
  }

  expect_failures = [var.portees]
}

run "une_rotation_au_dela_d_un_an_est_refusee" {
  command = plan

  variables {
    rotation_jours = 400
  }

  expect_failures = [var.rotation_jours]
}

run "un_chemin_absolu_dans_le_coffre_est_refuse" {
  command = plan

  variables {
    coffre = { mount = "kv", chemin = "/recodanse/billetterie" }
  }

  expect_failures = [var.coffre]
}

run "soumettre_sans_conditions_est_refuse" {
  command = plan

  variables {
    soumettre = true
  }

  expect_failures = [recodanse_application.service]
}
