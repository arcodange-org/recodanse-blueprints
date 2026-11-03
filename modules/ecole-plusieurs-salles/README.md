---
type: "module"
title: "École à plusieurs salles"
description: "UNE application de service publie les créneaux de toutes les salles, chaque salle préfixe la référence de ses cours ; modifier = même référence, annuler = DELETE."
tags: ["blueprint", "ecole", "creneaux", "dac7"]
---
[Blueprints](../../README.md) > **École à plusieurs salles**

# École à plusieurs salles

Une école a plusieurs **lieux** ; elle n'a pas besoin d'une application par
salle. **Une** application de service publie pour toutes : une salle est le lieu
d'un créneau, pas un objet de ReCoDanse. Le module donne au site, pour chaque
salle, le **préfixe** de la référence de ses créneaux (`miroirs/mardi-salsa-20h`) :
deux cours de même nom dans deux salles ne se confondent pas, et l'école modifie
un cours en reprenant sa référence (`PUT`, même cours) ou l'annule (`DELETE` :
ReCoDanse le garde « retiré », le site le cache).

| Ce qu'il crée | Portées | Pour qui |
|---|---|---|
| module [`studio-creneaux`](../studio-creneaux/README.md) ; en option `recodanse_webhook` `publication.retiree` | `creneaux.publier` ; connexion : `openid` | une école qui donne ses cours dans plusieurs salles |

⚠ **Créneaux SUSPENDUS (DAC7)** : rangés, pas montrés, tant que l'avis juridique
n'est pas rendu — le plan l'avertit (voir
[`studio-creneaux`](../studio-creneaux/README.md#-les-créneaux-sont-suspendus-dac7)).

## Entrées

| Variable | Défaut | Règle vérifiée au plan |
|---|---|---|
| `nom` | — | 2 à 49 caractères |
| `salles` | — | 2 à 20 ; `cle` en minuscules, chiffres, tirets (24 au plus), **unique** ; `nom` lisible |
| `webhook_url` | `null` | `https://`, hôte public |
| `dac7_suspendu` | `true` | avertit au plan |
| `connexion`, `rotation_jours`, `coffre`, `soumettre`, `accepte_les_conditions`, `site_web` | | voir `studio-creneaux` |

## Sorties

`creneaux`, `salles` (nom et `prefixe_de_reference` par clé), `creneaux_visibles`,
`connexion` ; **sensibles** : `creneaux_client_secret`, `webhook_publication_retiree`.

## Exemple et essais

[`exemples/ecole-plusieurs-salles`](../../exemples/ecole-plusieurs-salles/main.tf).
`tofu test` : trois salles, une application ; le webhook des retraits ; trois
refus (deux salles de même clé, une seule salle, une clé avec un espace).
