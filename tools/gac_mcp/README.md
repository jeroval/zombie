# MCP local zombie

Adaptation du scaffold Godot Asset Cloud 3.38.0. Depuis la racine :

```powershell
uv sync --locked
.\.venv\Scripts\python.exe tools/gac_mcp/server.py
```

L'environnement et le verrou de dépendances sont ceux du dépôt. Les outils
déclarés dans `policy.json` effectuent des appels bornés avec délais.
Les fichiers audio restent dans le dépôt et les sorties existantes sont refusées.
Aucun outil shell, téléchargement ou génération cloud n'est exposé.
Les erreurs sont propagées par le SDK MCP.

Blender interactif utilise le MCP global `blender`. Le serveur
`gac-local-studio-aube` appartient à un autre projet.
