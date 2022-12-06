# Citoyen en transition

## Présentation
Voici le code source du site https://citoyenentransition.fr,
celui-ci est aussi une occasion pour jouer avec `ruby`.

## How to

### Configurer

#### Application
Le fichier `config.yml` doit être créer à la racine du projet.
Parmis les clés indispensables, il y a :
- `port` : qui détermine sur quel port est lancé l'application
- `cotent_folder` : qui est le chemin à partir du dossier `content` du projet,
où l'application va chercher le contenu *markdown*.
- `title` : Qui sera en tant que *title* et *h1* de l'application

##### Facultatif

###### Traductions
La clé `translations` permet de fournir une traduction des sous-dossiers de votre dossier de contenus,
exemple :
```yaml
translations:
  posts: articles
```
Si vous avez cette arborescence :
```
* content/
\_ * mon_contenu/
   \_ * posts/
      \_ premier_article.md
   \_ * no_translation/
      \_ second_post.md
```
vous aurez les urls suivantes
- `/articles/premier-article`
- `/no_translation/second-post`
(le dernier slug est déterminé d'après le premier `h1` trouver dans le markdown)

###### Liens dans le footer
2 liens sont disponibles, un lien github et twitter.
Voici un exemple dans la configuration :
```yaml
footer:
  github:
    url: https://github.com/at-github/citoyenentransition-router
    title: Contribuez, retrouvez le code source sur github
  twitter:
    url: https://twitter.com/_en_transition_
    title: Retrouvons nous aussi sur twitter
```

#### Contenu

Le contenu *markdown* est à télécharger voire cloner dans le dossier `content`
(inclut dans `.gitignore`).

0. sur toutes les pages, le contenu du fichiers `links.md` est affiché en colonne
1. sur `/` l'application affichera le résumé de tous les dossiers
2. sur `/articles` l'application affichera le résumé de dossier `post` puisqu'elle a trouvé une traduction dans la configuration (voir plus haut)
3. sur `/no_translation` l'application affichera le résumé de dossier `no_translation`

/!\ Le nom du fichier doit être le même que son h1,
les 2 sans accents pour l’instant.

### Installer
```
bundle install
```

### Démarrer le serveur

```shell
bundle exec daemon.rb start
```
Par défaut le serveur démarre sur le port `4000`,
il est modifiable dans le fichier de configuration `config.yml`.

## Notes techniques d'apprentissage

Lancer un serveur de base
```shell
ruby -run -e httpd -- -p 5000 .
```

Configurer `bundle` pour installer les `gems` localement
```
bundle config path "vendor/bundle"
```
