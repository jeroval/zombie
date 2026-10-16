# Architecture initiale — DS-V1

Godot 4.7.2, GDScript, jeu hors ligne. Conserver le studio Python pour les builds,
assets et vérifications ; l'exécutable final ne dépend pas de ces outils.

## Responsabilités prévues

- `Game` : état de partie, phases, collecte garantie et conditions victoire/défaite.
- `Player` : déplacement, visée, combat, endurance, santé et inventaire court.
- `Enemy` : perception, chemin, attaque et réactions ; variantes configurées par données.
- `World` : carte, obstacles, placements et points d'apparition ; aucun état global caché.
- `HUD` : menus, objectifs, retours, pause et paramètres ; commandes transmises au jeu.
- `Audio` : bus et voix bornées ; volumes sauvegardés via ConfigFile.

Les scènes et scripts restent locaux à ce jeu. Extraire uniquement les
responsabilités qui sont déjà distinctes ; ne pas construire un framework général.
Collisions séparées : monde, joueur, ennemis et interactions. Les projectiles
doivent respecter les murs. Navigation adaptée à la carte réellement construite.

## Données et compatibilité

Paramètres/best score sous `user://`, schéma versionné, valeurs bornées lors du
chargement. Un fichier absent ou corrompu revient aux valeurs par défaut avec
diagnostic ; il ne doit pas empêcher de démarrer. Pas de secret ni réseau runtime.

## Vérification

Tests GDScript des transitions, ressources et redémarrage ; scénario déterministe
pour victoire/défaite et interactions. Tests graphiques séparés pour entrée,
visée, collisions, caméra, animations, effets et menus. Parcours agent complet
via commandes d'entrée, distinct des tests qui appellent directement une règle.
Mesure du framerate et du coût avec une population représentative.

L'export final est testé hors éditeur et accompagné d'une empreinte et du commit
source. Les fixtures de studio restent exclues de l'export. Les révisions de
scripts/assets modifiées invalident les preuves qui en dépendent.
