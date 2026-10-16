# Vue FPS — bras et mains

Asset original du projet, authored dans Blender 5.2.2 par
`scripts/build_viewmodel.py`. Le GLB est utilisé sous la caméra première personne
avec le pistolet Quaternius adapté séparément. Repère Godot, mètres, regard vers
-Z. Les manches reprennent l'accent chaud de la survivante défini par DS-V2.

Les volumes volontairement simples protègent le centre de visée à 85 degrés de
champ de vision. Doigts, paumes, poignets, manches et coutures d'encrage restent
des objets nommés et éditables. Le mouvement de marche, le recul et la recharge
sont appliqués au groupe par le contrôleur Godot.

Statut : candidat intégré. Import, présence sous la caméra et réactions tir,
recharge et mouvement sont testés. La capture `fps-feedback-final.png` a été
inspectée localement : prise lisible, réticule dégagé et réponse de tir visible.
`fps_arms.views.png` est une feuille multivue GAC courante et inspectée. La
validation artistique humaine reste ouverte.
