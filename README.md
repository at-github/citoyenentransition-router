# Citoyen en transition

## Présentation
Voici le code source du site, celui-ci est aussi une occasion pour jouer avec `ruby`.

## How to

### Démarrer le serveur
```shell
ruby server.rb
```
Par défaut pour l'instant le serveur démarre sur le port `2345` qui est écrit en *dur*, TODO mettre ce port en variable d'environnement.

## Notes techniques d'apprentissage
Lancer un serveur de base
```shell
ruby -run -e httpd -- -p 5000 .
```
