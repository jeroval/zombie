# Dernier Signal

FPS 3D de survie en français. Explorez un quartier contaminé, récupérez trois
composants, réparez la radio, survivez à l'assaut puis rejoignez l'extraction.

Le jeu se joue à la première personne avec souris et clavier. Le guide complet,
les commandes et les options sont dans [le guide joueur](docs/PLAYER_GUIDE.md).

## Télécharger le jeu

La version Windows x86_64 est disponible dans la
[release Dernier Signal 1.0.0](https://github.com/jeroval/zombie/releases/tag/v1.0.0).
Télécharger puis décompresser l'archive complète afin de conserver l'exécutable
et `Dernier-Signal.pck` dans le même dossier. Cette version n'est pas signée avec
Authenticode ; l'empreinte SHA-256 est fournie avec la release.

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

