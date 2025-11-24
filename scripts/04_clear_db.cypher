// ============================================
// NETTOYAGE DE LA BASE DE DONNÉES
// Projet: Graphe d'amitié entre étudiants
// Date: 24 novembre 2025
// ============================================

// ATTENTION : Ce script supprime TOUTES les données !
// À utiliser uniquement pour réinitialiser la base

// ============================================
// OPTION 1 : Supprimer toutes les données
// ============================================

MATCH (n)
DETACH DELETE n;

// ============================================
// OPTION 2 : Supprimer uniquement certains types de nœuds
// ============================================

// Supprimer uniquement les étudiants et leurs relations
// MATCH (e:Etudiant)
// DETACH DELETE e;

// Supprimer uniquement les cours et leurs relations
// MATCH (c:Cours)
// DETACH DELETE c;

// Supprimer uniquement les villes et leurs relations
// MATCH (v:Ville)
// DETACH DELETE v;

// ============================================
// OPTION 3 : Supprimer uniquement les relations
// ============================================

// Supprimer toutes les amitiés
// MATCH ()-[r:AMI_AVEC]->()
// DELETE r;

// Supprimer toutes les inscriptions aux cours
// MATCH ()-[r:ÉTUDIE]->()
// DELETE r;

// ============================================
// VÉRIFICATION APRÈS SUPPRESSION
// ============================================

// Compter ce qui reste
MATCH (n)
RETURN labels(n) as Type, COUNT(*) as Nombre;

// Vérifier qu'il n'y a plus de relations
MATCH ()-[r]->()
RETURN type(r) as TypeRelation, COUNT(*) as Nombre;
