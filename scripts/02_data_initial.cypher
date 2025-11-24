// ============================================
// DONNÉES INITIALES
// Projet: Graphe d'amitié entre étudiants
// Date: 24 novembre 2025
// ============================================

// ============================================
// NETTOYER LA BASE (ATTENTION: Supprime tout!)
// ============================================
// MATCH (n) DETACH DELETE n;

// ============================================
// CRÉER LES ÉTUDIANTS DE VOTRE GROUPE
// ============================================

CREATE (e1:Etudiant {
  id: 1,
  nom: "Rachidi",
  prenom: "Mohamed",
  age: 22,
  filiere: "Informatique",
  niveau: "Master 1",
  ville: "Paris",
  email: "rachidi@univ.fr",
  telephone: "+33 6 12 34 56 78",
  hobbies: ["programmation", "base de données", "sport", "musique"],
  date_inscription: date("2023-09-01")
})

CREATE (e2:Etudiant {
  id: 2,
  nom: "Dupont",
  prenom: "Marie",
  age: 21,
  filiere: "Informatique",
  niveau: "Master 1",
  ville: "Lyon",
  email: "marie.dupont@univ.fr",
  telephone: "+33 6 23 45 67 89",
  hobbies: ["lecture", "programmation", "voyage", "photographie"],
  date_inscription: date("2023-09-01")
})

CREATE (e3:Etudiant {
  id: 3,
  nom: "Ben Ali",
  prenom: "Ahmed",
  age: 23,
  filiere: "Informatique",
  niveau: "Master 1",
  ville: "Paris",
  email: "ahmed.benali@univ.fr",
  telephone: "+33 6 34 56 78 90",
  hobbies: ["sport", "jeux vidéo", "cuisine", "cinéma"],
  date_inscription: date("2023-09-01")
});

// ============================================
// AJOUTER D'AUTRES ÉTUDIANTS POUR ENRICHIR LE GRAPHE
// ============================================

CREATE (e4:Etudiant {
  id: 4,
  nom: "Martin",
  prenom: "Sophie",
  age: 22,
  filiere: "Informatique",
  niveau: "Master 1",
  ville: "Paris",
  email: "sophie.martin@univ.fr",
  telephone: "+33 6 45 67 89 01",
  hobbies: ["danse", "musique", "programmation"],
  date_inscription: date("2023-09-01")
})

CREATE (e5:Etudiant {
  id: 5,
  nom: "Dubois",
  prenom: "Thomas",
  age: 24,
  filiere: "Informatique",
  niveau: "Master 2",
  ville: "Lyon",
  email: "thomas.dubois@univ.fr",
  telephone: "+33 6 56 78 90 12",
  hobbies: ["sport", "escalade", "randonnée"],
  date_inscription: date("2022-09-01")
})

CREATE (e6:Etudiant {
  id: 6,
  nom: "Garcia",
  prenom: "Laura",
  age: 21,
  filiere: "Informatique",
  niveau: "Master 1",
  ville: "Marseille",
  email: "laura.garcia@univ.fr",
  telephone: "+33 6 67 89 01 23",
  hobbies: ["voyage", "photographie", "lecture"],
  date_inscription: date("2023-09-01")
});

// ============================================
// CRÉER LES COURS
// ============================================

CREATE (c1:Cours {
  code: "INFO301",
  nom: "Bases de données avancées",
  credits: 6,
  semestre: "Automne 2025",
  professeur: "Dr. Dupuis",
  salle: "A301"
})

CREATE (c2:Cours {
  code: "INFO302",
  nom: "Intelligence Artificielle",
  credits: 6,
  semestre: "Automne 2025",
  professeur: "Dr. Lambert",
  salle: "B205"
})

CREATE (c3:Cours {
  code: "INFO303",
  nom: "Réseaux et sécurité",
  credits: 4,
  semestre: "Automne 2025",
  professeur: "Dr. Moreau",
  salle: "C102"
})

CREATE (c4:Cours {
  code: "INFO304",
  nom: "Développement Web",
  credits: 5,
  semestre: "Automne 2025",
  professeur: "Dr. Bernard",
  salle: "A210"
})

