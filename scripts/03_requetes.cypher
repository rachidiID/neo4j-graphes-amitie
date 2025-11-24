// ============================================
// REQUÊTES D'ANALYSE
// Projet: Graphe d'amitié entre étudiants
// Date: 24 novembre 2025
// ============================================

// ============================================
// 1. REQUÊTES DE BASE
// ============================================

// 1.1 Afficher tous les étudiants
MATCH (e:Etudiant)
RETURN e.nom, e.prenom, e.ville, e.hobbies, e.email
ORDER BY e.nom;

// 1.2 Afficher tous les cours
MATCH (c:Cours)
RETURN c.code, c.nom, c.credits, c.professeur
ORDER BY c.code;

// 1.3 Nombre total d'étudiants et de cours
MATCH (e:Etudiant)
WITH COUNT(e) as nb_etudiants
MATCH (c:Cours)
RETURN nb_etudiants, COUNT(c) as nb_cours;

// ============================================
// 2. REQUÊTES SUR LES AMITIÉS
// ============================================

// 2.1 Trouver les amis de Rachidi
MATCH (rachidi:Etudiant {nom: "Rachidi"})-[:AMI_AVEC]->(ami)
RETURN ami.nom, ami.prenom, ami.ville
ORDER BY ami.nom;

// 2.2 Qui a le plus d'amis ?
MATCH (e:Etudiant)-[:AMI_AVEC]->()
RETURN e.nom, e.prenom, COUNT(*) as nombre_amis
ORDER BY nombre_amis DESC
LIMIT 5;

// 2.3 Liste complète des amitiés avec force de relation
MATCH (e1:Etudiant)-[r:AMI_AVEC]->(e2:Etudiant)
WHERE id(e1) < id(e2)  // Éviter les doublons
RETURN e1.nom + ' ' + e1.prenom as Personne1,
       e2.nom + ' ' + e2.prenom as Personne2,
       r.force as Force,
       r.type as Type,
       r.depuis as Depuis
ORDER BY r.force DESC;

// 2.4 Amitiés les plus fortes (>= 8)
MATCH (e1:Etudiant)-[r:AMI_AVEC]->(e2:Etudiant)
WHERE r.force >= 8 AND id(e1) < id(e2)
RETURN e1.nom, e2.nom, r.force, r.type
ORDER BY r.force DESC;

// 2.5 Force moyenne des amitiés
MATCH ()-[r:AMI_AVEC]->()
RETURN AVG(r.force) as force_moyenne,
       MIN(r.force) as force_min,
       MAX(r.force) as force_max;

// ============================================
// 3. REQUÊTES SUR LES COURS
// ============================================

// 3.1 Cours communs entre Rachidi et Marie
MATCH (e1:Etudiant {nom: "Rachidi"})-[:ÉTUDIE]->(c:Cours)<-[:ÉTUDIE]-(e2:Etudiant {nom: "Dupont"})
RETURN c.code, c.nom, c.credits
ORDER BY c.code;

// 3.2 Qui étudie quoi ? (avec notes)
MATCH (e:Etudiant)-[r:ÉTUDIE]->(c:Cours)
RETURN e.nom + ' ' + e.prenom as Etudiant,
       c.code,
       c.nom as Cours,
       r.note,
       r.presence
ORDER BY e.nom, c.code;

// 3.3 Cours les plus populaires
MATCH (e:Etudiant)-[:ÉTUDIE]->(c:Cours)
RETURN c.code, c.nom, COUNT(e) as nombre_etudiants
ORDER BY nombre_etudiants DESC;

// 3.4 Moyenne des notes par cours
MATCH ()-[r:ÉTUDIE]->(c:Cours)
RETURN c.code,
       c.nom,
       AVG(r.note) as moyenne,
       MIN(r.note) as note_min,
       MAX(r.note) as note_max,
       COUNT(*) as nb_etudiants
ORDER BY moyenne DESC;

