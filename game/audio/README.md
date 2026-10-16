# Audio de Dernier Signal

Les dix sons sous `generated/` sont originaux : tir, clic vide, recharge, mêlée,
impact, blessure, collecte, radio, extraction et ambiance de 45 secondes.
Ils sont en PCM stéréo 48 kHz ; durées, pics et empreintes sont conservés dans
`generated/manifest.json`.

Les quatre messages radio français sous `voice/` ont été synthétisés localement
avec Piper 1.8.0, voix `siwis`, locuteur 0, length scale 1,08. Le catalogue voix
du studio lie le modèle à son hash et au jeu de données français SIWIS CC BY 4.0.
Chaque message est doublé par un texte à l'écran ; aucune information nécessaire
n'est transmise seulement par le son.

Les bus Master, Music, SFX et Voice sont séparés. Le menu expose leur volume ;
la musique, les effets répétés et la voix ont chacun un propriétaire borné.
