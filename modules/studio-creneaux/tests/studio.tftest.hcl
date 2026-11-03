# « Studio Parquet Clair » (un nom fictif), joué avec des fournisseurs SIMULÉS.

mock_provider "recodanse" {}
mock_provider "time" {}
mock_provider "vault" {}

variables {
  nom = "Studio Parquet Clair"
  # Les runs qui n'éprouvent pas DAC7 le disent levé, pour que son avertissement
  # ne se mêle pas à leur verdict ; le premier run l'éprouve tel qu'il est par défaut.
  dac7_suspendu = false
}

run "les_creneaux_seulement_et_l_avertissement_dac7" {
  command = apply

  variables {
    dac7_suspendu = true
  }

  assert {
    condition     = module.creneaux.application_id != null && output.creneaux_visibles == false
    error_message = "le service existe, et les créneaux sont annoncés NON visibles tant que DAC7 suspend"
  }

  assert {
    condition     = length(module.connexion) == 0
    error_message = "sans `connexion`, aucune application de connexion"
  }

  # Le check avertit au plan (un avertissement, pas une erreur, hors des essais) ;
  # `tofu test` le compte comme un échec ATTENDU : c'est le témoin qu'il parle.
  expect_failures = [check.creneaux_suspendus_dac7]
}

run "les_eleves_se_connectent_et_le_studio_publie_aussi_des_stages" {
  command = apply

  variables {
    publie_aussi_des_evenements = true
    dac7_suspendu               = false
    connexion = {
      redirections = ["https://studio.example/retour"]
    }
  }

  assert {
    condition     = length(module.connexion) == 1 && output.creneaux_visibles
    error_message = "la connexion des élèves doit exister, et la levée de DAC7 se lit"
  }
}

# ── Les refus ──────────────────────────────────────────────────────────────────

run "un_nom_trop_long_pour_le_compte_de_service_est_refuse" {
  command = plan

  variables {
    nom = "Le Studio de Danse du Parquet Clair et de la Rive Gauche"
  }

  expect_failures = [var.nom]
}

run "un_site_en_http_est_refuse" {
  command = plan

  variables {
    site_web = "http://studio.example"
  }

  expect_failures = [var.site_web]
}
