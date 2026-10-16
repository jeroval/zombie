# Quaternius — candidats adaptés pour Dernier Signal

Statut : candidats tiers intégrés, avec licence et provenance conservées.
Sources originales et licence : `../../vendor/quaternius-zombie/provenance.json`.
Page officielle : https://quaternius.com/packs/zombieapocalypsekit.html (CC0).
Le fichier de licence fourni utilise un ancien titre de pack ; il est conservé
tel quel, avec la page officielle qui identifie ce kit et sa licence.

Construction reproductible : `scripts/build_vendor_assets.py` lancé par Blender
5.2.2 en arrière-plan avec `--factory-startup`. Chaque source reste éditable ;
les atlas sont empaquetés. Les bandes d'encrage structurel sont des meshes
distincts ; pour le zombie elles suivent les mêmes poids et le même squelette.
La lumière toon et le contour sont appliqués par `game/scripts/art_style.gd`,
depuis les shaders de calibration GAC 3.38.0 copiés dans le projet.

`build.json` contient les chemins, empreintes, triangles, normalisation et actions.
La normalisation du zombie vise 1,75 m ; le pistolet est réduit à 34 % de sa
source. La face avant des personnages nécessite une rotation Y de 180° par
rapport au contrôleur qui regarde vers -Z. Les collisions restent dans Godot.

Premières preuves : import Godot réussi, squelette de 50 os et poses réellement
différentes en Idle/Walk/Punch/Death ; captures `asset_anchor.gd` inspectées.
Le zombie, le véhicule et le pistolet sont reconnaissables dans la même scène.
`zombie_basic.views.png` est une feuille GAC courante et inspectée. Le pistolet
est désormais tenu par le viewmodel original du projet et les captures montrent
le quartier habillé. L'acceptation artistique humaine reste ouverte.

Les avertissements d'export sur les contraintes du rig sont résolus par le
baking de l'exporteur ; les influences sont réduites à quatre par sommet.
La fidélité visuelle des déformations doit donc rester contrôlée en moteur.
