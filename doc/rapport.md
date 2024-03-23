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

Pour assurer la transparence à la fragmentation et la localisation des données, nous avons mis en place des vues sur chaque site. Ces vues permettent de masquer la fragmentation et la localisation des données. Ainsi, les utilisateurs peuvent faire des requêtes sur les vues sans se soucier de la fragmentation et de la localisation des données.

Pour la vue `Personne`, nous avons créé une vue `Personne_T` sur le site 1 et une vue `Personne_G` sur le site 2. Ces vues sont définies de la manière suivante depuis le site 1 :

```sql
create view if not exists PERSONNE_T as
select *
from PERSONNE1
join PERSONNE2 on PERSONNE1.numP = PERSONNE2.numP;

create view if not exists PERSONNE as
select * from PERSONNE_G@db_link
union select * from PERSONNE_T;
```

## Partie 3 : Gestion de clés primaires et étrangères

## Partie 4 : Mécanisme de réplication des données

## Partie 5 : Jeu de requêtes

## Conclusion