CREATE (c5:Cours {
  code: "INFO305",
  nom: "Systèmes distribués",
  credits: 6,
  semestre: "Automne 2025",
  professeur: "Dr. Petit",
  salle: "B310"
});

// ============================================
// CRÉER LES VILLES (pour analyses géographiques)
// ============================================

CREATE (v1:Ville {nom: "Paris", code_postal: "75000", region: "Île-de-France"})
CREATE (v2:Ville {nom: "Lyon", code_postal: "69000", region: "Auvergne-Rhône-Alpes"})
CREATE (v3:Ville {nom: "Marseille", code_postal: "13000", region: "Provence-Alpes-Côte d'Azur"});

// ============================================
// RELATIONS : QUI ÉTUDIE QUOI
// ============================================

// Rachidi
MATCH (e:Etudiant {id: 1}), (c:Cours {code: "INFO301"})
CREATE (e)-[:ÉTUDIE {note: 15.5, presence: 95}]->(c);

MATCH (e:Etudiant {id: 1}), (c:Cours {code: "INFO302"})
CREATE (e)-[:ÉTUDIE {note: 16.0, presence: 98}]->(c);

MATCH (e:Etudiant {id: 1}), (c:Cours {code: "INFO305"})
CREATE (e)-[:ÉTUDIE {note: 14.5, presence: 90}]->(c);

// Marie
MATCH (e:Etudiant {id: 2}), (c:Cours {code: "INFO301"})
CREATE (e)-[:ÉTUDIE {note: 17.0, presence: 100}]->(c);

MATCH (e:Etudiant {id: 2}), (c:Cours {code: "INFO303"})
CREATE (e)-[:ÉTUDIE {note: 15.0, presence: 92}]->(c);

MATCH (e:Etudiant {id: 2}), (c:Cours {code: "INFO304"})
CREATE (e)-[:ÉTUDIE {note: 16.5, presence: 96}]->(c);

// Ahmed
MATCH (e:Etudiant {id: 3}), (c:Cours {code: "INFO302"})
CREATE (e)-[:ÉTUDIE {note: 14.0, presence: 88}]->(c);

MATCH (e:Etudiant {id: 3}), (c:Cours {code: "INFO303"})
CREATE (e)-[:ÉTUDIE {note: 15.5, presence: 94}]->(c);

MATCH (e:Etudiant {id: 3}), (c:Cours {code: "INFO305"})
CREATE (e)-[:ÉTUDIE {note: 13.5, presence: 85}]->(c);

// Sophie
MATCH (e:Etudiant {id: 4}), (c:Cours {code: "INFO301"})
CREATE (e)-[:ÉTUDIE {note: 16.0, presence: 97}]->(c);

MATCH (e:Etudiant {id: 4}), (c:Cours {code: "INFO302"})
CREATE (e)-[:ÉTUDIE {note: 15.5, presence: 93}]->(c);

MATCH (e:Etudiant {id: 4}), (c:Cours {code: "INFO304"})
CREATE (e)-[:ÉTUDIE {note: 17.5, presence: 99}]->(c);

// Thomas
MATCH (e:Etudiant {id: 5}), (c:Cours {code: "INFO303"})
CREATE (e)-[:ÉTUDIE {note: 16.0, presence: 91}]->(c);

MATCH (e:Etudiant {id: 5}), (c:Cours {code: "INFO305"})
CREATE (e)-[:ÉTUDIE {note: 17.0, presence: 95}]->(c);

// Laura
MATCH (e:Etudiant {id: 6}), (c:Cours {code: "INFO301"})
CREATE (e)-[:ÉTUDIE {note: 15.0, presence: 89}]->(c);

MATCH (e:Etudiant {id: 6}), (c:Cours {code: "INFO304"})
CREATE (e)-[:ÉTUDIE {note: 16.0, presence: 94}]->(c);

// ============================================
// RELATIONS D'AMITIÉ (bidirectionnelles)
// ============================================

