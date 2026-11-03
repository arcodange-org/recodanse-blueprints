---
type: "module"
title: "Publier des événements"
description: "Un compte de service qui publie des événements (ou des créneaux) pour le compte qui l'a déclaré, son secret qui tourne seul (time_rotating) ou à la main, et, en option, rangé dans Vault."
tags: ["blueprint", "service", "rotation", "vault"]
---
[Blueprints](../../README.md) > **Publier des événements**

# Publier des événements

Un **compte de service** (`client_credentials`) : ton logiciel publie tes
soirées, stages et festivals dans l'agenda de ReCoDanse, **pour le compte qui l'a
déclaré** — aucune personne n'autorise, aucune donnée personnelle ne circule.
C'est aussi le moteur des modules [`billetterie`](../billetterie/README.md),
[`studio-creneaux`](../studio-creneaux/README.md) et
[`ecole-plusieurs-salles`](../ecole-plusieurs-salles/README.md).

| Ce qu'il crée | Portées | Pour qui |
|---|---|---|
| `recodanse_application` (`service`) ; `time_rotating` (si `rotation_jours > 0`) ; `vault_kv_secret_v2` (si `coffre`) | `evenements.publier` (défaut) ; `creneaux.publier` possible | un agenda, un festival, une billetterie qui publient leurs dates |

## Le secret qui tourne

- **Planifié** : `rotation_jours` (défaut 90). `time_rotating` change d'identifiant à
  l'échéance ; le **premier `apply` après** la date fait tourner le secret.
- **À la main** : `rotation = { fuite = "2026-11-02" }` — changer une valeur fait
  tourner tout de suite (la procédure « un jeton a fui » : couper d'abord).
- ⚠ **L'ancien secret cesse de valoir à l'instant** (Hydra n'en garde qu'un), et
  pour un compte de service, ses jetons en cours sont révoqués.
  Le nouveau doit atteindre ton logiciel **dans la même minute** : c'est pourquoi
  `coffre` l'écrit dans Vault **dans le même `apply`**.

## Entrées

| Variable | Défaut | Règle vérifiée au plan |
|---|---|---|
| `nom` | — | 2 à 60 caractères, sans espace au bord |
| `portees` | `["evenements.publier"]` | `evenements.publier`, `creneaux.publier` seulement |
| `rotation_jours` | `90` | entier, 0 à 365 (0 : à la main seulement) |
| `rotation` | `{}` | carte libre |
| `coffre` | `null` | `{ mount, chemin }`, chemin relatif |
| `soumettre`, `accepte_les_conditions` | `false`, `null` | soumettre exige une version écrite de ta main |
| `description`, `site_web` | `""` | 500 caractères ; `https://` |

Le fournisseur `vault` ne sert que si `coffre` est donné : sans lui, aucune
ressource Vault n'existe et rien ne l'appelle (plan joué sans `VAULT_ADDR`).

## Sorties

`application_id`, `client_id`, `statut`, `prochaine_rotation`,
`chemin_dans_le_coffre` ; **sensible** : `client_secret`.

## Exemple

[`exemples/publier-des-evenements`](../../exemples/publier-des-evenements/main.tf).

## Essais

`tofu test` (fournisseurs simulés) : la rotation de 90 jours par défaut, sans
rotation, la rotation à la main, le secret vers Vault ; quatre refus (portée de
connexion, rotation au-delà d'un an, chemin absolu dans le coffre, soumettre sans
conditions).
