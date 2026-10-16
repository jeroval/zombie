# Studio local zombie

État vérifié le 16 octobre 2026. Godot Asset Cloud 3.38.0 orchestre la production ;
le skill utilisateur `studio-3d-local` décrit les adaptateurs installés.
Le projet Godot est `game/project.godot`. Il contient une mission FPS complète :
exploration de trois lieux, combat, réparation de radio, défense et extraction.

## Démarrer

Depuis la racine du dépôt :

```powershell
uv sync --locked
uv run --locked python scripts/studio.py doctor
uv run --locked python scripts/studio.py smoke
uv run --locked python scripts/studio.py check
uv run --locked python scripts/verify_mcp.py
uv run --locked python scripts/studio.py open
```

Les mêmes opérations sont accessibles dans les tâches VS Code. `.python-version`
sélectionne Python 3.11 ; `.venv` est propre au dépôt. `uv.lock` verrouille les
dépendances. Le workflow GitHub exécute lint, formatage et tests Python ; il
n'installe pas le studio graphique ni les modèles sur les runners.

## Capacités vérifiées

| Outil ou route | État et preuve de cette session |
| --- | --- |
| Godot 4.7.2 | Résolution canonique GAC, import et lancement headless réussis ; rendu OpenGL NVIDIA capturé et inspecté |
| Blender 5.2.2 LTS | Export `.blend` + GLB distinct ; animation du GLB effectivement lue dans Godot |
| MCP Blender | Extension 1.8, protocole 13 à jour ; état et scène interrogés ; écoute locale 9876 ; télémétrie désactivée |
| Poly Haven via Blender | Activé ; recherche de texture réussie, aucun téléchargement ni asset sélectionné |
| FFmpeg / ffprobe 9.0.1 | Conversion WAV → Ogg, durée sondée, import et lecture technique Godot réussis |
| Audacity 4.0.1 / LMMS 1.2.2 | Commandes de version réussies ; édition et composition interactives non testées |
| Piper 1.8.0 | Dépendance du dépôt ; voix française `siwis` générée hors ligne ; modèles vérifiés par SHA-256 |
| MPFB 2.0.18 | Doctor profond GAC : création/export morph-safe réussis |
| TripoSR CUDA | Doctor profond : imports et extraction d'une surface non vide sur CUDA ; inférence complète non relancée |
| Infinigen 2.0.0a3 | Doctor profond : catalogue de générateurs chargé ; génération non relancée |
| Stable Fast 3D | Imports des extensions, calcul CUDA et empreintes des modèles vérifiés ; génération complète non relancée |
| UniRig | Imports, FlashAttention effectivement exécuté sur CUDA et empreintes des modèles vérifiés ; rig complet non relancé |
| GPU | RTX 4070 SUPER, 12 Go ; environ 10 Go libres au contrôle initial, valeur à revérifier avant un travail lourd |
| Git / Git LFS / VS Code / Codex | Commandes de version réussies ; `main` synchronisée avec `origin` ; release Windows `v1.0.0` publiée |
| MCP zombie | Six outils listés, appels réels Blender/Godot et rejet d'un chemin hors dépôt testés en stdio |
| MCP Tripo | Solde interrogé : 0 crédit, génération cloud indisponible |

Les générations complètes de SF3D, UniRig et des autres fournisseurs disposent
de preuves historiques dans le rapport machine du skill. Ces preuves ne sont
pas une nouvelle validation d'inférence dans ce projet, ni une approbation
artistique de futurs assets.

## Connexions MCP

`gac-local-studio-zombie` est enregistré dans Codex avec le Python de ce dépôt et
`tools/gac_mcp/server.py`. Il expose :

- `studio_capabilities` : versions et diagnostic ;
- `godot_validate_smoke` : import et lancement de ce jeu ;
- `blender_version` : vérification de l'exécutable ;
- `ffmpeg_probe` : analyse d'un fichier audio du dépôt ;
- `audio_convert` : WAV/Ogg, sortie nouvelle, fréquence contrôlée ;
- `voice_generate` : voix française hors ligne, fichier WAV nouveau.

Le serveur n'expose ni shell arbitraire, ni téléchargement, ni génération cloud.
Les entrées audio utilisent des formats bornés et le protocole fichier de FFmpeg.
Les chemins résolus doivent rester dans le dépôt. Les erreurs sont visibles et
les processus ont des délais. Les politiques sont dans `tools/gac_mcp/policy.json`.

Le MCP global `blender` pilote la scène Blender interactive. Pour le démarrer
si Blender est fermé :

```powershell
uv run --locked python scripts/studio.py blender
```

Cette commande lance Blender masqué sur Windows, active l'extension déjà
installée et Poly Haven dans cette session, sans sauvegarder les préférences.
Si Blender est déjà ouvert, utiliser son bouton de connexion MCP ; ne pas
lancer une seconde instance sur le même port. Un redémarrage de la session
Codex peut être nécessaire pour voir le nouveau MCP zombie dans ses outils.
Le test stdio direct est indépendant de cette exposition dans le chat.

`gac-local-studio-aube` reste enregistré pour **The Roads of the Aube** : ne pas
l'utiliser pour les opérations de ce jeu. `tripo3d` reste partagé et séparé du
générateur Premium optionnel du MCP Blender.

## Production locale 3D

Le fichier portable `.godot-studio/toolchain/local3d.json` applique la politique
gratuite locale, sans repli cloud et avec une seule génération lourde à la fois.
Les installations et poids restent dans le cache machine GAC.

Pour les commandes natives GAC :

