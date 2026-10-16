# Dernier Signal — roadmap de livraison

Révision 2 — 16 octobre 2026, direction FPS imposée par le créateur. Échéance : 18 h 00.
Responsable : Codex. Contrat produit : [conception](conception/01-concept.md).
État vivant : [suivi](suivi/ETAT.md). Mesures : [indicateurs](indicateurs/README.md).

## Produit à livrer

Un jeu Windows autonome de survie/action FPS 3D à la première personne : explorer un quartier
envahi, récupérer trois composants, réparer une radio, survivre à l'arrivée des
secours, puis rejoindre l'extraction. Une partie complète visée de 8 à 12 minutes,
avec un début guidé, une progression, un climax, une victoire ou défaite et une
relance. Présentation en français, direction dessin encré 3D, personnages animés,
ambiance sonore, commandes affichées, pause et options persistantes.

Cette première version constitue le jeu complet défini ici. Un blockout, une
arène sans objectifs, une simple scène ou une compilation seule ne le terminent pas.

## Jalons

Les horaires sont des budgets de travail, pas des preuves d'acceptation.

| ID | Cible horaire | Capacité livrée | Preuve requise | État |
| --- | --- | --- | --- | --- |
| M0 | 12 h 20 | Conception, roadmap, suivi, indicateurs et dépôt récupérable | Documents cohérents, branche et commit | TERMINÉ |
| M1 | 13 h 15 | Partie complète jouable avec exploration, combat, composants, défense et extraction | Parcours victoire/défaite/rejouer ; tests des règles ; contrôle graphique | VÉRIFIÉ sur prototype, parcours agent |
| M2 | 14 h 30 | Quartier authored, silhouettes de survivant/infectés, animations et rendu encré cohérent | Sources/licences, exports, vues en jeu et mouvement inspectés | VÉRIFIÉ par revue agent |
| M3 | 15 h 15 | Retours de tir, dégâts, progression, sons, musique et ambiance ; HUD et menus finis | Lecture réelle, options, pause, lisibilité aux résolutions cibles | VÉRIFIÉ techniquement et graphiquement |
| M4 | 16 h 15 | Jouabilité équilibrée, parcours complets et corrections | Tests entrée/sortie, parties représentatives, performances mesurées | EN COURS |
| M5 | 17 h 15 | Exécutable Windows autonome, crédits et mode d'emploi | Export depuis révision identifiée, lancement hors éditeur, parcours sur export | À FAIRE |
| M6 | 18 h 00 | Livraison vérifiée, suivi final, bilan indicateurs et propositions plugin | Audit de tous les critères ; aucune régression bloquante connue | À FAIRE |

## Ordre et arbitrages

1. Prouver la boucle entière avec des formes provisoires, puis remplacer ses assets.
2. Donner la priorité au contrôle, aux collisions et aux objectifs compréhensibles.
3. Réutiliser un pack animé CC0 si compatible ; adapter la présentation au style encré.
4. Garder une carte maîtrisée avec trois lieux distincts et plusieurs chemins.
5. Vérifier après chaque intégration ; préserver la dernière version utilisable.
6. Commits à chaque jalon cohérent et branches par lot majeur. Aucun push/publication
   distante nécessaire à la livraison locale.

## Conditions de sortie

- Lancement Windows sans Python, Blender, plugin ou accès Internet.
- Menu → nouvelle partie → trois composants → radio → défense → extraction → victoire.
- Mort → résultat → nouvelle partie fonctionnels, sans état résiduel.
- Déplacement, visée, tir, rechargement, mêlée, sprint et interaction répondent correctement.
- Ennemis atteignent le joueur par les passages ; obstacles et murs bloquent les tirs.
- Objectif et danger lisibles ; aucune impasse de ressources ou de progression.
- Pause, volumes, aide des commandes et paramètres persistants utilisables.
- Direction encrée, animations, son et transitions intégrés ; pas de géométrie de test livrée.
- Licences/crédits, guide joueur, exécutable, version, sources et tests conservés.
- Performance graphique mesurée sur cette RTX 4070 SUPER ; les autres GPU restent non certifiés.
- Roadmap, conception, suivi, indicateurs et propositions plugin reflètent les résultats réels.

La durée de partie et le plaisir restent des objectifs de conception à éprouver.
Les observations agent, les tests automatiques et les retours humains sont distincts.