// 3.5 Groupes d'étude potentiels (même cours)
MATCH (e:Etudiant)-[:ÉTUDIE]->(c:Cours)
WITH c, COLLECT(e.nom + ' ' + e.prenom) as etudiants
WHERE SIZE(etudiants) >= 2
RETURN c.nom as Cours, etudiants, SIZE(etudiants) as Taille
ORDER BY Taille DESC;

// ============================================
// 4. RECOMMANDATIONS
// ============================================

// 4.1 Recommander des amis à Rachidi (amis d'amis)
MATCH (moi:Etudiant {nom: "Rachidi"})-[:AMI_AVEC]->()-[:AMI_AVEC]->(recommandation)
WHERE NOT (moi)-[:AMI_AVEC]->(recommandation)
  AND moi <> recommandation
RETURN DISTINCT recommandation.nom,
       recommandation.prenom,
       recommandation.ville,
       COUNT(*) as amis_communs
ORDER BY amis_communs DESC;

// 4.2 Recommander des cours basés sur les amis
MATCH (moi:Etudiant {nom: "Rachidi"})-[:AMI_AVEC]->(ami)-[:ÉTUDIE]->(c:Cours)
WHERE NOT (moi)-[:ÉTUDIE]->(c)
RETURN c.code,
       c.nom,
       COUNT(DISTINCT ami) as nb_amis_suivant,
       COLLECT(DISTINCT ami.nom) as amis
ORDER BY nb_amis_suivant DESC;

// 4.3 Trouver des personnes avec hobbies communs
MATCH (e1:Etudiant {nom: "Rachidi"}), (e2:Etudiant)
WHERE e1 <> e2
  AND ANY(h IN e1.hobbies WHERE h IN e2.hobbies)
RETURN e2.nom,
       e2.prenom,
       [h IN e1.hobbies WHERE h IN e2.hobbies] as hobbies_communs,
       SIZE([h IN e1.hobbies WHERE h IN e2.hobbies]) as nb_communs
ORDER BY nb_communs DESC;

// ============================================
// 5. ANALYSES DE RÉSEAU
// ============================================

// 5.1 Plus court chemin d'amitié entre deux personnes
MATCH path = shortestPath(
  (e1:Etudiant {nom: "Rachidi"})-[:AMI_AVEC*]-(e2:Etudiant {nom: "Laura"})
)
RETURN [n IN nodes(path) | n.nom + ' ' + n.prenom] as Chemin,
       LENGTH(path) as Distance;

// 5.2 Tous les chemins entre deux personnes (max 4 sauts)
MATCH path = (e1:Etudiant {nom: "Rachidi"})-[:AMI_AVEC*..4]-(e2:Etudiant {nom: "Thomas"})
RETURN [n IN nodes(path) | n.nom] as Chemin,
       LENGTH(path) as Distance
ORDER BY Distance
LIMIT 5;

// 5.3 Trouver les communautés (groupes d'amis connectés)
MATCH (e:Etudiant)-[:AMI_AVEC]->()
WITH e, COUNT(*) as nb_amis
WHERE nb_amis >= 3
RETURN e.nom, e.prenom, nb_amis
ORDER BY nb_amis DESC;

// 5.4 Degré de centralité (qui est le plus connecté)
MATCH (e:Etudiant)
OPTIONAL MATCH (e)-[:AMI_AVEC]->(ami)
RETURN e.nom,
       e.prenom,
       COUNT(ami) as degre,
       e.ville
ORDER BY degre DESC;

// 5.5 Réseau complet d'un étudiant (amis + cours)
MATCH (e:Etudiant {nom: "Rachidi"})-[r]->(n)
RETURN e, r, n;

// ============================================
// 6. ANALYSES GÉOGRAPHIQUES
// ============================================

// 6.1 Répartition des étudiants par ville
MATCH (e:Etudiant)-[:VIT_À]->(v:Ville)
RETURN v.nom as Ville,
       v.region as Region,
       COUNT(e) as Nombre_etudiants
