# État du développement

Mis à jour : 16 octobre 2026, 12 h 45 Europe/Paris. Vision DS-V2.

- **Objectif global** : livrer Dernier Signal complet et vérifié avant 18 h.
- **Dernier résultat réel** : parcours FPS graphique gagnant avec trois intérieurs et infectés animés.
- **Jalon actif** : M2, quartier, mains FPS et présentation finale.
- **Prochain résultat** : décor de rue, radio/objets réels, arme tenue en mains et feedback lisible.
- **Branche** : `feat/fps-art-and-playability` ; boucle initiale conservée sur `feat/dernier-signal`.
- **Blocage global** : aucun constaté.
- **Incertain** : rythme et durée cible, qualité finale des assets, export autonome.

## Couverture

| Domaine | Prévu | Implémenté | Vérifié runtime | Accepté visuellement / en jeu |
| --- | --- | --- | --- | --- |
| Studio et MCP | Oui | Oui | Oui, preuves de bootstrap | Rendu de calibration seulement |
| Boucle de partie | Oui | Complète au stade prototype | Règles et parcours graphique par entrées | Agent gagne ; rythme humain non mesuré |
| Déplacement et combat | Oui | FPS, tir, mêlée, recharge | Entrées, murs, munitions, soins en parcours | Manquent mains et retours sonores/visuels finis |
| Carte et objectifs | Oui | Trois intérieurs, radio, extraction | Chemins, portes et collecte testés | Habillage final restant |
| Assets et animations | Oui | Candidats Blender/GLB, zombie animé, bâtiments | Import, canaux et poses inspectés | Feuilles et revue finale ouvertes |
| HUD, menus, options | Oui | HUD et menu initiaux ; options restantes | Menu/relance testés | Lisibilité initiale inspectée |
| Son et musique | Oui | Non | Non | Non |
| Build autonome | Oui | Non | Non | Non |

## Reprise

Lire ce fichier, la roadmap, puis `git status` et les trois derniers commits.
Consulter seulement le dernier épisode métrique et les incidents ouverts.
Ne pas confondre le prototype intermédiaire avec les conditions de livraison.
