# Journal de développement

## 16 octobre 2026 — cadrage initial

Le créateur délègue la réalisation jusqu'à 18 h et autorise branches/commits,
outils locaux, téléchargements et recherches. Le dépôt contient le studio préparé
pendant le tour précédent ; aucune mécanique de jeu n'existe au démarrage.

Décision DS-D01 : réaliser **Dernier Signal**, une partie de survie/action
isométrique finie, avec trois composants, une radio et une évacuation. Le choix
exploite le thème zombie du dépôt et permet de concentrer le travail sur une
expérience complète. Alternative écartée : sandbox de survie avec construction,
trop dispersée pour la fenêtre disponible. Réviser si le prototype révèle une
progression répétitive ou une finale sans décision intéressante.

Décision DS-D02 : prioriser les assets animés réutilisables CC0, puis adaptation
Blender et rendu encré. Évite de consacrer le budget initial à une génération
de personnage dont le rig et les animations seraient encore inconnus.

Décision DS-D03 : mesurer avec le module métrique GAC existant. Les tokens de
cette interface restent inconnus faute de traces `codex exec --json` attribuables.
Les totaux cumulés d'un autre périmètre ne sont pas transformés en coût de ce jeu.

Travail précédent : **progression vérifiée**, puisqu'il a créé le studio et ses
preuves techniques. Le tour actuel ouvre le contrat de jeu ; il ne réutilise
pas ces preuves pour certifier le gameplay.

## 12 h 20 — correction créateur, DS-V2

Le créateur impose explicitement un **FPS 3D**. Le choix isométrique DS-D01
est annulé : il venait de l'agent, pas de la demande. La boucle radio/extraction
est conservée, avec caméra à hauteur des yeux, souris, arme de première personne
et niveaux conçus pour cette perspective. Aucun gameplay isométrique n'avait
été implémenté. Le tour de simple acquiescement n'a pas modifié le dépôt ;
ce tour applique réellement la correction et ouvre M1.

## 12 h 25 — boucle FPS et première vérification

Implémentés : contrôleur première personne, collisions, tir hitscan, recharge,
mêlée, soins, endurance, deux vitesses d'infectés avec perception et chemins,
collecte des trois composants, appel, défense, extraction, mort et relance.
Les tests GDScript passent pour les règles et le déplacement par entrée injectée.
Le test de victoire accélère le temps et déplace le joueur : il ne prouve pas
encore un parcours complet par les commandes normales. Capture graphique FPS
inspectée : blockout volontairement brut. Un événement de recentrage souris
provoquait un saut du regard ; ajout d'une courte fenêtre de stabilisation.
Tests Python et Ruff inchangés passent. Assets, sons, options et build restent
à produire ; M1 n'est pas clos sur ces seuls tests.

## 12 h 35 — premier parcours par entrées et assets candidats

Parcours agent graphique réussi sans téléportation, santé ajoutée ni saut de
phase : 148,32 s, 3 composants, 34 neutralisations, 112 tirs, extraction vivante.
Le mode headless n'émule pas la capture souris et ne convient pas à ce test.
Ce résultat prouve une stratégie gagnante ; la durée cible et le plaisir humain
ne sont pas validés. L'agent connaît les positions, vise exactement et soigne
immédiatement. Il révèle aussi un quartier encore trop simple pour le rythme visé.

Commit `df9e8f5` conserve la boucle blockout ; nouvelle branche
`feat/fps-art-and-playability`. Téléchargement direct des sources officielles
Quaternius CC0, provenance et empreintes conservées. Douze exports adaptés,
zombie animé et pistolet intégrés comme candidats. Le contrat glTF des UV,
poids, joints et animations passe ; les poses de 50 os changent dans Godot.
Captures Idle et Punch inspectées avec véhicule et arme. Restent notamment
mains FPS, ville authored, audio, feedback, options, feuilles multivues et export.

## 12 h 45 — intérieurs et second parcours

Clinique, garage et télécom ont désormais des sources Blender, portes, fenêtres,
enseignes, joints et mobilier. Les objectifs sont à l'intérieur. Les colliders
des murs et le maillage de navigation dérivent de la recette de bâtiment.
Correction de navigation : utiliser les centres entiers réellement inclus dans
la boîte élargie, au lieu d'arrondir vers l'extérieur et fermer les portes.
Le test de détour a déplacé son départ hors du nouveau camion ; il exige un
vrai contournement, sans conserver une coordonnée désormais occupée.

Parcours graphique agent après intégration : victoire à 135,8 s, santé 82,
trois composants, 34 infectés neutralisés, 111 tirs. Test de règles également
réussi. Preuve reproductible dans `docs/indicateurs/parcours-fps-district.json`.
M1 est vérifié au niveau prototype. M2 reste ouvert : sol, limites, radio et
objets sont encore provisoires ; mains, feuilles multivues et revue artistique
complète manquent. La rapidité du bot ne valide pas la durée humaine cible.
