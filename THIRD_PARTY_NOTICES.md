# Dernier Signal — composants tiers

Les sources, modèles et sons originaux de Dernier Signal restent sous le contrôle
de leur auteur. Ce fichier recense les composants tiers distribués avec le jeu.

## Godot Engine

Le jeu utilise Godot Engine 4.7.2, distribué sous licence MIT. Le paquet Windows
contient `GODOT_COPYRIGHT.txt`, généré depuis le binaire exact par
`Engine.get_license_text()`, `Engine.get_copyright_info()` et
`Engine.get_license_info()` afin de conserver les notices de Godot et de ses
bibliothèques tierces. Site et licence : https://godotengine.org/license

## Quaternius — Zombie Apocalypse Kit

Personnage infecté, animations, pistolet, véhicules et accessoires adaptés depuis
le **Zombie Apocalypse Kit** de Quaternius, licence CC0 1.0.

- Source : https://quaternius.com/packs/zombieapocalypsekit.html
- Provenance et empreintes : `art/vendor/quaternius-zombie/provenance.json`
- Licence fournie : `art/vendor/quaternius-zombie/License.txt`

## Piper — voix française SIWIS

Les quatre messages radio ont été synthétisés avec le modèle Piper
`fr_FR-siwis-medium`. Son model card indique que le jeu de données SIWIS est sous
CC BY 4.0.

Attribution du jeu de données : Junichi Yamagishi, Pierre-Edouard Honnet,
Philip Garner et Alexandros Lazaridis (2017), *The SIWIS French Speech Synthesis
Database, 2016*, University of Edinburgh, Centre for Speech Technology Research,
https://doi.org/10.7488/ds/1705.

- Model card : https://huggingface.co/rhasspy/piper-voices/blob/main/fr/fr_FR/siwis/medium/MODEL_CARD
- Licence CC BY 4.0 : https://creativecommons.org/licenses/by/4.0/
- Modèle : SHA-256 `641d1ab097da2b81128c076810edb052b385decc8be3381814802a64a73baf99`

Les voix sont intégrées sous forme de fichiers audio générés. Les poids du modèle
Piper ne sont pas distribués avec le jeu.