```powershell
uv run --locked python scripts/studio.py gac local3d doctor --project . --provider mpfb --deep
uv run --locked python scripts/studio.py gac local3d doctor --project . --provider triposr --deep
uv run --locked python scripts/studio.py gac local3d doctor --project . --provider infinigen --deep
```

Une recette doit être propre à l'asset demandé, avec ses droits et ses sources.
Exemple d'invocation après rédaction de cette recette :

```powershell
uv run --locked python scripts/studio.py gac local3d run --project . --provider mpfb --recipe art/personnage/recipe.json --output art/personnage/candidate-01
```

Pour SF3D et UniRig, les adaptateurs du skill sont distincts de `local3d` :

```powershell
$adapters = Join-Path $env:USERPROFILE 'Documents/Codex/tools/studio-3d'
& "$adapters/sf3d.ps1" --image 'C:/chemin/reference.png' --output 'C:/chemin/asset-v01'
& "$adapters/unirig.ps1" --mesh 'C:/chemin/non-skinne.glb' --output 'C:/chemin/rig-v01'
```

Utiliser des chemins dans ce projet et des répertoires de sortie nouveaux.
SF3D accepte une référence image ; le détourage utilise U2Net déjà en cache.
UniRig simplifie les gros maillages et normalise leur taille ; son pont FBX ne
préserve pas les UV et matériaux source. Préserver l'original et transférer le
rig sur ce maillage dans Blender lorsque l'apparence doit être conservée.
Conserver le `.blend` éditable, exporter uniquement l'asset et la scène actifs
en GLB, puis vérifier déformation, animations et apparence dans Godot.

Les planches multivues GAC demandent une collection Blender nommée et Pillow,
verrouillé dans le groupe de développement. Les scripts de construction créent
les collections `Asset`, `DistrictModule`, `MissionProp`, `Streetscape` ou
`FPSArms`. Une planche courante prouve la fraîcheur des vues ; l'inspection
visuelle et la vérification runtime restent des preuves séparées.

`art/` contient les sources et licences ; `game/assets/` reçoit les exports.
L'import implicite `.blend` de Godot est désactivé pour conserver un export
explicite, reproductible et indépendant des préférences de l'éditeur.

## Voix et audio

```powershell
uv run --locked python scripts/voice.py --text 'Exemple de voix française.' --output game/assets/audio/exemple.wav
```

Les voix `siwis` et `mls` sont décrites dans `.godot-studio/voices.json`, avec
empreintes et attribution CC-BY-4.0 à conserver selon les droits du modèle et
des données. Les poids restent hors Git. Piper est résolu dans `.venv`, sans
dépendre du Python d'un autre jeu. Les bus Godot sont Master, Music, SFX et Voice.
La lecture headless prouve la route technique, pas l'écoute ni le mixage final.

## Options non activées

| Option mentionnée par le plugin | Situation et choix |
| --- | --- |
| SoX | Absent ; optionnel, les conversions nécessaires passent par FFmpeg |
| Kokoro | Cache présent ; adaptateur non raccordé à zombie et inférence non testée ici ; Piper fournit la voix locale |
| ACE-Step / génération musicale | Non configuré ; LMMS permet la composition locale |
| Rhubarb / lip-sync | Non raccordé ; à sélectionner pour une demande de synchronisation labiale |
| Hunyuan, Hyper3D, Meshy, Lux3D | Routes conditionnelles, aucune génération ni connexion active certifiée ici |
| Sketchfab / Poly Pizza | Désactivés dans Blender ; accès et droits propres au service à configurer si retenus |
| Tripo cloud / Premium Blender | Aucun budget cloud autorisé ; Tripo est à 0 crédit, Premium n'est pas actif |
| Plugins compagnons Game Development Studio / Build 3D Game Rooms | Skills disponibles dans cette session ; exécution spécialisée à vérifier au moment de leur sélection |

Le bootstrap GAC recommande de réutiliser les installations compatibles et de
ne pas installer tous les fournisseurs. Une capacité optionnelle ne devient
pas prête parce que son skill existe. Aucun achat, compte, secret ou modèle
supplémentaire n'a été demandé pour les options de ce tableau.

## Versions, preuves et reprise

Le chemin du plugin 3.38.0 est conservé dans `machine.local.json` ignoré ; les
outils du dépôt l'utilisent pour le résolveur Godot et la CLI GAC. La session
dispose des skills 3.38.0 du plugin distant. La CLI Codex conserve aussi le
miroir historique `godot-asset-cloud@gac-local` 3.27.0 ; il n'a pas été remplacé.
Ne pas confondre ce miroir avec le chemin 3.38.0 utilisé par ce studio.

Les diagnostics machine et la capture inspectée sont sous
`.godot-studio/reports/` (ignorés). Les fixtures de roundtrip ont un identifiant
unique sous `game/studio_fixtures/`, leurs sources Blender sous
`.tools/verification/`. Elles sont conservées pour diagnostic, pas versionnées
ni destinées à une livraison du jeu. Les rapports `roundtrip.json`, `mcp.json`,
`mpfb.json`, `triposr.json`, `infinigen.json`, `sf3d.json` et `unirig.json`
décrivent la portée exacte des tests de cette session.

Pour vérifier le code :

```powershell
uv run --locked ruff check .
uv run --locked ruff format --check .
uv run --locked python -m unittest discover -s tests -v
git diff --check
```

Sur une autre machine, configurer `GAC_PLUGIN_ROOT` et les outils via les
résolveurs GAC ; revalider les providers avant production. Les modèles et MCP
globaux ne sont pas distribués avec ce dépôt. La CI est préparée ; aucune
exécution GitHub Actions n'a été déclenchée pendant cette préparation.
