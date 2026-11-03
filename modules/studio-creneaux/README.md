---
type: "module"
title: "Studio — créneaux"
description: "Un compte de service qui publie les cours réguliers (créneaux, tarifs) — publication SUSPENDUE (DAC7) : rangés, pas montrés — et la connexion des élèves avec ReCoDanse."
tags: ["blueprint", "studio", "creneaux", "dac7"]
---
[Blueprints](../../README.md) > **Studio — créneaux**

# Studio — créneaux

Le studio publie ses **cours réguliers** (jour, heure, tarif) ; ses élèves se
connectent à son site avec leur compte ReCoDanse, sans compte de plus.

| Ce qu'il crée | Portées | Pour qui |
|---|---|---|
| module [`publier-des-evenements`](../publier-des-evenements/README.md) (« <nom> — créneaux ») ; en option [`se-connecter-avec-recodanse`](../se-connecter-avec-recodanse/README.md) | `creneaux.publier` (+ `evenements.publier` si `publie_aussi_des_evenements`) ; connexion : `openid` | un studio qui publie ses cours réguliers |

## ⚠ Les créneaux sont SUSPENDUS (DAC7)

ReCoDanse **range** les créneaux publiés mais ne les **montre** à personne tant
que l'avis juridique sur DAC7 (la directive européenne sur les revenus des
plateformes) n'est pas rendu. L'API le dit à chaque lecture : `publies: false`,
`raison: "publication_suspendue_dac7"` — et le site du studio peut l'afficher à
ses élèves.

Le module le **dit au plan** : tant que `dac7_suspendu = true` (défaut), le
`check "creneaux_suspendus_dac7"` produit un **avertissement** (jamais une
erreur : la déclaration se fait, la publication aussi), et la sortie
`creneaux_visibles` vaut `false`. Passe `dac7_suspendu = false` quand
dev.recodanse.fr annonce la levée.

## Entrées

| Variable | Défaut | Règle |
|---|---|---|
| `nom` | — | 2 à 49 caractères (le service s'appelle « <nom> — créneaux ») |
| `publie_aussi_des_evenements` | `false` | ajoute `evenements.publier` (stages, soirées) |
| `dac7_suspendu` | `true` | avertit au plan tant qu'il est vrai |
| `connexion` | `null` | `{ redirections, publique?, portees?, webhook_url? }` |
| `rotation_jours`, `rotation`, `coffre` | `90`, `{}`, `null` | voir `publier-des-evenements` ; la connexion va à `<chemin>/connexion` |
| `soumettre`, `accepte_les_conditions`, `site_web` | `false`, `null`, `""` | |

## Sorties

`creneaux`, `creneaux_visibles`, `connexion` ; **sensibles** :
`creneaux_client_secret`, `connexion_client_secret`.

## Exemple et essais

[`exemples/studio-creneaux`](../../exemples/studio-creneaux/main.tf). `tofu test` :
l'avertissement DAC7 (attendu, c'est le témoin qu'il parle) ; la connexion des
élèves et les stages ; deux refus (nom trop long, site en `http://`).
