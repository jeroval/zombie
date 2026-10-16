# Dernier Signal — conception initiale

Version de vision : DS-V2, 16 octobre 2026. Nom de dépôt conservé : `zombie`.
Le créateur délègue les choix de jeu ; ces décisions sont celles du responsable
du projet, prises avant l'implémentation et révisables avec trace explicite.

## Promesse

Se frayer un chemin dans un quartier abandonné, faire du bruit seulement quand
cela en vaut le prix, puis défendre le dernier appel vers l'extérieur.
Un jeu d'action/survie solo nerveux et lisible, avec de courts moments de répit.

Le personnage est une survivante qui capte un message d'évacuation. La radio
du refuge ne peut pas répondre : il manque une batterie, du carburant et un
module d'antenne. Les trois lieux du quartier donnent ces composants. Lorsque
la radio émet, les infectés convergent ; il faut tenir puis gagner le point
d'évacuation annoncé. La fin répond explicitement à l'objectif initial.

## Boucles

- Instant : se déplacer et viser → esquiver/attaquer → lire l'impact → se repositionner.
- Courte : repérer une ressource/objectif → choisir un chemin → gérer les infectés
  et le bruit → récupérer → décider de poursuivre ou se soigner.
- Partie : refuge → trois lieux dans l'ordre choisi → retour radio → défense
  finale → extraction → bilan et relance.
- Rejouabilité : difficulté et routes alternatives, meilleure gestion des tirs,
  de la santé et du temps. Aucun grind ni progression de compte nécessaire.

## Carte et missions

Quartier compact avec axes lisibles, obstacles, raccourcis et trois signatures :

| Lieu | Composant | Situation proposée | Lecture visuelle |
| --- | --- | --- | --- |
| Clinique | Batterie de secours | Passage étroit, réserve de soins, risque au retour | Croix médicale, façade claire, accents verts |
| Garage | Carburant | Détour entre véhicules, collecte exposée | Enseigne orange, bidons et carrosseries |
| Poste télécom | Module d'antenne | Groupe plus rapide, approche par deux accès | Antenne, câbles, enseigne cyan |
| Refuge / radio | Installation des composants | Préparer le climax et activer volontairement l'appel | Halo chaud, radio, pancarte de rendez-vous |
| Zone de secours | Extraction finale | Dernier trajet sous pression | Balise, zone indiquée et arrivée des secours |

Les objectifs sont garantis et ne peuvent être détruits ou consommés autrement.
Le jeu ne doit pas exiger de nettoyer tous les ennemis pour progresser. Les
ressources optionnelles récompensent un détour ; leur manque ne bloque pas
définitivement la partie grâce à la mêlée et à la mobilité.

## Règles de départ à équilibrer

Santé 100, endurance pour le sprint, arme de poing avec chargeur de 12 cartouches,
réserve limitée et rechargement interrompant le tir. Mêlée de secours, portée
courte et temps de récupération. Soins consommables et caisses de munitions.
Les nombres sont des réglages initiaux, pas des résultats de playtest.

Deux comportements d'infectés minimum : rôdeur lent et poursuivant rapide ;
un lourd peut enrichir la finale si sa lisibilité et ses animations passent les
tests. Les infectés réagissent à la proximité/vision et aux tirs. Une cible
entendue doit mener à une investigation ; la perte du joueur doit permettre
de rompre la poursuite. Les obstacles offrent de vraies décisions de trajet.

La défense finale dure environ 75–90 secondes. Le joueur l'engage en réparant
la radio une fois prêt. Les vagues sont bornées pour conserver lisibilité et
performance. Le dernier objectif est de rejoindre la zone d'extraction en vie.

## Présentation et contrôles

Direction imposée par le créateur : FPS 3D. Caméra à hauteur des yeux,
regard souris capturé en partie, arme visible et réticule central.
Clavier ZQSD et WASD, flèches comme alternative ; clic gauche tir, clic droit
visée précise, V mêlée, R recharge, E interaction, Maj sprint, F soin, Échap pause. Afficher les
commandes contextuelles. Le remappage exhaustif et la manette ne sont pas
promis dans cette version ; privilégier un clavier français réellement utilisable.

HUD : santé, endurance, chargeur/réserve, soins, phase et progression de mission.
Marqueurs distincts par forme/texte, pas uniquement par couleur. Carte ou repères
directionnels pour éviter les recherches à l'aveugle. Aide consultable en pause.
Options volumes, plein écran, sensibilité souris, champ de vision et secousses
caméra ; persistance locale.

## Livrable et limites définies avant production

Jeu Windows autonome, français, clavier/souris, une carte complète, une boucle
de partie finie et rejouable. Sources Godot et sources d'assets conservées.
Pas de multijoueur, monde ouvert infini, construction de base, économie persistante,
campagne de plusieurs heures ou boutique. Ces systèmes ne font pas partie de
la promesse initiale de ce jeu. Une partie peut être recommencée ; une sauvegarde
de campagne n'est pas requise, les paramètres et meilleurs résultats le sont.

## Acceptation produit

Les conditions de sortie de la [roadmap](../ROADMAP.md) sont le contrat DS-V2.
Le suivi distingue prévu, implémenté, vérifié techniquement et observé en jeu.
Une réduction de ce contrat doit être explicitée ; aucun test vert ne redéfinit
la portée. La version finale doit offrir un vrai début, un parcours et une fin.
