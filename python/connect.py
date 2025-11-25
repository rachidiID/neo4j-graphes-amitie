"""
Connexion à Neo4j
Projet: Graphe d'amitié entre étudiants
Date: 24 novembre 2025
"""

from neo4j import GraphDatabase
import os
from typing import List, Dict, Any

class Neo4jConnection:
    """Classe pour gérer la connexion à Neo4j"""
    
    def __init__(self, uri: str, user: str, password: str):
        """
        Initialiser la connexion
        
        Args:
            uri: URI de connexion (ex: bolt://localhost:7687)
            user: Nom d'utilisateur
            password: Mot de passe
        """
        self.driver = GraphDatabase.driver(uri, auth=(user, password))
        print(f"✓ Connecté à Neo4j : {uri}")
    
    def close(self):
        """Fermer la connexion"""
        if self.driver:
            self.driver.close()
            print("✓ Connexion fermée")
    
    def query(self, query: str, parameters: Dict = None) -> List[Dict[str, Any]]:
        """
        Exécuter une requête Cypher
        
        Args:
            query: Requête Cypher
            parameters: Paramètres optionnels
            
        Returns:
            Liste des résultats
        """
        with self.driver.session() as session:
            result = session.run(query, parameters or {})
            return [dict(record) for record in result]
    
    def execute_file(self, filepath: str):
        """
        Exécuter un fichier .cypher
        
        Args:
            filepath: Chemin du fichier Cypher
        """
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Nettoyer les commentaires et lignes vides
        lines = []
        for line in content.split('\n'):
            line = line.strip()
            # Ignorer les commentaires et lignes vides
            if line and not line.startswith('//'):
                lines.append(line)
        
        # Rejoindre et séparer par point-virgule
        cleaned = ' '.join(lines)
        queries = [q.strip() for q in cleaned.split(';') if q.strip()]
        
        with self.driver.session() as session:
            for q in queries:
                if q and len(q) > 5:  # Ignorer les requêtes trop courtes
                    try:
                        result = session.run(q)
                        # Consommer le résultat pour détecter les erreurs
                        summary = result.consume()
                        print(f"✓ Requête exécutée")
                    except Exception as e:
                        print(f"✗ Erreur sur requête : {str(e)[:100]}")
                        print(f"   Requête : {q[:80]}...")
    
    def test_connection(self) -> bool:
        """
        Tester la connexion
        
        Returns:
            True si connecté, False sinon
        """
        try:
            with self.driver.session() as session:
                result = session.run("RETURN 1 AS num")
                record = result.single()
                if record and record["num"] == 1:
                    print("✓ Connexion réussie !")
                    return True
        except Exception as e:
            print(f"✗ Erreur de connexion : {e}")
            return False
        return False
    
    def get_stats(self) -> Dict[str, int]:
        """
        Obtenir des statistiques sur la base
        
        Returns:
            Dictionnaire avec les statistiques
        """
        stats = {}
        
        # Nombre d'étudiants
        result = self.query("MATCH (e:Etudiant) RETURN COUNT(e) as count")
        stats['etudiants'] = result[0]['count'] if result else 0
        
        # Nombre de cours
        result = self.query("MATCH (c:Cours) RETURN COUNT(c) as count")
        stats['cours'] = result[0]['count'] if result else 0
        
        # Nombre d'amitiés
        result = self.query("MATCH ()-[r:AMI_AVEC]->() RETURN COUNT(r) as count")
        stats['amities'] = result[0]['count'] if result else 0
        
        # Nombre d'inscriptions
        result = self.query("MATCH ()-[r:ÉTUDIE]->() RETURN COUNT(r) as count")
        stats['inscriptions'] = result[0]['count'] if result else 0
        
        return stats


def main():
    """Fonction principale de test"""
    
    # Configuration
    URI = "bolt://localhost:7687"
    USER = "neo4j"
    PASSWORD = "password123"  # À changer selon votre config
    
    # Connexion
    conn = Neo4jConnection(URI, USER, PASSWORD)
    
    # Test
    if conn.test_connection():
        # Afficher les statistiques
        stats = conn.get_stats()
        print("\n=== Statistiques de la base ===")
        for key, value in stats.items():
            print(f"{key.capitalize()}: {value}")
        
        # Exemple de requête
        print("\n=== Liste des étudiants ===")
        etudiants = conn.query("""
            MATCH (e:Etudiant)
            RETURN e.nom as nom, e.prenom as prenom, e.ville as ville
            ORDER BY e.nom
            LIMIT 5
        """)
        
        for etudiant in etudiants:
            print(f"- {etudiant['prenom']} {etudiant['nom']} ({etudiant['ville']})")
    
    # Fermer
    conn.close()


if __name__ == "__main__":
    main()