ORDER BY Nombre_etudiants DESC;

// 6.2 Amitiés dans la même ville vs différentes villes
MATCH (e1:Etudiant)-[:AMI_AVEC]->(e2:Etudiant)
WHERE id(e1) < id(e2)
WITH e1.ville = e2.ville as meme_ville, COUNT(*) as nombre
RETURN CASE meme_ville
         WHEN true THEN 'Même ville'
         ELSE 'Villes différentes'
       END as Type,
       nombre;

// 6.3 Étudiants de Paris et leurs amis
MATCH (e:Etudiant {ville: "Paris"})-[:AMI_AVEC]->(ami)
RETURN e.nom, e.prenom,
       COLLECT(ami.nom + ' (' + ami.ville + ')') as amis
ORDER BY e.nom;

// ============================================
// 7. STATISTIQUES AVANCÉES
// ============================================

// 7.1 Performance académique par étudiant
MATCH (e:Etudiant)-[r:ÉTUDIE]->(c:Cours)
RETURN e.nom + ' ' + e.prenom as Etudiant,
       COUNT(c) as nb_cours,
       AVG(r.note) as moyenne_generale,
       AVG(r.presence) as taux_presence_moyen
ORDER BY moyenne_generale DESC;

// 7.2 Corrélation amitié-cours communs
MATCH (e1:Etudiant)-[:AMI_AVEC]->(e2:Etudiant)
OPTIONAL MATCH (e1)-[:ÉTUDIE]->(c:Cours)<-[:ÉTUDIE]-(e2)
WHERE id(e1) < id(e2)
RETURN e1.nom + ' <-> ' + e2.nom as Amitie,
       COUNT(DISTINCT c) as Cours_communs
ORDER BY Cours_communs DESC;

// 7.3 Hobbies les plus populaires
MATCH (e:Etudiant)
UNWIND e.hobbies as hobby
RETURN hobby, COUNT(*) as popularite
ORDER BY popularite DESC;

// 7.4 Matrice d'adjacence (qui est ami avec qui)
MATCH (e:Etudiant)
OPTIONAL MATCH (e)-[:AMI_AVEC]->(ami)
RETURN e.nom as Etudiant,
       COLLECT(ami.nom) as Amis,
       SIZE(COLLECT(ami.nom)) as Nombre_amis
ORDER BY e.nom;

// ============================================
// 8. REQUÊTES DE MISE À JOUR
// ============================================

// 8.1 Ajouter un nouveau hobby à un étudiant
// MATCH (e:Etudiant {nom: "Rachidi"})
// SET e.hobbies = e.hobbies + ["natation"];

// 8.2 Mettre à jour la force d'une amitié
// MATCH (e1:Etudiant {nom: "Rachidi"})-[r:AMI_AVEC]->(e2:Etudiant {nom: "Dupont"})
// SET r.force = 10;

// 8.3 Ajouter une nouvelle amitié
// MATCH (e1:Etudiant {nom: "Rachidi"}), (e2:Etudiant {nom: "Garcia"})
// CREATE (e1)-[:AMI_AVEC {depuis: date(), force: 5, type: "connaissance"}]->(e2)
// CREATE (e2)-[:AMI_AVEC {depuis: date(), force: 5, type: "connaissance"}]->(e1);

// ============================================
// 9. EXPORT ET VISUALISATION
// ============================================

// 9.1 Réseau complet (pour visualisation)
MATCH (e:Etudiant)-[r:AMI_AVEC]->(ami)
WHERE id(e) < id(ami)
RETURN e, r, ami;

// 9.2 Graphe cours-étudiants
MATCH (e:Etudiant)-[r:ÉTUDIE]->(c:Cours)
RETURN e, r, c;

// 9.3 Vue complète du réseau social
MATCH (n)-[r]->(m)
RETURN n, r, m
LIMIT 100;
