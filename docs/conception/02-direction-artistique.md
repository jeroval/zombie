# Direction artistique et sonore — DS-V1

Référence de production : `gac.inked-comic-3d` révision 1 et
`gac.dessin-encre-3d` révision 1, plugin GAC 3.38.0.

Quartier de fin de journée : grands aplats bleu ardoise, murs crème poussière,
couleurs de signal ambre/cyan et infectés verdâtres. La survivante se distingue
par une veste chaude et une silhouette compacte. Le sang reste stylisé ; pas
de détails gore réalistes. La fiction est originale, sans reprise d'un autre projet.

Les huit piliers du plugin sont conservés : silhouettes dessinées, géométrie
contrôlée, surfaces illustrées, encrage intérieur, contours hiérarchisés,
valeurs toon, cohérence entre familles et lisibilité à la caméra de jeu.
Le catalogue normatif exact est extrait dans `docs/indicateurs/catalogue-plugin.json`.

## Grammaire à vérifier

- Grandes masses lisibles ; fenêtres, coutures, arêtes et assemblages encrés.
- Contour extérieur plus fort que les traits intérieurs ; cible initiale 2 px
  à 1080p, traits intérieurs environ 1 px, ajustés au vrai angle de caméra.
- Trois groupes diffus dominants ; valeurs initiales 0,38 / 0,70 / 1,00,
  seuils 0,35 / 0,68. Les ombres portées renforcent les volumes.
- Texture peinte sobre ; les détails fins ne doivent pas devenir un bruit uniforme.
- Toutes les familles partagent palette, lignes et lumière. Aucun pack ne conserve
  une apparence incompatible au seul motif qu'il est déjà importé.

## Sources et budgets initiaux

Rechercher d'abord un kit animé CC0 cohérent. Candidat identifié : Quaternius
Zombie Apocalypse Kit, page officielle et licence à archiver avant intégration.
Les sources locales déjà testées sont des preuves d'outillage, pas des assets
de jeu approuvés. Blender conserve les sources adaptées ; GLB pour Godot.

Budgets indicatifs à valider au rendu : acteur 3–12 k triangles, objet courant
0,2–4 k, véhicule 3–15 k, bâtiment 3–20 k ; atlas 1024–2048 pour les familles.
Caméra de jeu à environ 15–22 m, acteurs lisibles sur 60–120 px en 1080p.
Au plus 40–60 infectés actifs selon mesures. Les effets doivent rester sobres
et conserver leurs informations quand la caméra tremble est désactivée.

## Son

Ambiance urbaine vide, vent discret, souffle radio et pulsation musicale qui
monte pendant l'appel. Tirs secs, attaques de mêlée distinctes, impacts et
grognements localisables. Retours de collecte et de validation brefs. Messages
radio sous-titrés ; la voix ne doit jamais être indispensable à la compréhension.
Limiter le nombre de sons simultanés et le niveau des tirs répétitifs.

## Preuves requises

Calibration personnage + objet + bâtiment dans Godot ; captures proches, caméra
de jeu et éloignées ; séquences de course, attaque et dégâts. Vérifier silhouettes,
traits intérieurs, contours, lumière et HUD dans le même cadre. Les références,
sources, exports et captures restent identifiables par leur révision.
