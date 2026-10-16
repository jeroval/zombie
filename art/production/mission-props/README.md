# Accessoires de mission

Cinq assets originaux authored dans Blender 5.2.2 par
`scripts/build_mission_props.py` : batterie, bidon de carburant, module d'antenne,
console radio et balise d'extraction. Chaque source `.blend` est distincte et
liée à son GLB par `build.json`. Unités en mètres, Godot +Y, géométrie mid-poly,
matériaux couleur larges et traits structurels sombres.

Ces objets portent une fonction gameplay déterminante : les trois premiers se
masquent après collecte, la console déclenche la défense et la balise conclut la
partie. Le texte au-dessus conserve une redondance accessible avec la forme et
la couleur. Statut : candidats intégrés. Les cinq imports et leurs 47 instances
de mesh sont vérifiés dans Godot ; `mission-assets-final.png` et la planche GAC
`radio_console.views.png` ont été inspectées. Validation humaine ouverte.
