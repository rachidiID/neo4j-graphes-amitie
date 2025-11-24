# Guide de Démarrage Rapide - Projet Neo4j

## Installation et Visualisation en 8 Étapes

### Étape 1 : Démarrer Neo4j (2 min)

```bash
cd exposé_neo4j/
docker-compose up -d
sleep 15
docker-compose ps  # Doit afficher "Up"
```

**Vérification :** http://localhost:7474 (neo4j / password123)

---

### Étape 2 : Installer Python (2 min)

```bash
python3 -m venv venv
source venv/bin/activate
cd python/
pip install -r requirements.txt
```

---

### Étape 3 : Tester la connexion (30 sec)

```bash
python3 connect.py
# ✓ Doit afficher : "Connecté à Neo4j"
```

---

### Étape 4 : Peupler la base (1 min)

```bash
python3 populate.py
```
- Taper **3** (Les deux)
- Taper **oui**
- Résultat : 6 étudiants, 5 cours, 16 amitiés créés

---

### Étape 5 : Visualiser dans Neo4j Browser (5 min)

http://localhost:7474

**Requête 1 - Tout voir :**
```cypher
MATCH (n) RETURN n LIMIT 50
```

**Requête 2 - Amis de Rachidi :**
```cypher
MATCH (rachidi:Etudiant {nom: 'Diallo'})-[:AMI_AVEC]->(ami)
RETURN rachidi, ami
```

**Requête 3 - Recommandations :**
```cypher
MATCH (e1:Etudiant {nom: 'Diallo'})-[:AMI_AVEC]->()-[:AMI_AVEC]->(e2)
WHERE NOT (e1)-[:AMI_AVEC]->(e2) AND e1 <> e2
RETURN e2.nom + ' ' + e2.prenom as suggestion, COUNT(*) as amis_communs
ORDER BY amis_communs DESC
```

---

### Étape 6 : Générer les graphiques (2 min)

```bash
python3 analyze.py
```
- Taper **5** (Tout générer)
- 3 images créées dans `../images/`

---

### Étape 7 : Voir les graphiques (2 min)

```bash
cd ../images/
xdg-open reseau_amities.png      # Réseau social
xdg-open stats_etudiants.png     # 4 graphiques stats
xdg-open stats_cours.png         # Stats cours
```

---

### Étape 8 : Documents PDF (3 min)

```bash
# Rapport (19 pages)
cd ../rapport/
pdflatex rapport.tex
pdflatex rapport.tex
evince rapport.pdf &

# Présentation (28 slides)
cd ..
pdflatex presentation.tex
pdflatex presentation.tex
evince presentation.pdf &

# UML
cd uml/
sudo apt install plantuml
plantuml modele_donnees.puml
xdg-open modele_donnees.png
```

---

## Résumé : Vous avez visualisé

**Neo4j Browser** - Graphe interactif  
 **3 Graphiques PNG** - NetworkX + Stats  
 **Diagramme UML** - Modèle de données  
 **Rapport PDF** - 19 pages (364 Ko)  
 **Présentation PDF** - 28 slides (305 Ko)  

**Temps total : ~25 minutes** 

---

##  Arrêter

```bash
docker-compose stop          # Arrêter (conserve données)
docker-compose down          # Supprimer conteneur
docker-compose down -v       # Supprimer + données
```

---

## Documentation complète

- `README.md` - Vue d'ensemble du projet
- `GUIDE_COMPLET.md` - Guide détaillé avec dépannage
- `DOCKER.md` - Documentation Docker (sera créée)
- `rapport/rapport.pdf` - Rapport académique complet
- `presentation.pdf` - Présentation Beamer

---

**Projet Neo4j - Graphe Social d'Étudiants**  
*Créé le 24 novembre 2025*
