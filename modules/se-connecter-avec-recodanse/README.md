---
type: "module"
title: "Se connecter avec ReCoDanse"
description: "Une application OpenID Connect (publique PKCE ou confidentielle), ses portées minimales, et le webhook d'effacement quand une portée l'exige."
tags: ["blueprint", "connexion", "oidc", "webhook"]
---
[Blueprints](../../README.md) > **Se connecter avec ReCoDanse**

# Se connecter avec ReCoDanse

« Se connecter avec ReCoDanse » sur ton site : la personne autorise, ton site
reçoit un **sujet** stable (et, si tu le demandes, son prénom public ou son
adresse). Ce module déclare l'application `connexion` et, quand il le faut, le
webhook qui te prévient d'un retrait.

| Ce qu'il crée | Portées | Pour qui |
|---|---|---|
| `recodanse_application` (`connexion`) ; `recodanse_webhook` (`autorisation.retiree`, `compte.efface`) si `webhook_url` | `openid` par défaut ; jusqu'à `profile`, `email`, `offline_access`, `videos.*`, `programmes.poser`, `evenements.proposer` | tout site qui veut connaître ses danseurs ; le socle des autres modules |

## Pourquoi le webhook n'est pas toujours exigé

Le webhook d'effacement sert à **effacer** ce que tu gardes d'une personne quand
elle retire son accord ou efface son compte.

- Avec `openid` **seul**, tu ne reçois qu'un **sujet pseudonyme** — propre à ton
  application, inutilisable ailleurs. Il n'y a rien à effacer que tu tiennes de
  ReCoDanse : le webhook n'est **pas exigé**, et
  l'application se soumet à la revue dès le premier `apply`.
- Dès que tu demandes une portée qui te **donne** une donnée à garder — `profile`
  (prénom), `email`, `offline_access` (un accès qui dure), `videos.lire` —, la
  revue exige un webhook abonné à `autorisation.retiree` **et** `compte.efface`,
  qui répond 2xx à un essai signé et 4xx au même essai **mal** signé.
  Le module refuse alors le plan tant que `webhook_url` manque.
- Les portées d'**écriture** (`videos.deposer`, `videos.annoter`,
  `programmes.poser`, `evenements.proposer`) ne te donnent rien à garder : elles
  n'exigent pas le webhook.

⚠ Le webhook dépend de l'identifiant de l'application, donc il naît **après**
elle : avec `soumettre = true` et une portée gardée, le premier `apply` déclare
et avertit (`portee_sans_webhook_d_effacement`), le second soumet.

## Entrées

| Variable | Défaut | Règle vérifiée au plan |
|---|---|---|
| `nom` | — | 2 à 60 caractères, sans espace au bord |
| `redirections` | — | 1 à 10 ; `https://`, `http://127.0.0.1`, ou schéma d'app native à domaine inversé |
| `publique` | `false` | `true` : PKCE, aucun secret ; changer recrée l'application |
| `portees` | `["openid"]` | contient `openid` ; toutes au catalogue `connexion` |
| `webhook_url` | `null` | `https://`, hôte public ; exigée avec une portée gardée |
| `rotation` | `null` | refusée sur un client public |
| `soumettre`, `accepte_les_conditions` | `false`, `null` | soumettre exige une version `AAAA-MM-JJ` écrite de ta main |
| `description`, `site_web` | `""` | 500 caractères ; `https://` |

## Sorties

`application_id`, `client_id`, `statut`, `webhook_id`, `webhook_exige` ;
**sensibles** : `client_secret` (nul pour un client public), `webhook_secret`
(`whsec_…`). Envoie-les vers un coffre (voir
[`rotation-vers-un-coffre`](../rotation-vers-un-coffre/README.md)), jamais vers
un journal.

## Exemple

[`exemples/se-connecter-avec-recodanse`](../../exemples/se-connecter-avec-recodanse/main.tf).

## Essais

`tofu test` (fournisseur simulé) : le minimum `openid` sans webhook ; `profile`
avec webhook ; le client public ; et sept refus (portée de service, `openid`
absente, `http://` vers un hôte, webhook local, `profile` sans webhook, soumettre
sans conditions, rotation d'un client public).
