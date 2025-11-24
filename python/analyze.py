"""
Analyses et visualisations du graphe social
Projet: Graphe d'amitié entre étudiants
Date: 24 novembre 2025
"""

from connect import Neo4jConnection
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import networkx as nx
from typing import List, Dict

# Configuration des graphiques
plt.style.use('seaborn-v0_8-darkgrid')
sns.set_palette("husl")


class GraphAnalyzer:
    """Classe pour analyser le graphe social"""
    
    def __init__(self, conn: Neo4jConnection):
        self.conn = conn
    
    def get_friendships(self) -> pd.DataFrame:
        """Obtenir toutes les amitiés"""
        query = """
        MATCH (e1:Etudiant)-[r:AMI_AVEC]->(e2:Etudiant)
        WHERE id(e1) < id(e2)
        RETURN e1.nom + ' ' + e1.prenom as personne1,
               e2.nom + ' ' + e2.prenom as personne2,
               r.force as force,
               r.type as type
        """
        results = self.conn.query(query)
        return pd.DataFrame(results)
    
    def get_students_stats(self) -> pd.DataFrame:
        """Statistiques par étudiant"""
        query = """
        MATCH (e:Etudiant)
        OPTIONAL MATCH (e)-[:AMI_AVEC]->(:Etudiant)
        WITH e, COUNT(*) as nb_amis
        OPTIONAL MATCH (e)-[r:ÉTUDIE]->(:Cours)
        RETURN e.nom + ' ' + e.prenom as etudiant,
               e.ville as ville,
               nb_amis,
               COUNT(r) as nb_cours,
               AVG(r.note) as moyenne
        ORDER BY nb_amis DESC
        """
        results = self.conn.query(query)
        return pd.DataFrame(results)
    
    def get_courses_stats(self) -> pd.DataFrame:
        """Statistiques par cours"""
        query = """
        MATCH (c:Cours)<-[r:ÉTUDIE]-(e:Etudiant)
        RETURN c.code as code,
               c.nom as cours,
               COUNT(e) as nb_etudiants,
               AVG(r.note) as moyenne,
               MIN(r.note) as note_min,
               MAX(r.note) as note_max
        ORDER BY nb_etudiants DESC
        """
        results = self.conn.query(query)
        return pd.DataFrame(results)
    
    def plot_friendship_network(self, save_path: str = None):
        """Visualiser le réseau d'amitiés"""
        # Récupérer les données
        query = """
        MATCH (e1:Etudiant)-[r:AMI_AVEC]->(e2:Etudiant)
        WHERE id(e1) < id(e2)
        RETURN e1.nom as source, e2.nom as target, r.force as weight
        """
        edges = self.conn.query(query)
        
        # Créer le graphe
        G = nx.Graph()
        for edge in edges:
            G.add_edge(edge['source'], edge['target'], weight=edge['weight'])
        
        # Visualiser
        plt.figure(figsize=(12, 8))
        pos = nx.spring_layout(G, k=2, iterations=50)
        
        # Dessiner les nœuds
        nx.draw_networkx_nodes(G, pos, 
                               node_color='lightblue',
                               node_size=3000,
                               alpha=0.9)
        
        # Dessiner les arêtes avec épaisseur selon la force
        edges = G.edges()
        weights = [G[u][v]['weight'] for u, v in edges]
        nx.draw_networkx_edges(G, pos,
                               width=[w/2 for w in weights],
                               alpha=0.6,
                               edge_color='gray')
        
        # Labels
        nx.draw_networkx_labels(G, pos, font_size=10, font_weight='bold')
        
        plt.title("Réseau d'amitiés entre étudiants", fontsize=16, fontweight='bold')
        plt.axis('off')
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"✓ Graphe sauvegardé : {save_path}")
        
        plt.show()
    
    def plot_students_stats(self, save_path: str = None):
        """Graphique des statistiques étudiants"""
        df = self.get_students_stats()
        
        fig, axes = plt.subplots(2, 2, figsize=(14, 10))
        
        # 1. Nombre d'amis par étudiant
        axes[0, 0].barh(df['etudiant'], df['nb_amis'], color='skyblue')
        axes[0, 0].set_xlabel('Nombre d\'amis')
        axes[0, 0].set_title('Popularité (nombre d\'amis)')
        axes[0, 0].invert_yaxis()
        
        # 2. Répartition par ville
        ville_counts = df['ville'].value_counts()
        axes[0, 1].pie(ville_counts.values, labels=ville_counts.index, autopct='%1.1f%%')
        axes[0, 1].set_title('Répartition géographique')
        
        # 3. Moyenne générale
        df_sorted = df.sort_values('moyenne', ascending=False)
        axes[1, 0].barh(df_sorted['etudiant'], df_sorted['moyenne'], color='lightgreen')
        axes[1, 0].set_xlabel('Moyenne')
        axes[1, 0].set_title('Performance académique')
        axes[1, 0].invert_yaxis()
        axes[1, 0].axvline(x=10, color='red', linestyle='--', alpha=0.5, label='Seuil 10/20')
        axes[1, 0].legend()
        
        # 4. Corrélation amis vs moyenne
        axes[1, 1].scatter(df['nb_amis'], df['moyenne'], s=100, alpha=0.6)
        for idx, row in df.iterrows():
            axes[1, 1].annotate(row['etudiant'].split()[0], 
                               (row['nb_amis'], row['moyenne']),
                               fontsize=8)
        axes[1, 1].set_xlabel('Nombre d\'amis')
        axes[1, 1].set_ylabel('Moyenne générale')
        axes[1, 1].set_title('Amis vs Performance')
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"✓ Statistiques sauvegardées : {save_path}")
        
        plt.show()
    
    def plot_courses_stats(self, save_path: str = None):
        """Graphique des statistiques cours"""
        df = self.get_courses_stats()
        
        fig, axes = plt.subplots(1, 2, figsize=(14, 5))
        
        # 1. Popularité des cours
        axes[0].barh(df['cours'], df['nb_etudiants'], color='coral')
        axes[0].set_xlabel('Nombre d\'étudiants')
        axes[0].set_title('Popularité des cours')
        axes[0].invert_yaxis()
        
        # 2. Moyennes par cours
        x = range(len(df))
        axes[1].bar(x, df['moyenne'], color='lightblue', label='Moyenne')
        axes[1].errorbar(x, df['moyenne'], 
                        yerr=[df['moyenne']-df['note_min'], df['note_max']-df['moyenne']],
                        fmt='none', color='black', capsize=5, alpha=0.5)
        axes[1].set_xticks(x)
        axes[1].set_xticklabels(df['code'], rotation=45)
        axes[1].set_ylabel('Note')
        axes[1].set_title('Moyennes par cours (avec min/max)')
        axes[1].axhline(y=10, color='red', linestyle='--', alpha=0.5, label='Seuil 10/20')
        axes[1].legend()
        
        plt.tight_layout()
        
        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
            print(f"✓ Statistiques cours sauvegardées : {save_path}")
        
        plt.show()
    
    def generate_report(self):
        """Générer un rapport complet"""
        print("\n" + "="*60)
        print("RAPPORT D'ANALYSE DU GRAPHE SOCIAL".center(60))
        print("="*60 + "\n")
        
        # Statistiques générales
        stats = self.conn.get_stats()
        print("📊 STATISTIQUES GÉNÉRALES")
        print("-" * 60)
        for key, value in stats.items():
            print(f"{key.capitalize():.<40} {value:>3}")
        
        # Étudiants
        print("\n👥 TOP 5 ÉTUDIANTS (par nombre d'amis)")
        print("-" * 60)
        df_students = self.get_students_stats()
        for idx, row in df_students.head(5).iterrows():
            print(f"{row['etudiant']:.<40} {int(row['nb_amis']):>3} amis")
        
        # Cours
        print("\n📚 COURS LES PLUS POPULAIRES")
        print("-" * 60)
        df_courses = self.get_courses_stats()
        for idx, row in df_courses.head(5).iterrows():
            print(f"{row['cours'][:40]:.<40} {int(row['nb_etudiants']):>3} étudiants")
        
        # Recommandations
        print("\n💡 RECOMMANDATIONS")
        print("-" * 60)
        query = """
        MATCH (e1:Etudiant)-[:AMI_AVEC]->()-[:AMI_AVEC]->(e2:Etudiant)
        WHERE NOT (e1)-[:AMI_AVEC]->(e2) AND e1 <> e2
        WITH e1.nom + ' ' + e1.prenom as etudiant,
             e2.nom + ' ' + e2.prenom as recommandation,
             COUNT(*) as amis_communs
        ORDER BY amis_communs DESC
        LIMIT 5
        RETURN etudiant, recommandation, amis_communs
        """
        recommandations = self.conn.query(query)
        for rec in recommandations:
            print(f"{rec['etudiant']:.<25} → {rec['recommandation']:.<25} ({rec['amis_communs']} ami(s) commun(s))")
        
        print("\n" + "="*60 + "\n")


