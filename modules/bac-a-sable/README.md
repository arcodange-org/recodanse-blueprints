---
type: "module"
title: "Bac à sable"
description: "Une application d'essai, les comptes fictifs (recodanse_comptes_fictifs) et un « compte.efface » déclenché à la demande (recodanse_evenement_du_bac_a_sable) pour éprouver son webhook avant la revue."
tags: ["blueprint", "bac-a-sable", "webhook", "essai"]
---
[Blueprints](../../README.md) > **Bac à sable**

# Bac à sable

Avant la revue, il faut **prouver** que ton webhook écoute et vérifie
l'effacement. Le bac à sable des développeurs te donne des
**comptes fictifs** et déclenche **à la demande** `compte.efface` ou
`autorisation.retiree` pour l'un d'eux, signé comme en production.

| Ce qu'il crée | Portées | Pour qui |
|---|---|---|
| module [`se-connecter-avec-recodanse`](../se-connecter-avec-recodanse/README.md) ; source `recodanse_comptes_fictifs` ; `recodanse_evenement_du_bac_a_sable` (si `declencher`) | `openid`, `profile` par défaut | tout tiers qui doit prouver, avant la revue, que son webhook traite « compte.efface » |

## Deux `apply`, un geste entre eux

1. `apply` (`declencher = false`, défaut) : l'application et son webhook naissent ;
   la sortie `comptes_fictifs` liste les personas.
2. **Le geste** : ouvre ton site, « Se connecter avec ReCoDanse », réponds
   « Autoriser » **au nom du compte fictif** (« Continuer en tant que »).
3. `apply -var declencher=true` : l'événement part vers ton webhook. Il **retire
   vraiment l'accord** ; pour redéclencher, refais le geste 2 puis change `essai`.

Détruire l'événement ne fait rien (un envoi parti ne se reprend pas) ;
`compte.efface` n'efface pas le compte fictif (il sert à tous).

## ⚠ Le fournisseur doit être au bac à sable

```hcl
provider "recodanse" {
  environnement = "bac-a-sable"
  api           = "https://bac-a-sable.recodanse.fr"            # à confirmer
  emetteur      = "https://connexion.bac-a-sable.recodanse.fr"  # à confirmer
}
```

Ailleurs, la source et l'événement se **refusent dès le plan**, sans un appel. Le
module ne peut pas le vérifier lui-même (la configuration du fournisseur vit chez
l'appelant) : c'est le fournisseur qui garde cette porte.

⚠ **Le bac à sable n'est pas encore ouvert** : ses routes `/v1/bac-a-sable/*` sont un **contrat supposé** (le fournisseur
est éprouvé contre une doublure). Ce module se joue donc en `tofu test` seulement.

## Entrées

| Variable | Défaut | Règle vérifiée au plan |
|---|---|---|
| `nom` | — | 2 à 60 caractères |
| `webhook_url` | — | `https://`, hôte public |
| `evenement` | `compte.efface` | `compte.efface` ou `autorisation.retiree` (pas `publication.retiree`) |
| `compte` | `null` (le premier) | doit être une `cle` de `comptes_fictifs` |
| `declencher`, `essai` | `false`, `"1"` | |
| `redirections`, `portees` | `http://127.0.0.1:8080/retour`, `openid profile` | règles de `se-connecter-avec-recodanse` |

## Sorties

`application_id`, `client_id`, `comptes_fictifs`, `compte`,
`evenement_declenche` (sujet, instant) ; **sensibles** : `client_secret`,
`webhook_secret`.

## Exemple et essais

[`exemples/bac-a-sable`](../../exemples/bac-a-sable/main.tf). `tofu test` (comptes
fictifs simulés) : rien ne part au premier `apply` ; `compte.efface` pour le compte
choisi ; trois refus (`publication.retiree`, un compte qui n'est pas fictif, un
webhook local).
