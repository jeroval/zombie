# Quartier de Dernier Signal — modules FPS

Sources originales du projet, éditables dans Blender 5.2.2. Script reproductible :
`scripts/build_district.py`. Unités en mètres, Godot +Y en haut, façade vers +Z.
Les recettes utilisent des coordonnées Godot, converties en repère Blender.

Trois modules : clinique, garage et relais télécom. Les murs ont une épaisseur,
une entrée libre, un toit, des fenêtres encadrées, une enseigne, des joints de
construction et du mobilier identifiable. Chaque partie reste nommée et éditable.
Le fichier `build.json` lie sources et exports par empreinte ; les mêmes recettes
produisent `game/data/buildings.json` pour les colliders et la navigation.

Statut **EXPERIMENTAL** : première implantation inspectée en FPS. Import et
chemins vers les trois objectifs passent. Un parcours agent graphique par entrées
atteint l'extraction en 135,8 s. Les feuilles multivues, détails de sol,
mobilier complémentaire, collisions du mobilier et revue finale restent ouverts.
Ne pas confondre ces bâtiments avec l'acceptation artistique du quartier entier.
