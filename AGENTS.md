# Studio du projet zombie

Lire `docs/STUDIO.md` avant de modifier la chaîne de production.
Godot Asset Cloud dirige les outils ; appliquer le skill utilisateur
`studio-3d-local` pour les adaptateurs 3D de cette machine.

- Le projet Godot est `game/project.godot`. La scène initiale est une calibration,
  sans gameplay ni direction artistique approuvée.
- Utiliser `.venv`, `uv.lock` et `scripts/studio.py` pour les vérifications.
- Le MCP de ce jeu est `gac-local-studio-zombie`. Le MCP `blender` est partagé.
  `gac-local-studio-aube` appartient à un autre projet.
- Les chemins machine restent dans les caches GAC ou `machine.local.json` ignoré.
- Réutiliser les assets licenciés avant de générer. Une seule génération GPU à
  la fois ; ne pas retirer un verrou sans vérifier le processus propriétaire.
- Préserver les sources éditables et exporter un GLB distinct. Valider dans Godot.
- Aucune dépense cloud sans autorisation explicite pour l'opération.
- Distinguer démarrage technique, rendu, lecture audio, animation, qualité
  artistique et jouabilité. Un test headless ne prouve pas ces dernières qualités.
- Vérifier avec `ruff check .`, `ruff format --check .`, les tests Python et
  `scripts/studio.py smoke`. Pour une modification des exports, lancer `check`.
