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

## 13 h 20 — quartier FPS, présentation et audio intégrés

Le quartier dispose désormais de routes, trottoirs, passage refuge, façade de
fond et repères d'extraction authored dans Blender. Les trois composants, la
radio et la balise ont chacun un modèle original ; trois réserves optionnelles
évitent une impasse de munitions. Les bras et mains FPS authored accompagnent le
pistolet, avec balancement, recul, recharge, flash de bouche et impact. Le
hitbox ennemi a été remonté après qu'un rayon centré a réellement frôlé sa
capsule : le test de tir centré couvre la régression.

Effets sonores et ambiance ont été générés localement par recette déterministe.
Quatre messages radio français utilisent Piper/siwis avec attribution et
empreintes conservées. La lecture réelle de l'ambiance, de la voix et d'un effet
a avancé sur le backend audio. Le menu tient à 1152 × 648 et expose volumes,
sensibilité, champ de vision, secousses et plein écran. Paramètres, meilleur
temps d'évacuation et record de neutralisations sont persistants.

Cinq planches multivues GAC sont courantes et ont été inspectées : mains FPS,
zombie, clinique, console radio et quartier. La première tentative a révélé deux
préconditions tardives, collection Blender nommée et Pillow ; les scripts de
construction créent maintenant leur collection explicite et Pillow est verrouillé
comme dépendance de développement. Proposition GAC-I10 enregistrée pour un
préflight plus explicite.

Après reconstruction de tous les GLB, les contrats gameplay et présentation,
les animations, les assets de mission et la lecture audio passent. Le parcours
graphique par entrées normales gagne en 135,88 s, santé 82, 34 neutralisations et
108 tirs. C'est une preuve agent reproductible, pas un playtest humain ni une
acceptation artistique du créateur. M2 et M3 sont clos à ce niveau de preuve ;
M4 doit maintenant mesurer les performances et corriger les défauts observables.

## 13 h 25 — performance représentative et préparation Windows

Une sonde graphique sans V-Sync a animé 35 infectés pendant 900 images après
180 images de chauffe, en 1152 × 648 sur l'OpenGL de la RTX 4070 SUPER. Résultat :
moyenne 4,28 ms, médiane 3,81 ms, p95 5,91 ms, p99 6,47 ms, 1 % bas calculé à
154,6 FPS et aucune image au-dessus de 16,67 ms. La scène observée comptait
3 160 appels de dessin et 1 034 540 primitives. Cette marge ne justifie pas une
optimisation spéculative ; les autres GPU ne sont pas certifiés.

Le menu de résultat a aussi été capturé dans sa fenêtre cible. Un test accéléré
avait écrit un meilleur temps impossible à zéro seconde : la persistance refuse
désormais tout temps sous les 90 secondes incompressibles de la défense et
nettoie les anciennes valeurs invalides. L'écran complet, avec record, tient dans
940 × 560 au sein de la fenêtre 1152 × 648.

Le preset Windows x86_64, le guide joueur, les notices tierces et la recette de
paquet sont prêts. Les notices Godot seront générées depuis le binaire exact ;
Quaternius CC0 et la voix SIWIS CC BY 4.0 sont attribués. M4 est vérifié par les
probes automatisées. Le rythme et le plaisir humains restent ouverts ; M5 doit
encore produire puis tester l'exécutable réel.

## 13 h 43 — livraison Windows 1.0.0 vérifiée

Le paquet Windows x86_64 a été généré depuis le commit propre `3f501d8`. Il
contient l'exécutable, le PCK séparé, le lanceur console de vérification, les
notices exactes de Godot, le guide joueur, les attributions tierces, un manifeste
et les empreintes SHA-256. Le lancement autonome a réussi. Le ZIP mesure
42 476 735 octets et son SHA-256 est
`86403772664f46fbd057c0422091b906423acee44ad956203a0b987d85b093c7`.

Le parcours complet exécuté contre ce build exporté a réussi en 135,88 s : trois
composants, radio, défense, extraction, 82 points de vie, 34 neutralisations et
108 tirs. La capture montre l'écran final « Évacuation réussie ». Cette preuve
est une traversée par entrées pilotée par l'agent et ne remplace pas un playtest
humain. La sonde de performance reste limitée à la RTX 4070 SUPER mesurée.

L'exécutable n'a pas de signature Authenticode, faute de certificat de signature.
Le PCK reste séparé afin de permettre une signature ultérieure sans reconstruire
un exécutable à ressources embarquées. Les sommes et la révision source rendent
le livrable local vérifiable. M5 et M6 sont clos au niveau technique défini ; le
plaisir, le mixage humain et l'acceptation artistique du créateur restent ouverts.

La mesure GAC a aussi révélé que `metrics run` crée son événement avant d'appeler
la commande observée. L'empaqueteur accepte donc uniquement ces nouveaux
événements append-only comme bruit de mesure et continue de refuser toute vraie
modification produit. La proposition GAC-I11 formalise un contrat plus propre.
