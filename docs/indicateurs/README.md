# Indicateurs et amélioration de Godot Asset Cloud

Sources : plugin installé **3.38.0**, `scripts/studio_metrics.py`,
`skills/development-observability/references/development-metrics.md` et
`player-quality-measures.md`, plus critères art/production applicables.
Catalogue exact : [catalogue-plugin.json](catalogue-plugin.json).
Rapport calculé : [mesures.md](mesures.md). Propositions : [ameliorations-plugin.md](ameliorations-plugin.md).

## Inventaire des KPI de développement du plugin

| Indicateur | Définition, dénominateur et état initial |
| --- | --- |
| Épisodes et état | Nombre total, ouverts/clos ; un épisode fini ne signifie pas jeu fini |
| Durée d'épisode | Horodatage UTC fin moins début ; inclut attentes, activité non instrumentée inconnue |
| Durée de commande | Temps monotone d'une commande réellement exécutée ; parallélisme non additionnable au temps mural |
| Coût par phase | Secondes mesurées, commandes, échecs et tokens importés par phase ; couverture explicite |
| Tokens entrée/sortie | Compteurs par tour `codex exec` importé ; **indisponibles ici**, jamais estimés |
| Tokens d'entrée en cache | Sous-ensemble de l'entrée, non ajouté une seconde fois ; inconnu si absent |
| Couverture tokens | Tours importés et épisodes avec compteurs ; couverture totale inconnue sans recensement complet |
| Reprise | Secondes FAILURE_DEMAND / secondes de commandes classées ; UNKNOWN exclu |
| Couverture de classement | Secondes classées / toutes les secondes mesurées |
| Premier passage | Premiers verdicts SATISFIED / contrats-révisions avec premier verdict décisif ; PENDING exclu |
| Critères et verdicts | Comptage des déclarations du contrat à leur révision ; pas un score de qualité universel |
| Problèmes | Ouverts, âge depuis enregistrement, origine introduite/préexistante/inconnue |
| Récurrences | Occurrences distinctes par empreinte ; mises à jour d'un incident non recomptées |
| Solutions | VERIFIED / tentatives TRIED, VERIFIED, REJECTED ; PLANNED exclu |
| Fraîcheur | Preuves/fichiers inchangés, obsolètes ou absents ; succès historique distinct |
| Étapes lentes | Cinq durées de commande les plus élevées |
| Épisodes coûteux | Cinq plus gros totaux de tokens observés, si disponibles |
| Cohortes/tendances | Groupe comparable, catégorie, plugin, modèle, cache ; n, médiane, P90 seulement si n ≥ 10 |
| Couverture du rapport | Nombre de lignes/épisodes/incidents/propositions omis par limite ; historique conservé |

Phases prévues : design, narrative, setup, research, code, assets, audio,
integration, test, review, recovery, documentation, other.
Classes de travail : VALUE, FAILURE_DEMAND, RISK_REDUCTION, MAINTENANCE, UNKNOWN.

## Mesures de qualité joueur prévues par le plugin

1. Actions pertinentes sans aide / premières tentatives ; échecs et abandons conservés.
2. Délai de début à action ; montrer aussi les tentatives sans résultat.
3. Réutilisation d'une règle / tentatives de transfert, contexte et aide renseignés.
4. Reprise après pause, chargement ou mort, mesurée séparément par condition.
5. Niveau et moment de l'aide, intervention et récupération ; pas de diagnostic sur le seul temps d'arrêt.
6. Erreurs d'entrée, focus ou retour bloquantes par tâche, appareil et build.
7. Délai problème→décision, âge des incidents et cycles sans progrès ni incertitude retirée.

Aucune observation humaine n'est encore disponible. Les scripts et agents sont
identifiés comme tels ; ils ne simulent pas des débutants humains ni leur plaisir.

## Mesures de production des assets

La comparaison des routes d'assets suit aussi les dimensions du plugin :
acquisition/génération, crédits, calcul local, correction Blender, UV/matériaux,
rig/skin, retargeting, intégration Godot, QA, risque de reprise et maintenance.
Conserver révision provider/modèle, disponibilité, estimation/confiance,
coût/temps réellement observés, gates échoués, nombre de corrections et preuve
runtime. Dépense monétaire, temps de production et jugement artistique restent
séparés. Les poids illustratifs par classe ne constituent pas des mesures.

## Mesures propres à ce jeu

Durée de partie ; composants obtenus ; cause de mort ; tirs/touches ; ressources
consommées ; délai pour comprendre le premier objectif ; victoire/défaite/relance ;
ennemis actifs et coincés ; temps de frame CPU/GPU si disponible, FPS et pics ;
temps de chargement ; taille de build. Préciser résolution, hardware, scénario,
révision et effectif. Les seuils viennent du contrat produit, pas d'un score synthétique.

## Cadence et conservation

Un épisode par résultat significatif, mesure des commandes coûteuses et des
réparations, bilan aux jalons. Les événements compacts sont versionnés à la
demande de suivi du créateur ; pas de transcription, secrets ou caches lourds.
Le rapport canonique GAC est généré sous `docs/developpement/indicateurs.md`,
avec une copie dédiée ici. Les autres documents expliquent et interprètent sans
écraser les mesures. Toute amélioration du plugin reste une proposition jusqu'à
une demande explicite de modification du plugin.
