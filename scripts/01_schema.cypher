// ============================================
// SCHEMA ET CONTRAINTES - BASE NEO4J
// Projet: Graphe d'amitié entre étudiants
// Date: 24 novembre 2025
// ============================================

// Supprimer les contraintes existantes (optionnel, pour reset)
// DROP CONSTRAINT student_id IF EXISTS;
// DROP CONSTRAINT cours_code IF EXISTS;

// ============================================
// CONTRAINTES D'UNICITÉ
// ============================================

// Contrainte sur l'ID des étudiants
CREATE CONSTRAINT student_id IF NOT EXISTS
FOR (s:Etudiant) REQUIRE s.id IS UNIQUE;

// Contrainte sur le code des cours
CREATE CONSTRAINT cours_code IF NOT EXISTS
FOR (c:Cours) REQUIRE c.code IS UNIQUE;

// Contrainte sur l'email des étudiants
CREATE CONSTRAINT student_email IF NOT EXISTS
FOR (s:Etudiant) REQUIRE s.email IS UNIQUE;

// ============================================
// INDEX POUR AMÉLIORER LES PERFORMANCES
// ============================================

// Index sur le nom des étudiants
CREATE INDEX student_name IF NOT EXISTS
FOR (s:Etudiant) ON (s.nom);

// Index sur la ville
CREATE INDEX student_ville IF NOT EXISTS
FOR (s:Etudiant) ON (s.ville);

// Index sur la filière
CREATE INDEX student_filiere IF NOT EXISTS
FOR (s:Etudiant) ON (s.filiere);

// Index sur le nom des cours
CREATE INDEX cours_nom IF NOT EXISTS
FOR (c:Cours) ON (c.nom);

// ============================================
// VÉRIFICATION
// ============================================

// Afficher toutes les contraintes
SHOW CONSTRAINTS;

// Afficher tous les index
SHOW INDEXES;
