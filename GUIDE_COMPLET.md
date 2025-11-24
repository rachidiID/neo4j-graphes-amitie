# Guide Complet : De l'Installation à la Visualisation

## Prérequis
- Docker et Docker Compose installés
- Python 3.8+ avec pip

---

## ÉTAPE 1 : Installer Docker (si pas déjà fait)

```bash
# Sur Debian/Ubuntu
sudo apt update
sudo apt install docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# Ajouter votre utilisateur au groupe docker (évite sudo)
sudo usermod -aG docker $USER
newgrp docker  # Ou redémarrer la session
```

Vérifier l'installation :
```bash
docker --version
docker-compose --version
```

---

## ÉTAPE 2 : Démarrer Neo4j avec Docker Compose

```bash
# Se placer dans le dossier du projet
cd exposé_neo4j/

# Démarrer Neo4j (télécharge l'image si nécessaire)
docker-compose up -d

# Attendre 10-15 secondes que Neo4j démarre
sleep 15

# Vérifier que c'est démarré
docker-compose ps
# Vous devez voir : neo4j-social-graph   Up

# Voir les logs (optionnel)
docker-compose logs -f neo4j
# Appuyer sur Ctrl+C pour quitter
```

**Vérification :** Ouvrir http://localhost:7474 dans un navigateur
- Login : `neo4j`
- Password : `password123`

---

## ÉTAPE 3 : Installer les dépendances Python

```bash
# Créer un environnement virtuel (recommandé)
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Installer les packages
cd python/
pip install -r requirements.txt

# Vérifier l'installation
pip list | grep neo4j
```

---

## ÉTAPE 4 : Tester la connexion Neo4j

```bash
# Dans le dossier python/
python3 connect.py

# Vous devez voir :
# ✓ Connecté à Neo4j : bolt://localhost:7687
# ✓ Connexion réussie !
# === Statistiques de la base ===
# Etudiants: 0  (normal, base vide pour l'instant)
```

---

## ÉTAPE 5 : Peupler la base de données

```bash
python3 populate.py
```

**Menu qui apparaît :**
```
=== Menu ===
1. Peupler la base de données
2. Nettoyer la base de données
3. Les deux (nettoyer puis peupler)

Votre choix (1/2/3) :
```

**Tapez `3` et appuyez sur Entrée**

Vous verrez :
```
 Voulez-vous vraiment supprimer toutes les données ? (oui/non) :
```

**Tapez `oui` et appuyez sur Entrée**

Résultat attendu :
```
✓ Base de données nettoyée
Exécution de 01_schema.cypher...
✓ 01_schema.cypher exécuté
Exécution de 02_data_initial.cypher...
✓ 02_data_initial.cypher exécuté

=== Vérification ===
Étudiants créés : 6
Cours créés : 5
Amitiés créées : 16
Inscriptions créées : 17
```

---

## ÉTAPE 6 : Visualiser dans Neo4j Browser

Ouvrir http://localhost:7474

### Requête 1 : Voir tout le graphe
```cypher
MATCH (n) RETURN n LIMIT 50
```

**Résultat :** Vous voyez le graphe complet avec :
- 6 cercles bleus = étudiants
- 5 cercles verts = cours
- 3 cercles orange = villes
- Flèches rouges = amitiés
- Flèches bleues = inscriptions aux cours

### Requête 2 : Liste des étudiants
```cypher
MATCH (e:Etudiant)
RETURN e.nom, e.prenom, e.ville, e.age
ORDER BY e.nom
```

### Requête 3 : Réseau d'amis de Rachidi
```cypher
MATCH (rachidi:Etudiant {nom: 'Diallo'})-[:AMI_AVEC]->(ami:Etudiant)
RETURN rachidi, ami
```

### Requête 4 : Recommandations d'amitié
```cypher
MATCH (e1:Etudiant {nom: 'Diallo'})-[:AMI_AVEC]->()-[:AMI_AVEC]->(e2:Etudiant)
WHERE NOT (e1)-[:AMI_AVEC]->(e2) AND e1 <> e2
WITH e2, COUNT(*) as amis_communs
RETURN e2.nom + ' ' + e2.prenom as suggestion, amis_communs
ORDER BY amis_communs DESC
```

---

## ÉTAPE 7 : Générer les graphiques Python

```bash
# Retour dans le dossier python/
python3 analyze.py
```

**Menu qui apparaît :**
```
=== Menu d'analyse ===
1. Rapport texte complet
2. Graphique réseau d'amitiés
3. Graphiques statistiques étudiants
4. Graphiques statistiques cours
5. Tout générer

Votre choix (1/2/3/4/5) :
```

**Tapez `5` et appuyez sur Entrée**

Résultat :
```
=== RAPPORT D'ANALYSE DU GRAPHE SOCIAL ===
STATISTIQUES GÉNÉRALES
...
✓ Graphe sauvegardé : ../images/reseau_amities.png
✓ Statistiques sauvegardées : ../images/stats_etudiants.png
✓ Statistiques cours sauvegardées : ../images/stats_cours.png
```

---

## ÉTAPE 8 : Visualiser les graphiques générés

