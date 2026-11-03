# « L'École des Trois Salles » (un nom fictif), jouée avec des fournisseurs SIMULÉS.

mock_provider "recodanse" {}
mock_provider "time" {}
mock_provider "vault" {}

variables {
  nom = "L'École des Trois Salles"
  salles = [
    { cle = "grande", nom = "La grande salle" },
    { cle = "miroirs", nom = "La salle des miroirs" },
    { cle = "jardin", nom = "Le jardin d'hiver" },
  ]
  # L'avertissement DAC7 est éprouvé par studio-creneaux.
  dac7_suspendu = false
}

run "une_application_pour_trois_salles" {
  command = apply

  assert {
    condition     = length(local.salles) == 3 && local.salles["miroirs"].prefixe_de_reference == "miroirs/"
    error_message = "chaque salle doit avoir son préfixe de référence"
  }

  assert {
    condition     = length(recodanse_webhook.publication_retiree) == 0
    error_message = "sans webhook_url, aucun webhook"
  }
}

run "avec_le_webhook_des_retraits" {
  command = apply

  variables {
    webhook_url = "https://ecole.example/webhooks/recodanse"
  }

  assert {
    condition     = recodanse_webhook.publication_retiree[0].evenements == toset(["publication.retiree"])
    error_message = "le webhook écoute « publication.retiree »"
  }
}

# ── Les refus ──────────────────────────────────────────────────────────────────

run "deux_salles_de_meme_cle_sont_refusees" {
  command = plan

  variables {
    salles = [
      { cle = "grande", nom = "La grande salle" },
      { cle = "grande", nom = "L'autre grande salle" },
    ]
  }

  expect_failures = [var.salles]
}

run "une_seule_salle_est_refusee" {
  command = plan

  variables {
    salles = [{ cle = "grande", nom = "La grande salle" }]
  }

  expect_failures = [var.salles]
}

run "une_cle_avec_un_espace_est_refusee" {
  command = plan

  variables {
    salles = [
      { cle = "grande salle", nom = "La grande salle" },
      { cle = "jardin", nom = "Le jardin d'hiver" },
    ]
  }

  expect_failures = [var.salles]
}
