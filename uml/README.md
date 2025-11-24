# Génération du diagramme UML

## Installation de PlantUML

### Sur Debian/Ubuntu
```bash
sudo apt-get install plantuml
```

### Avec Java
```bash
# Télécharger plantuml.jar
wget https://sourceforge.net/projects/plantuml/files/plantuml.jar/download -O plantuml.jar

# Utiliser
java -jar plantuml.jar modele_donnees.puml
```

## Générer le diagramme

```bash
# PNG
plantuml modele_donnees.puml

# SVG (vectoriel)
plantuml -tsvg modele_donnees.puml

# PDF
plantuml -tpdf modele_donnees.puml
```

## Visualisation en ligne

Vous pouvez aussi copier le contenu de `modele_donnees.puml` sur :
- https://www.plantuml.com/plantuml/uml/
- https://plantuml-editor.kkeisuke.com/

## Alternative : Visual Studio Code

Installer l'extension PlantUML dans VS Code :
```
code --install-extension jebbs.plantuml
```

Puis ouvrir le fichier .puml et appuyer sur `Alt+D` pour prévisualiser.