```bash
# Aller dans le dossier images
cd ../images/

# Lister les fichiers
ls -lh

# Ouvrir les images (Linux)
xdg-open reseau_amities.png
xdg-open stats_etudiants.png
xdg-open stats_cours.png

# Ou avec un autre viewer
eog reseau_amities.png
```

**Vous verrez :**

1. **reseau_amities.png** : Graphe du réseau social
   - Cercles bleus = étudiants
   - Lignes = amitiés (épaisseur = force)
   - Labels = noms des étudiants

2. **stats_etudiants.png** : 4 graphiques
   - Popularité (nombre d'amis)
   - Répartition géographique (camembert)
   - Moyennes académiques
   - Corrélation amis vs performance

3. **stats_cours.png** : 2 graphiques
   - Popularité des cours
   - Moyennes par cours avec min/max

---

## ÉTAPE 9 : Compiler les documents LaTeX

```bash
# Compiler le rapport
cd ../rapport/
pdflatex rapport.tex
pdflatex rapport.tex  # 2 fois pour la table des matières

# Ouvrir le PDF
evince rapport.pdf &

# Compiler la présentation
cd ..
pdflatex presentation.tex
pdflatex presentation.tex

# Ouvrir la présentation
evince presentation.pdf &
```

---

## ÉTAPE 10 : Générer le diagramme UML

```bash
# Installer PlantUML (si pas déjà fait)
sudo apt install plantuml

# Générer le diagramme
cd uml/
plantuml modele_donnees.puml

# Ouvrir le diagramme
xdg-open modele_donnees.png
```

**Alternative en ligne :**
1. Ouvrir https://www.plantuml.com/plantuml/uml/
2. Copier le contenu de `uml/modele_donnees.puml`
3. Coller dans l'éditeur
4. Voir le diagramme généré

---

## RÉCAPITULATIF : Ce que vous avez visualisé

 **Interface Neo4j Browser** (http://localhost:7474)
   - Graphe complet interactif
   - Étudiants, cours, villes
   - Relations d'amitié et inscriptions

 **Graphiques Python** (dossier images/)
   - Réseau social avec NetworkX
   - Statistiques étudiants (4 graphiques)
   - Statistiques cours (2 graphiques)

 **Rapport PDF** (19 pages)
   - Théorie complète
   - Exemples de code
   - Résultats et analyses

 **Présentation Beamer** (25+ slides)
   - Pour présenter le projet
   - Slides professionnelles

 **Diagramme UML**
   - Modèle de données
   - Entités et relations

---

##  Arrêter et nettoyer

```bash
# Arrêter Neo4j (conserve les données)
docker-compose stop

# Redémarrer Neo4j
docker-compose start

# Arrêter et supprimer le conteneur (conserve les données)
docker-compose down

# Tout supprimer (conteneur + données)
docker-compose down -v

# Supprimer les images Python générées
rm -rf images/*.png

# Désactiver l'environnement Python
deactivate
```

---

## Dépannage

### Problème 1 : "Cannot connect to Docker daemon"
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
newgrp docker
```

### Problème 2 : "Port 7474 already in use"
```bash
# Trouver le processus
sudo lsof -i :7474

# Arrêter l'ancien Neo4j
docker-compose down
```

### Problème 3 : "ModuleNotFoundError: No module named 'neo4j'"
```bash
# Réinstaller les dépendances
pip install -r python/requirements.txt
```

### Problème 4 : Connexion Python échoue
```bash
# Vérifier que Neo4j tourne
docker-compose ps

# Vérifier les logs
docker-compose logs neo4j

# Attendre 30 secondes après le démarrage
```

### Problème 5 : LaTeX ne compile pas
```bash
# Installer les packages manquants
sudo apt install texlive-full

# Ou version minimale
sudo apt install texlive-latex-base texlive-latex-extra texlive-lang-french
```

---

## Temps estimé par étape

| Étape | Temps | Commentaire |
|-------|-------|-------------|
| 1. Installer Docker | 5 min | Si pas déjà fait |
| 2. Démarrer Neo4j | 2 min | Téléchargement image |
| 3. Python packages | 2 min | |
| 4. Test connexion | 30 sec | |
| 5. Peupler base | 1 min | |
| 6. Visualiser Neo4j | 5 min | Explorer les requêtes |
| 7. Graphiques Python | 2 min | |
| 8. Voir les images | 2 min | |
| 9. Compiler LaTeX | 3 min | |
| 10. UML | 1 min | |
| **TOTAL** | **~25 min** | Installation complète |

---

## Pour aller plus loin

### Ajouter vos propres données
Éditer `scripts/02_data_initial.cypher` et ajouter :
```cypher
CREATE (votre_nom:Etudiant {
  student_id: 'ETU007',
  nom: 'VotreNom',
  prenom: 'VotrePrenom',
  age: 22,
  ...
})
```

Puis :
```bash
python3 python/populate.py  # Choix 3
```

### Tester d'autres requêtes
Voir le fichier `scripts/03_requetes.cypher` qui contient 50+ requêtes !

### Modifier les graphiques
Éditer `python/analyze.py` et personnaliser :
- Couleurs
- Taille des nœuds
- Layout du graphe
- Titres et labels

---

**Projet complet créé le 24 novembre 2025** 
