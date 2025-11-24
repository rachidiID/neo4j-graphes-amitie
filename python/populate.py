"""
Peupler la base de données Neo4j
Projet: Graphe d'amitié entre étudiants
Date: 24 novembre 2025
"""

from connect import Neo4jConnection
import os

def populate_database(conn: Neo4jConnection, scripts_dir: str):
    """
    Peupler la base avec les scripts Cypher
    
    Args:
        conn: Connexion Neo4j
        scripts_dir: Dossier contenant les scripts
    """
    
    scripts = [
        "01_schema.cypher",
        "02_data_initial.cypher"
    ]
    
    print("=== Peuplement de la base de données ===\n")
    
    for script in scripts:
        filepath = os.path.join(scripts_dir, script)
        if os.path.exists(filepath):
            print(f"Exécution de {script}...")
            conn.execute_file(filepath)
            print(f"✓ {script} exécuté\n")
        else:
            print(f"✗ Fichier non trouvé : {filepath}\n")
    
    # Vérifier
    stats = conn.get_stats()
    print("\n=== Vérification ===")
    print(f"Étudiants créés : {stats['etudiants']}")
    print(f"Cours créés : {stats['cours']}")
    print(f"Amitiés créées : {stats['amities']}")
    print(f"Inscriptions créées : {stats['inscriptions']}")


def clear_database(conn: Neo4jConnection):
    """
    Nettoyer la base de données
    
    Args:
        conn: Connexion Neo4j
    """
    response = input("⚠️  Voulez-vous vraiment supprimer toutes les données ? (oui/non) : ")
    
    if response.lower() in ['oui', 'o', 'yes', 'y']:
        print("Suppression en cours...")
        conn.query("MATCH (n) DETACH DELETE n")
        print("✓ Base de données nettoyée")
    else:
        print("Annulé")


def main():
    """Fonction principale"""
    
    # Configuration
    URI = "bolt://localhost:7687"
    USER = "neo4j"
    PASSWORD = "password123"
    SCRIPTS_DIR = "../scripts"
    
    # Connexion
    conn = Neo4jConnection(URI, USER, PASSWORD)
    
    if conn.test_connection():
        # Menu
        print("\n=== Menu ===")
        print("1. Peupler la base de données")
        print("2. Nettoyer la base de données")
        print("3. Les deux (nettoyer puis peupler)")
        
        choix = input("\nVotre choix (1/2/3) : ")
        
        if choix == "1":
            populate_database(conn, SCRIPTS_DIR)
        elif choix == "2":
            clear_database(conn)
        elif choix == "3":
            clear_database(conn)
            populate_database(conn, SCRIPTS_DIR)
        else:
            print("Choix invalide")
    
    conn.close()


if __name__ == "__main__":
    main()
