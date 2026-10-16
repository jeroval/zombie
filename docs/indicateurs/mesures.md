<!-- gac-development-metrics:v1 -->
# Indicateurs du développement

Généré : 2026-10-16T11:18:56.270620+00:00. Historique local ; aucune certification du jeu.

## KPI

| Indicateur | Valeur |
|---|---|
| Episodes enregistrés | 5 |
| Tokens entrée / sortie observés | Indisponible / Indisponible |
| Entrée en cache (sous-ensemble de l’entrée) | Indisponible |
| Couverture tokens | 0 tours importés, 0/5 épisodes avec compteurs ; couverture totale inconnue |
| Durées cumulées des épisodes clos | 3 299.72 s |
| Durées cumulées des commandes mesurées | 425.97 s |
| Reprises / commandes classées | 0 % ; couverture de classement 100 % |
| Acceptation déclarée au premier verdict décisif | Indisponible sur 0 contrats/révisions |
| Problèmes ouverts / introduits / préexistants / origine inconnue | 0 / 1 / 0 / 0 |
| Solutions déclarées vérifiées / tentatives | 100 % sur 1 |

Les durées parallèles se recouvrent : ne pas les additionner pour annoncer un temps humain actif. Les temps de réflexion, attente et travail non instrumenté restent inconnus. Aucune conversion automatique en euros.

## Résultats et règles

Verdicts déclarés : {}. Critères déclarés : {}.

PASS technique, installation, génération et acceptation artistique/runtime restent distincts. Les critères sont ceux du contrat enregistré, pas toutes les règles possibles du plugin. Les revues sont des déclarations historiques ; leur intégrité ne prouve pas leur contenu.

| Contrat / révision | Verdict enregistré | Fichier source actuel | Preuve |
|---|---|---|---|

## Où passent le temps et les tokens ?

| Etape | Secondes de commandes cumulées | Commandes / échecs | Tokens entrée / sortie observés |
|---|---|---|---|
| test | 424.3 | 6 / 0 | Indisponible / Indisponible |
| review | 1.67 | 1 / 1 | Indisponible / Indisponible |

### Cinq commandes les plus longues

- animated-fps-input-traversal : 149.01 s ; PASS ; épisode `ds-20261016-art-anchor`.
- final-fps-input-traversal : 136.97 s ; PASS ; épisode `ds-20261016-feedback`.
- district-input-traversal : 136.55 s ; PASS ; épisode `ds-20261016-district`.
- viewmodel-multiview-sheet : 1.67 s ; FAIL ; épisode `ds-20261016-feedback`.
- district-contract : 0.81 s ; PASS ; épisode `ds-20261016-district`.

### Cinq épisodes avec le plus de tokens observés


## Historique récent

| Episode / objectif | Catégorie | Etat | Secondes écoulées | Bilan / suite |
|---|---|---|---|---|
| [.godot-studio/metrics/episodes/ds-20261016-feedback/episode.json](../../.godot-studio/metrics/episodes/ds-20261016-feedback/episode.json) — Finish FPS viewmodel combat feedback and original audio presentation | integration | COMPLETED | 1 997.96 | FPS streetscape, mission props, viewmodel, combat feedback, original audio, French radio voice, persistent options and results integrated; final graphical input traversal wins in 135.88 seconds / Measure representative graphical performance, tune observable hotspots, then build and validate the standalone Windows export |
| [.godot-studio/metrics/episodes/ds-20261016-district/episode.json](../../.godot-studio/metrics/episodes/ds-20261016-district/episode.json) — Integrate three authored FPS interiors and validate reachable objectives | assets | COMPLETED | 225.33 | Three authored FPS interiors integrated; doors and objectives reachable; graphical agent wins in 135.8 seconds / Finish district surfaces and mission props, FPS hands, feedback and options |
| [.godot-studio/metrics/episodes/ds-20261016-art-anchor/episode.json](../../.godot-studio/metrics/episodes/ds-20261016-art-anchor/episode.json) — Adapt licensed zombie and pistol assets and verify FPS combat | assets | COMPLETED | 552.21 | Animated zombie and pistol integrated as experimental candidates; GLB skin/UV channels and four poses verified; graphical input traversal wins / Integrate authored district interiors, FPS hands and final art reviews |
| [.godot-studio/metrics/episodes/ds-20261016-fps-core/episode.json](../../.godot-studio/metrics/episodes/ds-20261016-fps-core/episode.json) — Implement the complete first-person mission loop | code | COMPLETED | 466.34 | FPS blockout and mission-rule tests implemented; graphical camera verified; full input traversal and final assets remain / Validate combat and complete a normal-input mission; adapt licensed assets |
| [.godot-studio/metrics/episodes/ds-20261016-design/episode.json](../../.godot-studio/metrics/episodes/ds-20261016-design/episode.json) — Définir le jeu complet, les jalons et les mesures avant production | design | COMPLETED | 57.87 | Contrat DS-V1, roadmap, conception, suivi et catalogue métrique rédigés avant production / Implémenter et vérifier une partie complète jouable |

