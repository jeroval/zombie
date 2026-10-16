# Dernier Signal

FPS 3D de survie en français. Explorez un quartier contaminé, récupérez trois
composants, réparez la radio, survivez à l'assaut puis rejoignez l'extraction.

Le jeu se joue à la première personne avec souris et clavier. Le guide complet,
les commandes et les options sont dans [le guide joueur](docs/PLAYER_GUIDE.md).

Pour lancer le projet depuis l'éditeur :

```powershell
uv sync --locked
uv run --locked python scripts/studio.py doctor
uv run --locked python scripts/studio.py open
```

Créer le paquet Windows après avoir validé et commité les sources :

```powershell
uv run --locked python scripts/package_windows.py
```

Commandes, MCP, routes 3D et validations : [guide du studio](docs/STUDIO.md).
Roadmap et limites de preuve : [roadmap](docs/ROADMAP.md).