def main():
    """Fonction principale"""
    
    # Configuration
    URI = "bolt://localhost:7687"
    USER = "neo4j"
    PASSWORD = "password123"
    
    # Connexion
    conn = Neo4jConnection(URI, USER, PASSWORD)
    
    if conn.test_connection():
        analyzer = GraphAnalyzer(conn)
        
        # Menu
        print("\n=== Menu d'analyse ===")
        print("1. Rapport texte complet")
        print("2. Graphique réseau d'amitiés")
        print("3. Graphiques statistiques étudiants")
        print("4. Graphiques statistiques cours")
        print("5. Tout générer")
        
        choix = input("\nVotre choix (1/2/3/4/5) : ")
        
        if choix == "1":
            analyzer.generate_report()
        elif choix == "2":
            analyzer.plot_friendship_network("../images/reseau_amities.png")
        elif choix == "3":
            analyzer.plot_students_stats("../images/stats_etudiants.png")
        elif choix == "4":
            analyzer.plot_courses_stats("../images/stats_cours.png")
        elif choix == "5":
            analyzer.generate_report()
            analyzer.plot_friendship_network("../images/reseau_amities.png")
            analyzer.plot_students_stats("../images/stats_etudiants.png")
            analyzer.plot_courses_stats("../images/stats_cours.png")
        else:
            print("Choix invalide")
    
    conn.close()


if __name__ == "__main__":
    main()
