BELDILMI Guillaume et CORBEL Théo

# Systèmes d'Information Répartis : Travaux Pratiques

## Introduction

Le but de ce TP est de mettre en place une base de données répartie sur deux sites distants avec Oracle Database.

Le shéma relationnel de la base de données est le suivant :

- `Personne(numP, nom, prenom, email, sexe, dateNaissance, departementNaissance, dateDeces, departementDeces, pere, mere`;
- `Mariage(epoux, epouse, dateMariage, lieuMariage, dateDivorce`;
- `Geographie(numDepartement, nom, prefecture`.

Pour la fragmentation et l’allocation, les hypothèses sont les suivantes :

- la relation `Geographie` est fragmentée horizontalement selon le numéro de département ;
- la relation `Personne` est fragmentée horizontalement en accord avec `Geographie` selon le département de naissance ;
- la relation `Mariage` n’est pas fragmentée mais elle est dupliquée sur les deux sites ;
- la relation `Personne` est fragmentée verticalement en `Personne1(numP, nom, prenom, email, sexe, dateNaissance, departementNaissance dateDeces, departementDeces)` et `Personne2(numP, mere, pere)`.

## Partie 1 : Communication entre machines

Afin de communiquer entre les machines de chaque site, nous avons mis en place un database link entre les deux bases de données. Cela nous permet de faire des requêtes sur les tables de l'autre site par la désignation du nom de la table distante suivie du nom du database link (ex : `SELECT * FROM table@dblink;`).

## Partie 2 : Structure Oracle assurant la transparence à la fragmentation et la localisation des données

## Partie 3 : Gestion de clés primaires et étrangères

## Partie 4 : Mécanisme de réplication des données

## Partie 5 : Jeu de requêtes

## Conclusion
