---
type: "module"
title: "Billetterie"
description: "Un compte de service qui publie ses dates par sa référence, un webhook « publication.retiree » pour ne pas republier une date retirée, et en option « Se connecter avec ReCoDanse »."
tags: ["blueprint", "billetterie", "service", "webhook"]
---
[Blueprints](../../README.md) > **Billetterie**

# Billetterie

Une billetterie branche **une fois** sa base de dates : publier, reporter (même
référence), annuler (`annule: true`), retirer — ReCoDanse suit. Ce module pose ce
qu'il lui faut côté ReCoDanse ; le code qui publie (`PUT /v1/evenements/{ref}`)
reste chez elle.

| Ce qu'il crée | Portées | Pour qui |
|---|---|---|
| module [`publier-des-evenements`](../publier-des-evenements/README.md) (« <nom> — dates ») ; `recodanse_webhook` `publication.retiree` ; en option module [`se-connecter-avec-recodanse`](../se-connecter-avec-recodanse/README.md) et les secrets dans Vault | `evenements.publier` ; connexion : `openid` par défaut | une billetterie qui publie ses dates et veut savoir quand l'une est retirée |

## Pourquoi `publication.retiree`

**Une date retirée ne ressuscite pas** : la republier par la
même référence est refusé (`400 evenement_retire`). Mais quand c'est la
**modération** de ReCoDanse qui la retire, la billetterie ne le sait pas — sauf
si elle écoute `publication.retiree` (au catalogue des webhooks, lu dans le
fournisseur : `autorisation.retiree`, `compte.efface`, `publication.retiree`).

Le compte de service ne reçoit **aucune donnée personnelle** : il n'écoute ni
`autorisation.retiree` ni `compte.efface`. Ceux-là vont au webhook de la
connexion, si `connexion` est donnée et demande une portée gardée par l'effacement.

⚠ **Ce qui ne s'essaie pas encore** : `publication.retiree` ne se déclenche
aujourd'hui que par la modération de ReCoDanse — le bac à sable des développeurs
ne sait déclencher que `autorisation.retiree` et `compte.efface`.

## Entrées

| Variable | Défaut | Règle |
|---|---|---|
| `nom` | — | 2 à 52 caractères (le service s'appelle « <nom> — dates ») |
| `webhook_url` | — | `https://`, hôte public |
| `rotation_jours`, `rotation` | `90`, `{}` | voir `publier-des-evenements` |
| `connexion` | `null` | `{ redirections, publique?, portees?, webhook_url? }` — règles de `se-connecter-avec-recodanse` |
| `coffre` | `null` | `{ mount, chemin }` : service à `<chemin>`, webhooks à `<chemin>/webhooks`, connexion à `<chemin>/connexion` |
| `soumettre`, `accepte_les_conditions` | `false`, `null` | pour les deux applications |

## Sorties

`dates` (application_id, client_id, statut, prochaine_rotation), `connexion` ;
**sensibles** : `dates_client_secret`, `webhook_publication_retiree`,
`connexion_client_secret`.

## Exemple et essais

[`exemples/billetterie`](../../exemples/billetterie/main.tf). `tofu test` :
le service et son webhook ; la connexion et le coffre ; deux refus (webhook sur
une adresse privée, nom trop long pour le service).
