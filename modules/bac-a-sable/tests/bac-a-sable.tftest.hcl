# Le bac à sable, joué avec un fournisseur SIMULÉ dont les comptes fictifs sont
# ceux qu'on lui donne ici.

mock_provider "recodanse" {
  mock_data "recodanse_comptes_fictifs" {
    defaults = {
      comptes = [
        { cle = "nadia", prenom = "Nadia", titre = "danseuse de salsa" },
        { cle = "claire", prenom = "Claire", titre = "professeure de bachata" },
      ]
    }
  }
}

variables {
  nom         = "Essai de mon site"
  webhook_url = "https://mon-site.example/webhooks/recodanse"
}

run "le_premier_apply_ne_declenche_rien" {
  command = apply

  assert {
    condition     = length(recodanse_evenement_du_bac_a_sable.effacement) == 0 && output.evenement_declenche == null
    error_message = "au premier apply, rien ne part : le compte fictif n'a pas encore autorisé"
  }

  assert {
    condition     = output.compte == "nadia"
    error_message = "sans `compte`, le premier compte fictif est visé"
  }
}

run "le_second_declenche_compte_efface_pour_le_compte_choisi" {
  command = apply

  variables {
    declencher = true
    compte     = "claire"
  }

  assert {
    condition     = recodanse_evenement_du_bac_a_sable.effacement[0].evenement == "compte.efface"
    error_message = "l'événement par défaut est « compte.efface »"
  }

  assert {
    condition     = recodanse_evenement_du_bac_a_sable.effacement[0].compte == "claire"
    error_message = "le compte choisi doit être visé"
  }

  assert {
    condition     = recodanse_evenement_du_bac_a_sable.effacement[0].triggers["essai"] == "1"
    error_message = "`essai` doit passer dans triggers"
  }
}

# ── Les refus ──────────────────────────────────────────────────────────────────

run "publication_retiree_ne_se_declenche_pas_au_bac_a_sable" {
  command = plan

  variables {
    evenement = "publication.retiree"
  }

  expect_failures = [var.evenement]
}

run "un_compte_qui_n_est_pas_fictif_est_refuse" {
  command = plan

  variables {
    declencher = true
    compte     = "un-vrai-compte"
  }

  expect_failures = [recodanse_evenement_du_bac_a_sable.effacement]
}

run "un_webhook_local_est_refuse" {
  command = plan

  variables {
    webhook_url = "https://127.0.0.1:8443/webhooks"
  }

  expect_failures = [var.webhook_url]
}
