# Pistes d'amélioration du plugin

Statut initial : **propositions**, aucune modification du plugin installée.
Les exemples du bootstrap sont des observations de cette session précédente,
pas des mesures comparatives de gain. À enrichir aux jalons avec preuves réelles.

| ID | Priorité | Constat / attribution | Proposition | Vérification avant/après |
| --- | --- | --- | --- | --- |
| GAC-I01 | Haute | Le scaffold MCP utilise la clé cache ffmpeg pour résoudre ffprobe ; inspection du template 3.38.0 | Résoudre ffprobe par sa propre clé puis à côté de ffmpeg | Test avec deux exécutables distincts, lecture JSON d'un WAV réel |
| GAC-I02 | Haute | Le scaffold audio emploie `-y` et un chemin de sortie libre ; inspection source | Refuser l'écrasement, borner formats/fréquences et protocoles | Fichier existant intact, chemin sortant refusé, WAV→Ogg réussi |
| GAC-I03 | Moyenne | Session GAC 3.38.0 et miroir CLI local 3.27.0 coexistent | Diagnostic de provenance/version par surface, sans mise à jour silencieuse | Deux installations simulées ; afficher celle effectivement exécutée |
| GAC-I04 | Moyenne | Le doctor scaffold considère une inscription contenant `gac-local-studio` comme preuve générique | Vérifier le nom exact, le projet, la commande et un vrai initialize/list_tools | Deux jeux inscrits ; un serveur cassé doit rester distinct de celui qui marche |
| GAC-I05 | Moyenne | Import implicite `.blend` échoue sans préférence Blender configurée dans Godot | Scaffold sources hors runtime, GLB explicite, politique d'import documentée | Projet neuf : export/import sans dépendre des préférences de l'éditeur |
| GAC-I06 | À mesurer | Plusieurs entrées CLI/skills ont des syntaxes différentes | Aide unique de capacités et exemples exécutables testés | Exécuter les exemples documentés dans un projet temporaire |
| GAC-I07 | Haute | Erreur de décision de l'agent : caméra isométrique supposée, corrigée par le créateur en FPS ; ce n'est pas un bug démontré du plugin | Distinguer explicitement contraintes créateur, choix agent et hypothèses dans le contrat initial | Une correction caméra doit invalider contrôles, carte et critères de revue dépendants |
| GAC-I08 | Moyenne | Le parcours FPS headless ne capture pas la souris ; le même parcours graphique gagne | Déclarer les capacités d'entrée du backend dans les recettes de test | Un test d'entrée souris doit prouver la capture et le mouvement de caméra avant le scénario |
| GAC-I09 | Moyenne | Blender background sans factory-startup charge les extensions utilisateur et tente de prendre leurs ports ; observé sur ce poste | Pour les scripts autonomes, préférer factory-startup et charger explicitement les dépendances nécessaires | Export identique et aucun démarrage de serveur d'extension annexe |
| GAC-I10 | Moyenne | `asset-sheet render` a découvert successivement pendant l'exécution l'absence d'une collection Blender nommée puis de Pillow | Ajouter un préflight qui vérifie collection, dépendance d'image et sortie avant de lancer Blender | Même source sans collection puis sans Pillow : erreurs ciblées avant rendu ; source conforme : planche courante |

Gain attendu : moins de diagnostic et de configuration incohérente. **Gain non
mesuré**. Aucun pourcentage de temps ou de tokens n'est attribué à ces propositions.
Les incidents futurs distingueront cause confirmée, probable et inconnue, défaut
du projet, défaut du provider et défaut du plugin.
