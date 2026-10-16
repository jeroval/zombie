# État du développement

Mis à jour : 16 octobre 2026, 13 h 20 Europe/Paris. Vision DS-V2.

- **Objectif global** : livrer Dernier Signal complet et vérifié avant 18 h.
- **Dernier résultat réel** : parcours FPS graphique gagnant après intégration des rues, objets de mission, mains, audio et retours de combat.
- **Jalon actif** : M4, performance et réglages de jouabilité.
- **Prochain résultat** : sonde graphique représentative, correction des points chauds, puis export Windows autonome.
- **Branche** : `feat/fps-art-and-playability` ; boucle initiale conservée sur `feat/dernier-signal`.
- **Blocage global** : aucun constaté.
- **Incertain** : rythme et durée cible pour un joueur humain, mixage sur d'autres systèmes audio, export autonome.

## Couverture

| Domaine | Prévu | Implémenté | Vérifié runtime | Accepté visuellement / en jeu |
| --- | --- | --- | --- | --- |
| Studio et MCP | Oui | Oui | Oui, preuves de bootstrap et planches GAC courantes | Outils et cinq planches inspectés |
| Boucle de partie | Oui | Complète | Règles et parcours graphique par entrées | Agent gagne en 135,88 s ; rythme humain non mesuré |
| Déplacement et combat | Oui | FPS, tir, mêlée, recharge, mains et retours | Entrées, murs, munitions, soins et feedback testés | Capture FPS inspectée ; validation humaine ouverte |
| Carte et objectifs | Oui | Trois intérieurs, rues, radio, extraction, réserves | Chemins, portes, collecte et ressources testés | Parcours habillé inspecté |
| Assets et animations | Oui | Sources Blender, GLB, zombie animé et rendu encré | Import, canaux, poses et planches courantes | Revue agent faite ; acceptation créateur ouverte |
| HUD, menus, options | Oui | HUD, pause, options et meilleurs résultats persistants | Contrat de présentation réussi | Menu 1152 × 648 inspecté |
| Son et musique | Oui | Ambiance, effets et quatre voix françaises | Lecture réelle sur le backend audio | Mixage humain ouvert |
| Build autonome | Oui | Non | Non | Non |

## Reprise

Lire ce fichier, la roadmap, puis `git status` et les trois derniers commits.
Consulter seulement le dernier épisode métrique et les incidents ouverts.
Ne pas confondre le prototype intermédiaire avec les conditions de livraison.