// Rachidi <-> Marie (meilleurs amis)
MATCH (e1:Etudiant {id: 1}), (e2:Etudiant {id: 2})
CREATE (e1)-[:AMI_AVEC {depuis: date("2023-09-01"), force: 9, type: "meilleur ami"}]->(e2)
CREATE (e2)-[:AMI_AVEC {depuis: date("2023-09-01"), force: 9, type: "meilleur ami"}]->(e1);

// Rachidi <-> Ahmed
MATCH (e1:Etudiant {id: 1}), (e3:Etudiant {id: 3})
CREATE (e1)-[:AMI_AVEC {depuis: date("2024-01-15"), force: 7, type: "ami proche"}]->(e3)
CREATE (e3)-[:AMI_AVEC {depuis: date("2024-01-15"), force: 7, type: "ami proche"}]->(e1);

// Marie <-> Ahmed
MATCH (e2:Etudiant {id: 2}), (e3:Etudiant {id: 3})
CREATE (e2)-[:AMI_AVEC {depuis: date("2024-09-01"), force: 6, type: "ami"}]->(e3)
CREATE (e3)-[:AMI_AVEC {depuis: date("2024-09-01"), force: 6, type: "ami"}]->(e2);

// Rachidi <-> Sophie
MATCH (e1:Etudiant {id: 1}), (e4:Etudiant {id: 4})
CREATE (e1)-[:AMI_AVEC {depuis: date("2023-10-20"), force: 8, type: "ami proche"}]->(e4)
CREATE (e4)-[:AMI_AVEC {depuis: date("2023-10-20"), force: 8, type: "ami proche"}]->(e1);

// Sophie <-> Marie
MATCH (e4:Etudiant {id: 4}), (e2:Etudiant {id: 2})
CREATE (e4)-[:AMI_AVEC {depuis: date("2023-11-05"), force: 7, type: "ami proche"}]->(e2)
CREATE (e2)-[:AMI_AVEC {depuis: date("2023-11-05"), force: 7, type: "ami proche"}]->(e4);

// Ahmed <-> Thomas
MATCH (e3:Etudiant {id: 3}), (e5:Etudiant {id: 5})
CREATE (e3)-[:AMI_AVEC {depuis: date("2024-02-10"), force: 5, type: "connaissance"}]->(e5)
CREATE (e5)-[:AMI_AVEC {depuis: date("2024-02-10"), force: 5, type: "connaissance"}]->(e3);

// Marie <-> Laura
MATCH (e2:Etudiant {id: 2}), (e6:Etudiant {id: 6})
CREATE (e2)-[:AMI_AVEC {depuis: date("2024-03-15"), force: 6, type: "ami"}]->(e6)
CREATE (e6)-[:AMI_AVEC {depuis: date("2024-03-15"), force: 6, type: "ami"}]->(e2);

// Sophie <-> Laura
MATCH (e4:Etudiant {id: 4}), (e6:Etudiant {id: 6})
CREATE (e4)-[:AMI_AVEC {depuis: date("2024-04-20"), force: 7, type: "ami proche"}]->(e6)
CREATE (e6)-[:AMI_AVEC {depuis: date("2024-04-20"), force: 7, type: "ami proche"}]->(e4);

// ============================================
// RELATIONS : ÉTUDIANT -> VILLE
// ============================================

MATCH (e:Etudiant {ville: "Paris"}), (v:Ville {nom: "Paris"})
CREATE (e)-[:VIT_À]->(v);

MATCH (e:Etudiant {ville: "Lyon"}), (v:Ville {nom: "Lyon"})
CREATE (e)-[:VIT_À]->(v);

MATCH (e:Etudiant {ville: "Marseille"}), (v:Ville {nom: "Marseille"})
CREATE (e)-[:VIT_À]->(v);

// ============================================
// VÉRIFICATION
// ============================================

// Compter les nœuds créés
MATCH (n) RETURN labels(n) as Type, COUNT(*) as Nombre;

// Compter les relations créées
MATCH ()-[r]->() RETURN type(r) as TypeRelation, COUNT(*) as Nombre;
