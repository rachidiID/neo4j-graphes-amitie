# Projet Neo4j : Graphe d'amitié entre étudiants

![Neo4j](https://img.shields.io/badge/Neo4j-5.x-blue)
![Python](https://img.shields.io/badge/Python-3.x-green)
![Cypher](https://img.shields.io/badge/Cypher-Query-orange)

## Description

Ce projet implémente un **graphe social** modélisant les relations d'amitié entre étudiants en utilisant la base de données orientée graphes **Neo4j**. Il comprend :

-  Modélisation complète des données avec contraintes et index
-  Plus de 50 requêtes Cypher pour analyser le réseau social
-  Scripts Python pour l'analyse et la visualisation
-  Génération automatique de graphiques et statistiques
-  Système de recommandations d'amitié
-  Documentation complète (rapport LaTeX + présentation Beamer)

##  Objectifs

- Modéliser un réseau social avec Neo4j
- Analyser les relations et communautés
- Recommander de nouveaux amis basés sur les connexions
- Visualiser le graphe avec NetworkX
- Fournir des insights sur la performance académique

##  Structure du projet

```
exposé_neo4j/
│
├── docker-compose.yml          # Configuration Docker Compose
├── docker-compose.dev.yml      # Version développement
├── DOCKER.md                   # Guide Docker complet
│
├── scripts/                    # Scripts Cypher
│   ├── 01_schema.cypher       # Contraintes et index
│   ├── 02_data_initial.cypher # Données de test (6 étudiants)
│   ├── 03_requetes.cypher     # 50+ requêtes d'analyse
│   └── 04_clear_db.cypher     # Nettoyage de la base
│
├── python/                     # Scripts Python
│   ├── requirements.txt       # Dépendances Python
│   ├── connect.py            # Classe de connexion Neo4j
│   ├── populate.py           # Peuplement de la base
│   └── analyze.py            # Analyses et visualisations
│
├── uml/                       # Diagrammes UML
│   ├── modele_donnees.puml   # Diagramme PlantUML
│   └── README.md             # Instructions génération
│
├── rapport/                   # Documentation
│   └── rapport.tex           # Rapport LaTeX complet (20+ pages)
│
├── presentation.tex           # Présentation Beamer
├── images/                    # Images générées
└── README.md                 # Ce fichier
```

##  Installation

### Prérequis

- **Docker** et **Docker Compose** (recommandé) ou **Neo4j** 5.x
- **Python** 3.8+
- **Git** (optionnel)

### Installation rapide (3 commandes)

```bash
# 1. Démarrer Neo4j
docker-compose up -d

# 2. Installer les dépendances Python
pip install -r python/requirements.txt

# 3. Peupler la base
python python/populate.py  # Choisir option 3
```

### 1. Installer Neo4j

#### Option A : Docker Compose (recommandé) 

La méthode la plus simple avec fichier de configuration :

```bash
# Démarrer Neo4j (avec persistance des données)
docker-compose up -d

# Vérifier que c'est démarré
docker-compose ps

# Voir les logs
docker-compose logs -f neo4j
```

Accéder au navigateur Neo4j : http://localhost:7474

>  Voir `DOCKER.md` pour la documentation complète Docker

#### Option B : Docker Run (commande unique)

```bash
docker run -d \
  --name neo4j-social \
  -p 7474:7474 -p 7687:7687 \
  -e NEO4J_AUTH=neo4j/password123 \
  -v neo4j_data:/data \
  neo4j:latest
```

#### Option C : Neo4j Desktop

1. Télécharger depuis https://neo4j.com/download/
2. Créer un nouveau projet
3. Créer une base de données
4. Démarrer la base

### 2. Installer les dépendances Python

```bash
cd exposé_neo4j/python/
pip install -r requirements.txt
```

Ou dans un environnement virtuel :

```bash
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows
pip install -r requirements.txt
```

##  Utilisation

### Étape 1 : Créer le schéma

Dans le navigateur Neo4j (http://localhost:7474), exécuter :

```bash
# Copier le contenu de scripts/01_schema.cypher
```

Ou depuis Python :

```bash
cd python/
python connect.py
```

### Étape 2 : Peupler la base de données

```bash
python populate.py
```

Choisir l'option **3** (Nettoyer puis peupler) pour initialiser la base avec :
- 6 étudiants
- 5 cours
- 8 paires d'amitiés (16 relations bidirectionnelles)
- 17 inscriptions aux cours

### Étape 3 : Analyser et visualiser

```bash
python analyze.py
```

Choisir l'option **5** (Tout générer) pour créer :
- Rapport texte avec statistiques
- Graphique du réseau d'amitiés (`images/reseau_amities.png`)
- Graphiques statistiques étudiants (`images/stats_etudiants.png`)
- Graphiques statistiques cours (`images/stats_cours.png`)

##  Exemples de requêtes

### Trouver les amis de Rachidi

```cypher
MATCH (e:Etudiant {nom: 'Diallo'})-[:AMI_AVEC]->(ami:Etudiant)
RETURN ami.nom + ' ' + ami.prenom as ami, ami.ville;
```

### Étudiants les plus populaires

```cypher
MATCH (e:Etudiant)-[:AMI_AVEC]->(:Etudiant)
WITH e, COUNT(*) as nb_amis
RETURN e.nom + ' ' + e.prenom as etudiant, nb_amis
ORDER BY nb_amis DESC
LIMIT 5;
```

### Recommandations d'amitié

```cypher
MATCH (e1:Etudiant {nom: 'Diallo'})-[:AMI_AVEC]->()-[:AMI_AVEC]->(e2:Etudiant)
WHERE NOT (e1)-[:AMI_AVEC]->(e2) AND e1 <> e2
WITH e2, COUNT(*) as amis_communs
RETURN e2.nom + ' ' + e2.prenom as suggestion, amis_communs
ORDER BY amis_communs DESC
LIMIT 5;
```

### Plus court chemin entre deux étudiants

```cypher
MATCH path = shortestPath(
  (e1:Etudiant {nom: 'Diallo'})-[:AMI_AVEC*]-(e2:Etudiant {nom: 'Dubois'})
)
RETURN [n IN nodes(path) | n.nom + ' ' + n.prenom] as chemin,
       LENGTH(path) as longueur;
```

Plus de 50 requêtes disponibles dans `scripts/03_requetes.cypher` !

## Modèle de données

### Nœuds (Nodes)

- **Etudiant** : `student_id` (UNIQUE), `nom`, `prenom`, `age`, `email` (UNIQUE), `filiere`, `niveau`, `hobbies`, etc.
- **Cours** : `cours_code` (UNIQUE), `nom`, `credits`, `semestre`, `enseignant`
- **Ville** : `nom`, `departement`, `code_postal`

### Relations (Relationships)

- **AMI_AVEC** : `depuis`, `force` (1-10), `type` (proche/etudes/sport)
- **ÉTUDIE** : `annee`, `note` (0-20), `presence` (0-100%)
- **VIT_À** : `depuis`, `adresse`

Voir `uml/modele_donnees.puml` pour le diagramme complet.

##  Résultats

### Statistiques du réseau

| Métrique | Valeur |
|----------|--------|
| Étudiants | 6 |
| Cours | 5 |
| Amitiés | 16 (8 paires bidirectionnelles) |
| Inscriptions | 17 |
| Densité du réseau | 53% |
| Diamètre du graphe | 2 |

### Top 3 étudiants (par nombre d'amis)

1. **Rachidi Diallo** - 4 amis
2. **Marie Dupont** - 4 amis
3. **Ahmed Ben Ali** - 3 amis

### Recommandations d'amitié

| Étudiant | Suggestion | Amis communs |
|----------|-----------|--------------|
| Thomas | Laura | 2 |
| Sophie | Laura | 2 |
| Rachidi | Laura | 1 |

## Technologies

- **Neo4j 5.x** - Base de données orientée graphes
- **Cypher** - Langage de requête déclaratif
- **Python 3.x** - Scripts d'analyse
- **neo4j-driver** - Connecteur Python officiel
- **NetworkX** - Analyse et visualisation de graphes
- **Matplotlib/Seaborn** - Graphiques et statistiques
- **Pandas** - Manipulation de données
- **LaTeX** - Documentation professionnelle

## Documentation

### Rapport complet

Compiler le rapport LaTeX (20+ pages) :

```bash
cd rapport/
pdflatex rapport.tex
pdflatex rapport.tex  # Deux fois pour la table des matières
```

### Présentation Beamer

Compiler la présentation :

```bash
pdflatex presentation.tex
pdflatex presentation.tex
```

### Diagramme UML

Générer le diagramme :

```bash
cd uml/
plantuml modele_donnees.puml
# Génère modele_donnees.png
```

## Configuration

### Modifier les paramètres de connexion

Éditer dans chaque script Python :

```python
URI = "bolt://localhost:7687"
USER = "neo4j"
PASSWORD = "password123"  #  Changer selon votre config
```

### Ajouter des données

Modifier `scripts/02_data_initial.cypher` pour ajouter :
- Plus d'étudiants
- Plus de cours
- Plus de relations d'amitié

Puis relancer `python populate.py`.

## Scénarios avancés

Le fichier `scripts/03_requetes.cypher` contient 9 catégories :

1. **Requêtes de base** - Lister, filtrer, compter
2. **Analyse des amitiés** - Force, types, popularité
3. **Analyse des cours** - Inscriptions, moyennes, taux de présence
4. **Recommandations** - Basées sur amis communs, cours, hobbies
5. **Analyse du réseau** - Chemins, cliques, centralité
6. **Analyse géographique** - Groupes par ville
7. **Statistiques globales** - Moyennes, min/max, distributions
8. **Mises à jour** - Ajouter/supprimer relations, modifier notes
9. **Export de données** - JSON, CSV

##  Compétences démontrées

-  Modélisation de données en graphes
-  Maîtrise du langage Cypher
-  Analyse de réseaux sociaux
-  Programmation Python orientée objet
-  Visualisation de données
-  Algorithmes de graphes (shortest path, recommandations)
-  Documentation technique (LaTeX, Markdown)

##  Améliorations futures

### Court terme
- [ ] Ajouter plus d'étudiants (20-50)
- [ ] Intégrer l'évolution temporelle
- [ ] Recommandations multi-critères (hobbies + cours + ville)
- [ ] Dashboard interactif avec Streamlit

### Long terme
- [ ] Interface web (Flask/Django + D3.js)
- [ ] Algorithmes avancés (PageRank, Louvain, Label Propagation)
- [ ] Machine Learning pour prédiction de liens
- [ ] API REST avec FastAPI
- [ ] Intégration LDAP/Active Directory
- [ ] Déploiement cloud (AWS/GCP/Azure)

##  Contribution

Ce projet a été réalisé par **Rachidi et équipe** dans le cadre d'un projet universitaire sur les bases de données NoSQL.

### Pour contribuer :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/amelioration`)
3. Commit les changements (`git commit -m 'Ajout fonctionnalité X'`)
4. Push vers la branche (`git push origin feature/amelioration`)
5. Ouvrir une Pull Request

##  Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

##  Contact

Pour toute question ou suggestion :

- **Auteur** : Rachidi Diallo
- **Email** : rachidi.diallo@univ.fr
- **Projet** : Master Informatique - Bases de données NoSQL

##  Remerciements

- **Neo4j** pour leur excellente documentation
- **NetworkX** pour les outils de visualisation
- La communauté Python pour les bibliothèques utilisées
- Nos professeurs pour leur accompagnement

---

 **N'oubliez pas de mettre une étoile si ce projet vous a aidé !** 

## Ressources

- [Documentation Neo4j](https://neo4j.com/docs/)
- [Cypher Manual](https://neo4j.com/docs/cypher-manual/)
- [NetworkX Documentation](https://networkx.org/documentation/)
- [Neo4j Graph Data Science](https://neo4j.com/docs/graph-data-science/)
- [Graph Algorithms Book](https://neo4j.com/graph-algorithms-book/)

---

*Projet créé le 24 novembre 2025*
