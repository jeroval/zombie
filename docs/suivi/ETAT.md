# État du développement

Mis à jour : 16 octobre 2026, 12 h 20 Europe/Paris. Vision DS-V2.

- **Objectif global** : livrer Dernier Signal complet et vérifié avant 18 h.
- **Dernier résultat réel** : boucle FPS en blockout, règles de mission testées.
- **Jalon actif** : M1, boucle FPS complète en blockout.
- **Prochain résultat** : M1, partie de bout en bout jouable en blockout.
- **Branche** : `feat/fps-art-and-playability` ; boucle initiale conservée sur `feat/dernier-signal`.
- **Blocage global** : aucun constaté.
- **Incertain** : adaptation du kit animé, navigation, rythme, export templates.

## Couverture

| Domaine | Prévu | Implémenté | Vérifié runtime | Accepté visuellement / en jeu |
| --- | --- | --- | --- | --- |
| Studio et MCP | Oui | Oui | Oui, preuves de bootstrap | Rendu de calibration seulement |
| Boucle de partie | Oui | Blockout complet | Transitions scriptées testées | Parcours réel restant |
| Déplacement et combat | Oui | FPS, tir, mêlée, recharge | Entrée déplacement, murs, munitions | Capture FPS inspectée ; combat à éprouver |
| Carte et objectifs | Oui | Blockout, trois lieux, radio, extraction | Chemins et collecte testés | Habillage final restant |
| Assets et animations | Oui | Non | Non | Non |
| HUD, menus, options | Oui | HUD et menu initiaux ; options restantes | Menu/relance testés | Lisibilité initiale inspectée |
| Son et musique | Oui | Non | Non | Non |
| Build autonome | Oui | Non | Non | Non |

## Reprise

Lire ce fichier, la roadmap, puis `git status` et les trois derniers commits.
Consulter seulement le dernier épisode métrique et les incidents ouverts.
Ne pas confondre le prototype intermédiaire avec les conditions de livraison.