0 épisodes supplémentaires conservés sur disque.

## Difficultés, causes et solutions

### asset-sheet-preflight-01 — La première planche multivue a échoué successivement sur une collection absente puis sur Pillow absent.

- Etat : RESOLVED. Portée : MILESTONE. Responsable : studio-decision-kernel. Age/durée : 0 s.
- Cause : Les scripts du projet n'exposaient pas de collection nommée et la dépendance d'assemblage d'image n'était pas déclarée. (CONFIRMED). Attribution : PROJECT ; origine : INTRODUCED.
- Preuves : [scripts/build\_viewmodel.py](../../scripts/build_viewmodel.py), [pyproject.toml](../../pyproject.toml), [art/production/viewmodel/fps\_arms.views.json](../../art/production/viewmodel/fps_arms.views.json).
- Suite : Conserver les collections explicites et la dépendance verrouillée lors des reconstructions..
- Solution declare-sheet-prerequisites : Créer une collection nommée dans chaque source et verrouiller Pillow dans les dépendances de développement. — VERIFIED, preuve Cinq planches multivues rendues et contrôlées courantes ; fichiers \['UNCHANGED\_FILE', 'UNCHANGED\_FILE', 'UNCHANGED\_FILE', 'UNCHANGED\_FILE', 'UNCHANGED\_FILE'\] ; [art/production/viewmodel/fps\_arms.views.json](../../art/production/viewmodel/fps_arms.views.json), [art/production/quaternius/zombie\_basic.views.json](../../art/production/quaternius/zombie_basic.views.json), [art/production/district/clinic.views.json](../../art/production/district/clinic.views.json), [art/production/mission-props/radio\_console.views.json](../../art/production/mission-props/radio_console.views.json), [art/production/streetscape/streetscape.views.json](../../art/production/streetscape/streetscape.views.json).

Récurrences (occurrences distinctes, mises à jour exclues) : {}.
0 autres problèmes conservés sur disque.

## Améliorations proposées

### P2 — asset-sheet-preflight (PLUGIN_CANDIDATE)

- Problème : Deux préconditions de rendu de planche ont été découvertes l'une après l'autre pendant l'exécution.. Episodes/preuves : ds-20261016-feedback / \['asset-sheet-preflight-01'\] / \['docs/indicateurs/incident-planche-assets.json'\].
- Cible : Route GAC asset-sheet render et sa documentation de préparation.. Proposition : Vérifier avant Blender la collection demandée, la disponibilité de Pillow et le caractère disponible de la sortie, puis retourner toutes les erreurs ciblées ensemble..
- Gain attendu, à vérifier : Hypothèse : moins de relances de rendu sans réduire la qualité ou les contrôles requis..
- Vérification avant/après : Comparer la même source sans collection, sans Pillow puis conforme ; mesurer le nombre de lancements Blender et vérifier que la planche conforme reste identique..

0 autres propositions conservées sur disque.

PLUGIN_CANDIDATE est une proposition : aucune modification/publication automatique du plugin.

## Comparaisons de travaux similaires

| Groupe / catégorie / plugin / modèle / cache | n | Médiane (s) | P90 (s, n >= 10) |
|---|---|---|---|

Statistiques descriptives. Un groupe doit représenter une charge comparable. Les changements de modèle, cache, machine, périmètre, qualité ou validation empêchent une attribution causale automatique. Les essais isolés ne prouvent pas un gain.

Les données détaillées restent dans `.godot-studio/metrics/`. Charger uniquement le résumé utile et les références, jamais tout l’historique dans le contexte Codex.
