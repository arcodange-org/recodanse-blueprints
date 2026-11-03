# La combinaison rotation → coffre, jouée avec des fournisseurs SIMULÉS.

mock_provider "recodanse" {}
mock_provider "time" {}
mock_provider "vault" {}

variables {
  service = { nom = "Billets du Quai — dates" }
  connexion = {
    nom          = "Billets du Quai"
    redirections = ["https://billets-du-quai.example/retour"]
  }
}

run "un_rythme_commun_et_sans_coffre_rien_ne_part_vers_vault" {
  command = apply

  assert {
    condition     = time_rotating.rythme.rotation_days == 90
    error_message = "le rythme par défaut est de 90 jours"
  }

  assert {
    condition     = length(vault_kv_secret_v2.connexion) == 0 && length(vault_kv_secret_v2.service) == 0
    error_message = "sans coffre, rien ne part vers Vault"
  }

  assert {
    condition     = length(output.chemins_dans_le_coffre) == 0
    error_message = "sans coffre, aucun chemin"
  }
}

run "avec_un_coffre_chaque_secret_tourne_y_part" {
  command = apply

  variables {
    coffre   = { mount = "kv", prefixe = "recodanse/billets-du-quai" }
    rotation = { fuite = "2026-11-02" }
  }

  assert {
    condition     = vault_kv_secret_v2.service[0].name == "recodanse/billets-du-quai/service" && vault_kv_secret_v2.connexion[0].name == "recodanse/billets-du-quai/connexion"
    error_message = "les deux secrets vont sous le préfixe"
  }

  assert {
    condition     = module.service[0].rotation["fuite"] == "2026-11-02" && module.service[0].rotation["planifiee"] == time_rotating.rythme.id
    error_message = "le service tourne au rythme commun ET à la main"
  }
}

# ── Les refus ──────────────────────────────────────────────────────────────────

run "sans_application_est_refuse" {
  command = plan

  variables {
    service   = null
    connexion = null
  }

  expect_failures = [time_rotating.rythme]
}

run "zero_jour_est_refuse" {
  command = plan

  variables {
    rotation_jours = 0
  }

  expect_failures = [var.rotation_jours]
}

run "la_cle_planifiee_est_reservee" {
  command = plan

  variables {
    rotation = { planifiee = "x" }
  }

  expect_failures = [var.rotation]
}
