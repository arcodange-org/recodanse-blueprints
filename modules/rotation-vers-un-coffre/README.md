---
type: "module"
title: "Rotation vers un coffre"
description: "La combinaison : les secrets d'une connexion confidentielle et d'un compte de service tournent à un rythme commun (time_rotating) ou à la main, et partent dans Vault (vault_kv_secret_v2) dans le même apply — derrière la variable `coffre`."
tags: ["blueprint", "rotation", "vault", "securite"]
---
[Blueprints](../../README.md) > **Rotation vers un coffre**

# Rotation vers un coffre

Hydra ne garde **qu'un** secret par client : faire tourner coupe l'ancien **à
l'instant**. Le seul ordre sûr est donc : tourner, puis écrire le nouveau au
coffre **dans le même `apply`**, et des consommateurs qui **relisent** le coffre
(agent Vault, External Secrets) plutôt qu'une copie prise au démarrage.

| Ce qu'il crée | Portées | Pour qui |
|---|---|---|
| `time_rotating` (rythme commun) ; modules [`se-connecter-avec-recodanse`](../se-connecter-avec-recodanse/README.md) (confidentiel) et/ou [`publier-des-evenements`](../publier-des-evenements/README.md) ; `vault_kv_secret_v2` `<prefixe>/connexion` et `<prefixe>/service` si `coffre` | celles des applications données | tout tiers qui range ses secrets dans Vault ; la procédure « un jeton a fui » |

## Les deux rotations

- **Planifiée** : `rotation_jours` (1 à 365, défaut 90), commune à toutes les
  applications du module ; le premier `apply` après `prochaine_rotation` tourne.
- **À la main** : `rotation = { fuite = "2026-11-02" }` fait tourner **tout** d'un
  coup — l'étape 1 (« couper ») de la procédure quand un secret a fui.

La clé `whsec_…` d'un webhook **ne tourne pas** (l'API n'a pas de route pour la faire tourner) :
pour la changer, recréer le webhook (`tofu apply -replace=…`). Elle est écrite au
coffre à côté du secret de connexion.

## `coffre`, optionnel

`coffre = null` (défaut) : rien ne part vers Vault, et le fournisseur `vault` n'est
jamais appelé — les secrets ne sortent que par la sortie **sensible** `secrets`.
Avec `coffre = { mount, prefixe }`, ils vont à `<mount>/<prefixe>/connexion` et
`<mount>/<prefixe>/service`, avec en métadonnée l'application et l'instant de
rotation. Le fournisseur `vault` se configure chez l'appelant, par une identité de
CI (JWT/OIDC), jamais par un jeton écrit dans un fichier.

## Entrées

| Variable | Défaut | Règle vérifiée au plan |
|---|---|---|
| `connexion` | `null` | `{ nom, redirections, portees?, webhook_url? }` — toujours confidentielle |
| `service` | `null` | `{ nom, portees? }` |
| — | | l'une ou l'autre est exigée |
| `rotation_jours` | `90` | entier, 1 à 365 |
| `rotation` | `{}` | la clé `planifiee` est réservée |
| `coffre` | `null` | `{ mount, prefixe }`, préfixe relatif |

## Sorties

`prochaine_rotation`, `chemins_dans_le_coffre`, `client_ids` ; **sensible** :
`secrets`.

## Exemple et essais

[`exemples/rotation-vers-un-coffre`](../../exemples/rotation-vers-un-coffre/main.tf).
`tofu test` : un rythme commun sans coffre ; les deux secrets au coffre avec la
rotation à la main ; trois refus (aucune application, zéro jour, clé réservée).
