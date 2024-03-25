BELDILMI Guillaume et CORBEL Théo

# Systèmes d'Information Répartis : Travaux Pratiques

## Introduction

Le but de ce TP est de mettre en place une base de données répartie sur deux sites distants avec Oracle Database.

Le shéma relationnel de la base de données est le suivant :

- `PERSONNE(numP, nom, prenom, email, sexe, dateNaissance, departementNaissance, dateDeces, departementDeces, pere, mere`;
- `MARIAGE(epoux, epouse, dateMariage, lieuMariage, dateDivorce`;
- `GEOGRAPHIE(numDepartement, nom, prefecture`.

Pour la fragmentation et l’allocation, les hypothèses sont les suivantes :

- la relation `GEOGRAPHIE` est fragmentée horizontalement selon le numéro de département ;
- la relation `PERSONNE` est fragmentée horizontalement en accord avec `GEOGRAPHIE` selon le département de naissance ;
- la relation `MARIAGE` n’est pas fragmentée mais elle est dupliquée sur les deux sites ;
- la relation `PERSONNE` est fragmentée verticalement en `PERSONNE1(numP, nom, prenom, email, sexe, dateNaissance, departementNaissance dateDeces, departementDeces)` et `PERSONNE2(numP, mere, pere)`.

Nous avons fait le choix de répartir les informations en fonction des départements de naissance des personnes : Théo gère les départements pairs et Guillaume les impairs. 

## Partie 1 : Communication entre machines

Afin de communiquer entre les machines de chaque site, nous avons mis en place un database link entre les deux bases de données. Cela nous permet de faire des requêtes sur les tables de l'autre site par la désignation du nom de la table distante suivie du nom du database link (ex : `SELECT * FROM table@dblink;`). Ici notre database link se nomme *tp_sir*.

Ce dernier est utilisé dans deux situations :
- pour la création de vues matérialisées (voir partie 3)
- pour l'insertion, la mise à jour et la suppresion de données sur un site distant depuis le site local

Les création des utilisateurs et des database link sont fournis en annexe 1.

## Partie 2 : Structure Oracle assurant la transparence à la fragmentation et la localisation des données

Pour assurer la transparence à la fragmentation et la localisation des données, nous avons mis en place des vues sur chaque site. Ces vues permettent de masquer la fragmentation et la localisation des données. Ainsi, les utilisateurs peuvent faire des requêtes sur les vues comme s'il s'agissait de tables locales. La plupart de ces vues rassemblent les données locales et distantes. Nous utilisons des vues matérialisées, qui sont mises à jour à la demande à partir de la base distante.

Pour la vue PERSONNE, nous avons créé une vue PERSONNE_T sur le site 1 et une vue PERSONNE_G sur le site 2. Ces vues sont contiutées des données de PERSONNE1 et PERSONNE2. On crée également sur chaque site une vue matérialisée correpondant à la vue PERSONNE_X de l'autre site (on crée donc PERSONNE_G sur le site 1 et Perosnne_T sur le site 2). Ces vues matérialisées serviront à la création de la vue PERSONNE sur chaque site. Cette vue répertorie donc toutes les informations des toutes les personnes sur les deux sites, et permet de faire simplement des requêtes.

Selon le même principe on crée la vue GEOGRAPHIE qui réunit les vues GEOGRAPHIE_T et GEOGRAPHIE_G, grâce encore une fois à des vues matérialisées.

Comme dit dans l'introduction, nous avons choisi de séparer les données entre les départements pairs et impairs. Cela crée un genre de fragmentation horizontale sur PERSONNE1, PERSONNE2 et GEOGRAPHIE qui n'en est pas réelement une, puisque la table n'est pas déclarée comme fragmentée à la création. On s'assure de la bonne répartition des données grâce à des triggers qui avant toute insertion dans les tables PERSONNE1, PERSONNE2 ou GEOGRAPHIE vérifient le numéro du département afin de savoir si la requête doit être exécutée en local ou sur la base de données , distante.

La création des tables ainsi que des vues est fournie en annexes 2 et 3.
La création des triggers de distribution des données est fournie en annexes 4 et 5.

## Partie 3 : Gestion de clés primaires et étrangères

Grâce à notre vue globale PERSONNE, présente sur chaque site, la gestion des clés primaires et étrangères est grandement simplifiée pour ce qui est de la table MARIAGE. Les clés étrangères font directement référence aux champs de la vue.

Personne1 et Personne2 ont cependant posé problème. D'après nos recherches il semble qu'Oracle ne fournisse aucun moyen de réaliser une fragmentation verticale. Nous avons donc créé deux tables séparées, et avons choisi de faire de PERSONNE1.numP une référence à PERSONNE2.numP et inversement.

## Partie 4 : Mécanisme de réplication des données

Comme indiqué précedemment, nous avons choisi d'utiliser des vues matérialisées pour assurer la réplication des données. Ces vues sont asynchrones et se mettent donc à jour sur demande. Nous avons choisi ce mode de rafraichissement car il était le plus simple à mettre en oeuvre. Nous avions hésité à utiliser le FAST REFRESH, mais nous sommes ravisé après avoir fait de recherches. Cela semblait bien trop complexe.

Ces vues matérialisées sont au coeur de notre architecture : grâce à elles, et en les combinant avec les données locales, ont peu créer des vues globales qui rassemblent les données des deux sites et facilitent grandement les requêtes de sélection de données.

## Partie 5 : Jeu de requêtes

Nos requêtes couvrent un grand nombre possible d'utilisations de la base de données, de la recherche d'une personne en particulier jusqu'à l'affichage de toutes les personnes nées une certaine année, en passant par le nombre de divorces ou de mariages par région.

Notre jeu de requêtes est disponible en annexe 8.

## Conclusion
Avec du recul notre choix de séparer les données selon, le département n'était peut-être pas le meilleur, mais nous ne nous en somme apperçu qu'assez tard et avons choisi de poursuivre dans cette voie pour ne pas perdre de temps. Une réparrtition plus efficace aurait pu être de séparer PERSONNE1 et PERSONNE2 sur un site chacun.

Nous avonc eu quelques problèmes en raison des difficultés d'accès aux machines donc nous n'avons pas pu effectuer certains tests. Nous pensons cependant que notre architecture est logique.

## Annexes
**Annexe 1 : Création des utilisateurs et du database link**
'''sql
create user theo identified by theo quota 10G on users;
grant connect to theo;
grant resource to theo;
grant create view, create synonym, create materialized view to theo;

create public database link tp_sir connect to theo identified by theo using alias "theo";

create user guillaume identified by guillaume quota 10G on users;
grant connect to guillaume;
grant resource to guillaume;
grant create view, create synonym, create materialized view to guillaume;

create public database link tp_sir connect to guillaume identified by guillaume using alias "guillaume";
'''

**Annexe 2 : création des tables - côté Théo**
'''sql
/* GEOGRAPHIE (
  numDepartement,
  nom,
  prefecture
) */
create table GEOGRAPHIE_T (
  numDepartement integer primary key,
  nom varchar2(255) not null,
  prefecture varchar2(255) not null
);
/* GEOGRAPHIE_G */
create materialized view GEOGRAPHIE_G
refresh on demand
  as select * from GEOGRAPHIE_G@tp_sir;

/* GEOGRAPHIE = GEOGRAPHIE_T union GEOGRAPHIE_G */
create view GEOGRAPHIE as
  select * from GEOGRAPHIE_T
  union select * from GEOGRAPHIE_G;


/* PERSONNE1 (
  numP,
  nom,
  prenom,
  email,
  sexe,
  dateNaissance,
  departementNaissance,
  dateDeces,
  departementDeces
) */
create table PERSONNE1 (
  numP integer primary key  references PERSONNE2(numP) on delete cascade,
  nom varchar2(255) not null,
  prenom varchar2(255) not null,
  email varchar2(255) not null,
  sexe varchar2(1) not null,
  dateNaissance date not null,
  departementNaissance varchar2(255) not null,
  dateDeces date,
  departementDeces varchar2(255)
); -- */
/* PERSONNE2 (
  numP,
  mere,
  pere
) */
create table PERSONNE2 (
  numP integer primary key  references PERSONNE1(numP) on delete cascade,
  mere,   references PERSONNE1(numP),
  pere  references PERSONNE1(numP)
); -- */
/* PERSONNE_T = PERSONNE1 join PERSONNE2 */
create view PERSONNE_T as
  select * from PERSONNE1 inner join PERSONNE2 on PERSONNE1.numP = PERSONNE2.numP;
/* PERSONNE_G */
create materialized view PERSONNE_G 
refresh on demand
  as select * from PERSONNE_G@tp_sir;
/* PERSONNE = PERSONNE_T union PERSONNE_G */
create view PERSONNE as
  select * from PERSONNE_T
  union select * from PERSONNE_G;


/* MARIAGE (
  epoux,
  epouse,
  dateMariage,
  lieuMariage,
  dateDivorce
) */
create table MARIAGE_T (
  epoux integer not null,  references PERSONNE(numP),
  epouse integer null,   references PERSONNE(numP),
  dateMariage date not null,
  lieuMariage varchar2(255) not null,
  dateDivorce date,
  primary key (epoux, epouse, dateMariage)
); -- */
/* MARIAGE = synomym MARIAGE_T */
create synonym MARIAGE for MARIAGE_T;
'''

**Annexe 3 : création des tables - côté Guillaume**
'''sql
/* GEOGRAPHIE (
  numDepartement,
  nom,
  prefecture
) */
create table GEOGRAPHIE_G (
  numDepartement integer primary key,
  nom varchar2(255) not null,
  prefecture varchar2(255) not null
);
/* GEOGRAPHIE_T */
create materialized view GEOGRAPHIE_T
refresh on demand
  as select * from GEOGRAPHIE_T@tp_sir;

/* GEOGRAPHIE = GEOGRAPHIE_G union GEOGRAPHIE_T */
create view GEOGRAPHIE as
  select * from GEOGRAPHIE_G
  union select * from GEOGRAPHIE_T;


/* PERSONNE1 (
  numP,
  nom,
  prenom,
  email,
  sexe,
  dateNaissance,
  departementNaissance,
  dateDeces,
  departementDeces
) */
create table PERSONNE1 (
  numP integer primary key  references PERSONNE2(numP) on delete cascade,
  nom varchar2(255) not null,
  prenom varchar2(255) not null,
  email varchar2(255) not null,
  sexe varchar2(1) not null,
  dateNaissance date not null,
  departementNaissance varchar2(255) not null,
  dateDeces date,
  departementDeces varchar2(255)
); -- */
/* PERSONNE2 (
  numP,
  mere,
  pere
) */
create table PERSONNE2 (
  numP integer primary key  references PERSONNE1(numP) on delete cascade,
  mere,   references PERSONNE1(numP),
  pere  references PERSONNE1(numP)
); -- */
/* PERSONNE_G = PERSONNE1 join PERSONNE2 */
create view PERSONNE_G as
  select * from PERSONNE1 inner join PERSONNE2 on PERSONNE1.numP = PERSONNE2.numP;
/* PERSONNE_T */
create materialized view PERSONNE_T 
refresh on demand
  as select * from PERSONNE_T@tp_sir;
/* PERSONNE = PERSONNE_G union PERSONNE_T */
create view PERSONNE as
  select * from PERSONNE_G
  union select * from PERSONNE_T;


/* MARIAGE (
  epoux,
  epouse,
  dateMariage,
  lieuMariage,
  dateDivorce
) */
create table MARIAGE_G (
  epoux integer not null,  references PERSONNE(numP),
  epouse integer null,   references PERSONNE(numP),
  dateMariage date not null,
  lieuMariage varchar2(255) not null,
  dateDivorce date,
  primary key (epoux, epouse, dateMariage)
); -- */
/* MARIAGE = synomym MARIAGE_G */
create synonym MARIAGE for MARIAGE_G;
'''

**Annexe 4 : triggers de distribution des données - côté Théo**
'''sql
CREATE OR REPLACE TRIGGER check_site_insert_personne1
INSTEAD OF INSERT ON personne
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne1@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne1@tp_sir VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne1 VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_update_personne1
INSTEAD OF UPDATE ON personne1
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        UPDATE personne1@tp_sir SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne1@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        UPDATE personne1 SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_delete_personne1
INSTEAD OF DELETE ON personne1
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne1@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_insert_personne2
INSTEAD OF INSERT ON personne2
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne2@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne2@tp_sir VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne2 VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_update_personne2
INSTEAD OF UPDATE ON personne2
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        UPDATE personne2@tp_sir SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne2@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        UPDATE personne2 SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_delete_personne2
INSTEAD OF DELETE ON personne2
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne2@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
    END IF;
END;

CREATE OR REPLACE TRIGGER check_mariage_insert
BEFORE INSERT ON mariage
FOR EACH ROW
BEGIN
    INSERT INTO mariage@tp_sir VALUES (:new.numP1, :new.numP2, :new.dateMariage, :new.lieuMariage);
END;

CREATE OR REPLACE TRIGGER check_mariage_update
BEFORE UPDATE ON mariage
FOR EACH ROW
BEGIN
    UPDATE mariage@tp_sir SET numP1 = :new.numP1, numP2 = :new.numP2, dateMariage = :new.dateMariage, lieuMariage = :new.lieuMariage WHERE numP1 = :old.numP1 AND numP2 = :old.numP2;
END;

CREATE OR REPLACE TRIGGER check_mariage_delete
BEFORE DELETE ON mariage
FOR EACH ROW
BEGIN
    DELETE FROM mariage@tp_sir WHERE numP1 = :old.numP1 AND numP2 = :old.numP2;
END;

CREATE OR REPLACE TRIGGER check_geographie_insert
BEFORE INSERT ON geographie
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        INSERT INTO geographie@tp_sir VALUES (:new.numDepartement, :new.nomDepartement, :new.nomRegion, :new.nomPays);
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        INSERT INTO geographie VALUES (:new.numDepartement, :new.nomDepartement, :new.nomRegion, :new.nomPays);
    END IF;
END;

CREATE OR REPLACE TRIGGER check_geographie_update
BEFORE UPDATE ON geographie
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        UPDATE geographie@tp_sir SET numDepartement = :new.numDepartement, nomDepartement = :new.nomDepartement, nomRegion = :new.nomRegion, nomPays = :new.nomPays WHERE numDepartement = :old.numDepartement;
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        UPDATE geographie SET numDepartement = :new.numDepartement, nomDepartement = :new.nomDepartement, nomRegion = :new.nomRegion, nomPays = :new.nomPays WHERE numDepartement = :old.numDepartement;
    END IF;
END;

CREATE OR REPLACE TRIGGER check_geographie_delete
BEFORE DELETE ON geographie
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM geographie@tp_sirs WHERE numDepartement = :old.numDepartement;
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM geographie WHERE numDepartement = :old.numDepartement;
    END IF;
END;

--on répercute les modifications de la table mariage sur la base distante
create or replace trigger update_mariage
before insert or update on mariage
for each row
begin 
    insert into mariage@tp_sir values(:new.numP1, :new.numP2, :new.dateMariage, :new.lieuMariage, :new.dateDivorce, :new.lieuDivorce);
end;
'''

**Annexe 5 : triggers de distribution des données - côté Guillaume**
'''sql
CREATE OR REPLACE TRIGGER check_site_insert_personne1
INSTEAD OF INSERT ON personne
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne1@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne1@tp_sir VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne1 VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_update_personne1
INSTEAD OF UPDATE ON personne1
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        UPDATE personne1@tp_sir SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne1@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        UPDATE personne1 SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_delete_personne1
INSTEAD OF DELETE ON personne1
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne1@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_insert_personne2
INSTEAD OF INSERT ON personne2
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, on effectue la requête sur la base de données distante
        DELETE FROM personne2@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne2@tp_sir VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    ELSE
        -- Si le numéro de département est impair, on effectue la requête en local
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne2 VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_update_personne2
INSTEAD OF UPDATE ON personne2
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
                IF :old.numDepartement MOD 2 != 0 THEN
                    -- Si le numéro de département est impair, on effectue la requête sur la base de données distante
                    DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
                    UPDATE personne2@tp_sir SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
                ELSE
                    -- Si le numéro de département est pair, on effectue la requête en local
                    DELETE FROM personne2@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
                    UPDATE personne2 SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
                END IF;
        END;

CREATE OR REPLACE TRIGGER check_site_delete_personne2
INSTEAD OF DELETE ON personne2
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 != 0 THEN
        -- Si le numéro de département est impair, on effectue la requête sur la base de données distante
        DELETE FROM personne2@tp_sir WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
    ELSE
        -- Si le numéro de département est pair, on effectue la requête en local
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
    END IF;
END;

CREATE OR REPLACE TRIGGER check_geographie_insert
BEFORE INSERT ON geographie
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 != 0 THEN
        -- Si le numéro de département est impair, on effectue la requête sur la base de données distante
        INSERT INTO geographie@tp_sir VALUES (:new.numDepartement, :new.nomDepartement, :new.nomRegion, :new.nomPays);
    ELSE
        -- Si le numéro de département est pair, on effectue la requête en local
        INSERT INTO geographie VALUES (:new.numDepartement, :new.nomDepartement, :new.nomRegion, :new.nomPays);
    END IF;
END;

CREATE OR REPLACE TRIGGER check_geographie_update
BEFORE UPDATE ON geographie
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 != 0 THEN
        -- Si le numéro de département est impair, on effectue la requête sur la base de données distante
        UPDATE geographie@tp_sir SET numDepartement = :new.numDepartement, nomDepartement = :new.nomDepartement, nomRegion = :new.nomRegion, nomPays = :new.nomPays WHERE numDepartement = :old.numDepartement;
    ELSE
        -- Si le numéro de département est pair, on effectue la requête en local
        UPDATE geographie SET numDepartement = :new.numDepartement, nomDepartement = :new.nomDepartement, nomRegion = :new.nomRegion, nomPays = :new.nomPays WHERE numDepartement = :old.numDepartement;
    END IF;
END;

CREATE OR REPLACE TRIGGER check_geographie_delete
BEFORE DELETE ON geographie
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 != 0 THEN
        -- Si le numéro de département est impair, on effectue la requête sur la base de données distante
        DELETE FROM geographie@tp_sir WHERE numDepartement = :old.numDepartement;
    ELSE
        -- Si le numéro de département est pair, on effectue la requête en local
        DELETE FROM geographie WHERE numDepartement = :old.numDepartement;
    END IF;
END;

--on répercute les modifications de la table mariage sur la base distante
create or replace trigger update_mariage
before insert or update on mariage
for each row
begin 
    insert into mariage@tp_sir values(:new.numP1, :new.numP2, :new.dateMariage, :new.lieuMariage, :new.dateDivorce, :new.lieuDivorce);
end;
'''

**Annexe 6 : triggers de vérification des données**
'''sql
/*Vérifications des marriages*/
/*-----------------------------------*/
create or replace trigger check_deces
before insert or update on MARIAGE
for each row
begin
    SELECT dateDeces INTO decesEpoux FROM PERSONNE WHERE numP = :new.epoux;
    SELECT dateDeces INTO decesEpouse FROM PERSONNE WHERE numP = :new.epouse;
    IF decesEpoux IS NOT NULL OR decesEpouse IS NOT NULL THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un mariage si un des époux est décédé');
    END IF;
end;


create or replace trigger check_majeur
before insert or update on MARIAGE
for each row
begin
    SELECT new:datemariage - dateNaissance INTO ageEpoux FROM PERSONNE WHERE numP = :new.epoux;
    SELECT new:datemariage - dateNaissance INTO ageEpouse FROM PERSONNE WHERE numPe = :new.epouse;
    IF ageEpoux < 18 OR ageEpouse < 18 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un mariage si un des époux est mineur');
    END IF;
end;

create or replace trigger check_meme_personne
before insert or update on MARIAGE
for each row
begin
    IF :new.epoux = :new.epouse THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un mariage entre une personne et elle-même');
    END IF;
end;

create or replace trigger check_inceste
before insert or update on MARIAGE
for each row
begin
    SELECT pere FROM PERSONNE WHERE numP = :new.epoux INTO pereEpoux;
    SELECT pere FROM PERSONNE WHERE numP = :new.epouse INTO pereEpouse;
    SELECT mere FROM PERSONNE WHERE numP = :new.epoux INTO mereEpoux;
    SELECT mere FROM PERSONNE WHERE numP = :new.epouse INTO mereEpouse;
    IF pereEpoux = pereEpouse OR mereEpoux = mereEpouse OR new.epoux = pereEpouse OR new.epouse = mereEpoux THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un mariage entre des personnes de la même famille');
    END IF;
end;


create or replace trigger check_date_mariage
before insert or update on MARIAGE
for each row
begin
    IF :new.dateMariage > new.dateDivorce THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un mariage après un divorce');
    END IF;
end;

create or replace trigger check_nouveau_mariage
before insert or update on MARIAGE
for each row
begin
    SELECT dateMariage, dateDivorce, epouse INTO mariageEpoux FROM MARIAGE WHERE epoux = :new.epoux;
    SELECT dateMariagen, dateDivorce, epoux INTO mariageEpouse FROM MARIAGE WHERE epouse = :new.epouse;
    FOREACH mariage IN mariageEpoux LOOP
        SELECT dateDeces INTO decesEpouse FROM PERSONNE WHERE numP = mariage.epouse;
        IF mariage.dateDivorce IS NULL AND decesEpouse IS NULL THEN
            RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un mariage si un des époux est déjà marié');
        END IF;
    END LOOP;
    FOREACH mariage IN mariageEpouse LOOP
        SELECT dateDeces INTO decesEpoux FROM PERSONNE WHERE numP = mariage.epoux;
        IF mariage.dateDivorce IS NULL AND decesEpoux IS NULL THEN
            RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un mariage si un des époux est déjà marié');
        END IF;         
    END LOOP;
end;

create or replace trigger check_meme_sexe
before insert or update on MARIAGE
for each row
begin
    SELECT sexe INTO sexeEpoux FROM PERSONNE WHERE numP = :new.epoux;
    SELECT sexe INTO sexeEpouse FROM PERSONNE WHERE numP = :new.epouse;
    IF sexeEpoux = sexeEpouse THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un mariage entre personnes du même sexe');
    END IF;
end;

/*-----------------------------------*/
/*Vérifications des personnes*/
/*-----------------------------------*/
create or replace trigger check_departement_personne1
before insert or update on PERSONNE1
for each row
begin
    SELECT departementNaissance INTO departementNaissance FROM PERSONNE1 WHERE numP = :new.numP;
    SELECT departementDeces INTO departementDeces FROM PERSONNE1 WHERE numP = :new.numP;
    SELECT numDepartement INTO numDepartements FROM GEOGRAPHIE;
    IF departementNaissance NOT IN numDepartements OR departementDeces NOT IN numDepartements THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec un département non existant');
    END IF;
end;

create or replace trigger check_dates
before insert or update on PERSONNE1
for each row
begin
    SELECT dateNaissance INTO dateNaissance FROM PERSONNE1 WHERE numP = :new.numP;
    SELECT dateDeces INTO dateDeces FROM PERSONNE1 WHERE numP = :new.numP;
    IF dateNaissance > dateDeces OR dateNaissance > SYSDATE OR dateDeces > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec une date de naissance ou de décès invalide');
    END IF;
end;

create or replace trigger check_parents 
before insert or update on PERSONNE2
for each row
begin
    SELECT pere INTO pere FROM PERSONNE2 WHERE numP = :new.numP;
    SELECT mere INTO mere FROM PERSONNE2 WHERE numP = :new.numP;
    SELECT numP INTO personnes FROM PERSONNE2;
    IF pere NOT IN personnes OR mere NOT IN personnes OR pere = mere OR pere = :new.numP OR mere = :new.numP OR pere is null OR mere is null THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec des parents invalides');
    END IF;
end;

create or replace trigger check_sexe_parents
before insert or update on PERSONNE2
for each row
begin
    SELECT pere INTO pere FROM PERSONNE2 WHERE numP = :new.numP;
    SELECT mere INTO mere FROM PERSONNE2 WHERE numP = :new.numP;
    SELECT sexe INTO sexePere FROM PERSONNE1 WHERE numP = pere;
    SELECT sexe INTO sexeMere FROM PERSONNE1 WHERE numP = mere;
    IF sexePere = 'F' OR sexeMere = 'F' THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec des parents de sexe invalide');
    END IF;
end;

create or replace trigger check_email
before insert or update on PERSONNE1
for each row
begin
    SELECT email INTO email FROM PERSONNE1 WHERE numP = :new.numP;
    IF email NOT LIKE '%@%' THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec un email invalide');
    END IF;
end;

create or replace trigger check_sexe
before insert or update on PERSONNE1
for each row
begin
    SELECT sexe INTO sexe FROM PERSONNE1 WHERE numP = :new.numP;
    IF sexe != 'M' OR sexe != 'F' THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec un sexe invalide');
    END IF;
end;



/*-----------------------------------*/
/*Vérifications de la géographie*/
/*-----------------------------------*/
create or replace trigger check_departement
before insert or update on GEOGRAPHIE
for each row
begin
    IF new:numDepartement < 1 OR new:numDepartement > 101 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer un département avec un numéro invalide');
    END IF;
end;


'''

**Annexe 7 : remplissage des tables**
'''sql
--Remplissage de Geographie--
BEGIN
    INSERT INTO geographie VALUES (1, 'Ain', 'Bourg-en-Bresse');
    INSERT INTO geographie VALUES (2, 'Aisne', 'Laon');
    INSERT INTO geographie VALUES (3, 'Allier', 'Moulins');
    INSERT INTO geographie VALUES (4, 'Alpes-de-Haute-Provence', 'Digne-les-Bains');
    INSERT INTO geographie VALUES (5, 'Hautes-Alpes', 'Gap');
    INSERT INTO geographie VALUES (6, 'Alpes-Maritimes', 'Nice');
    INSERT INTO geographie VALUES (7, 'Ardèche', 'Privas');
    INSERT INTO geographie VALUES (8, 'Ardennes', 'Charleville-Mézières');
    INSERT INTO geographie VALUES (9, 'Ariège', 'Foix');
    INSERT INTO geographie VALUES (10, 'Aube', 'Troyes');
    INSERT INTO geographie VALUES (11, 'Aude', 'Carcassonne');
    INSERT INTO geographie VALUES (12, 'Aveyron', 'Rodez');
    INSERT INTO geographie VALUES (13, 'Bouches-du-Rhône', 'Marseille');
    INSERT INTO geographie VALUES (14, 'Calvados', 'Caen');
    INSERT INTO geographie VALUES (15, 'Cantal', 'Aurillac');
    INSERT INTO geographie VALUES (16, 'Charente', 'Angoulême');
    INSERT INTO geographie VALUES (17, 'Charente-Maritime', 'La Rochelle');
    INSERT INTO geographie VALUES (18, 'Cher', 'Bourges');
    INSERT INTO geographie VALUES (19, 'Corrèze', 'Tulle');
    INSERT INTO geographie VALUES (20, 'Corse', 'Ajaccio');
    INSERT INTO geographie VALUES (21, 'Côte-d''Or', 'Dijon');
    INSERT INTO geographie VALUES (22, 'Côtes-d''Armor', 'Saint-Brieuc');
    INSERT INTO geographie VALUES (23, 'Creuse', 'Guéret');
    INSERT INTO geographie VALUES (24, 'Dordogne', 'Périgueux');
    INSERT INTO geographie VALUES (25, 'Doubs', 'Besançon');
    INSERT INTO geographie VALUES (26, 'Drôme', 'Valence');
    INSERT INTO geographie VALUES (27, 'Eure', 'Évreux');
    INSERT INTO geographie VALUES (28, 'Eure-et-Loir', 'Chartres');
    INSERT INTO geographie VALUES (29, 'Finistère', 'Quimper');
    INSERT INTO geographie VALUES (30, 'Gard', 'Nîmes');
    INSERT INTO geographie VALUES (31, 'Haute-Garonne', 'Toulouse');
    INSERT INTO geographie VALUES (32, 'Gers', 'Auch');
    INSERT INTO geographie VALUES (33, 'Gironde', 'Bordeaux');
    INSERT INTO geographie VALUES (34, 'Hérault', 'Montpellier');
    INSERT INTO geographie VALUES (35, 'Ille-et-Vilaine', 'Rennes');
    INSERT INTO geographie VALUES (36, 'Indre', 'Châteauroux');
    INSERT INTO geographie VALUES (37, 'Indre-et-Loire', 'Tours');
    INSERT INTO geographie VALUES (38, 'Isère', 'Grenoble');
    INSERT INTO geographie VALUES (39, 'Jura', 'Lons-le-Saunier');
    INSERT INTO geographie VALUES (40, 'Landes', 'Mont-de-Marsan');
    INSERT INTO geographie VALUES (41, 'Loir-et-Cher', 'Blois');
    INSERT INTO geographie VALUES (42, 'Loire', 'Saint-Étienne');
    INSERT INTO geographie VALUES (43, 'Haute-Loire', 'Le Puy-en-Velay');
    INSERT INTO geographie VALUES (44, 'Loire-Atlantique', 'Nantes');
    INSERT INTO geographie VALUES (45, 'Loiret', 'Orléans');
    INSERT INTO geographie VALUES (46, 'Lot', 'Cahors');
    INSERT INTO geographie VALUES (47, 'Lot-et-Garonne', 'Agen');
    INSERT INTO geographie VALUES (48, 'Lozère', 'Mende');
    INSERT INTO geographie VALUES (49, 'Maine-et-Loire', 'Angers');
    INSERT INTO geographie VALUES (50, 'Manche', 'Saint-Lô');
    INSERT INTO geographie VALUES (51, 'Marne', 'Châlons-en-Champagne');
    INSERT INTO geographie VALUES (52, 'Haute-Marne', 'Chaumont');
    INSERT INTO geographie VALUES (53, 'Mayenne', 'Laval');
    INSERT INTO geographie VALUES (54, 'Meurthe-et-Moselle', 'Nancy');
    INSERT INTO geographie VALUES (55, 'Meuse', 'Bar-le-Duc');
    INSERT INTO geographie VALUES (56, 'Morbihan', 'Vannes');
    INSERT INTO geographie VALUES (57, 'Moselle', 'Metz');
    INSERT INTO geographie VALUES (58, 'Nièvre', 'Nevers');
    INSERT INTO geographie VALUES (59, 'Nord', 'Lille');
    INSERT INTO geographie VALUES (60, 'Oise', 'Beauvais');
    INSERT INTO geographie VALUES (61, 'Orne', 'Alençon');
    INSERT INTO geographie VALUES (62, 'Pas-de-Calais', 'Arras');
    INSERT INTO geographie VALUES (63, 'Puy-de-Dôme', 'Clermont-Ferrand');
    INSERT INTO geographie VALUES (64, 'Pyrénées-Atlantiques', 'Pau');
    INSERT INTO geographie VALUES (65, 'Hautes-Pyrénées', 'Tarbes');
    INSERT INTO geographie VALUES (66, 'Pyrénées-Orientales', 'Perpignan');
    INSERT INTO geographie VALUES (67, 'Bas-Rhin', 'Strasbourg');
    INSERT INTO geographie VALUES (68, 'Haut-Rhin', 'Colmar');
    INSERT INTO geographie VALUES (69, 'Rhône', 'Lyon');
    INSERT INTO geographie VALUES (70, 'Haute-Saône', 'Vesoul');
    INSERT INTO geographie VALUES (71, 'Saône-et-Loire', 'Mâcon');
    INSERT INTO geographie VALUES (72, 'Sarthe', 'Le Mans');
    INSERT INTO geographie VALUES (73, 'Savoie', 'Chambéry');
    INSERT INTO geographie VALUES (74, 'Haute-Savoie', 'Annecy');
    INSERT INTO geographie VALUES (75, 'Paris', 'Paris');
    INSERT INTO geographie VALUES (76, 'Seine-Maritime', 'Rouen');
    INSERT INTO geographie VALUES (77, 'Seine-et-Marne', 'Melun');
    INSERT INTO geographie VALUES (78, 'Yvelines', 'Versailles');
    INSERT INTO geographie VALUES (79, 'Deux-Sèvres', 'Niort');
    INSERT INTO geographie VALUES (80, 'Somme', 'Amiens');
    INSERT INTO geographie VALUES (81, 'Tarn', 'Albi');
    INSERT INTO geographie VALUES (82, 'Tarn-et-Garonne', 'Montauban');
    INSERT INTO geographie VALUES (83, 'Var', 'Toulon');
    INSERT INTO geographie VALUES (84, 'Vaucluse', 'Avignon');
    INSERT INTO geographie VALUES (85, 'Vendée', 'La Roche-sur-Yon');
    INSERT INTO geographie VALUES (86, 'Vienne', 'Poitiers');
    INSERT INTO geographie VALUES (87, 'Haute-Vienne', 'Limoges');
    INSERT INTO geographie VALUES (88, 'Vosges', 'Épinal');
    INSERT INTO geographie VALUES (89, 'Yonne', 'Auxerre');
    INSERT INTO geographie VALUES (90, 'Territoire de Belfort', 'Belfort');
    INSERT INTO geographie VALUES (91, 'Essonne', 'Évry');
    INSERT INTO geographie VALUES (92, 'Hauts-de-Seine', 'Nanterre');
    INSERT INTO geographie VALUES (93, 'Seine-Saint-Denis', 'Bobigny');
    INSERT INTO geographie VALUES (94, 'Val-de-Marne', 'Créteil');
    INSERT INTO geographie VALUES (95, 'Val-d''Oise', 'Pontoise');
    INSERT INTO geographie VALUES (96, 'Corse-du-Sud', 'Ajaccio');
    INSERT INTO geographie VALUES (97, 'Haute-Corse', 'Bastia');
    INSERT INTO geographie VALUES (98, 'Saint-Pierre-et-Miquelon', 'Saint-Pierre');
    INSERT INTO geographie VALUES (99, 'Wallis-et-Futuna', 'Mata-Utu');
    INSERT INTO geographie VALUES (100, 'Polynésie française', 'Papeete');
END;


--Remplissage de Personne--
DECLARE
    i NUMBER;
    a NUMBER;
    b NUMBER;
    nom VARCHAR2(50);
    prenom VARCHAR2(50);
    email VARCHAR2(50);
    sexe CHAR(1);
    dateNaissance DATE;
    departementNaissance NUMBER;
    dateDeces DATE;
    departementDeces NUMBER;
    mere NUMBER;
    pere NUMBER;
BEGIN
    FOR i IN 1..1000 LOOP
        nom := dbms_random.string('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 10);
        prenom := dbms_random.string('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 10);
        email := dbms_random.string('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 10) || '@' || dbms_random.string('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 5) || '.com';
        sexe := CASE MOD(i, 2) WHEN 0 THEN 'M' ELSE 'F' END;
        dateNaissance := dbms.random.value(TO_DATE('01-01-1900', 'DD-MM-YYYY'), TO_DATE('01-01-2000', 'DD-MM-YYYY'));
        departementNaissance := MOD(i, 100) + 1;
        a := dbms_random.value(0, 1);
        IF a = 1 THEN
            dateDeces := dateNaissance + dbms_random.value(TO_DATE('01-01-0', 'DD-MM-YYYY'), TO_DATE('01-01-100', 'DD-MM-YYYY'));
            departementDeces := MOD(i + 1000, 100) + 1;
        ELSE
            dateDeces := NULL;
            departementDeces := NULL;
        END IF;
        b := dbms_random.value(0, 4);
        CASE b WHEN 0 THEN
            mere := NULL;
            pere := NULL;
        WHEN 1 THEN
            mere := NULL;
            pere := dbms_random.value(1, i - 1);
        WHEN 2 THEN
            mere := dbms_random.value(1, i - 1);
            pere := NULL;
        ELSE
            mere := dbms_random.value(1, i - 1);
            pere := dbms_random.value(1, i - 1);
        END CASE;

        INSERT INTO personne VALUES (i, nom, prenom, email, sexe, dateNaissance, departementNaissance, dateDeces, departementDeces, mere, pere);
    END LOOP;
END;


--Remplissage de Personne1 et Personne2--
create or replace trigger remplissage_personne1_personne2
instead of insert on personne
for each row
begin
    INSERT INTO personne1 VALUES (:new.numP, :new.nom, :new.prenom, :new.email, :new.sexe, :new.dateNaissance, :new.departementNaissance, :new.dateDeces, :new.departementDeces);
    INSERT INTO personne2 VALUES (:new.numP, :new.mere, :new.pere);
end;

--Remplissage de Mariage--
DECLARE
    i NUMBER;
    a NUMBER;
    dateMariage DATE;
    lieuMariage VARCHAR2(50);
    epoux NUMBER;
    epouse NUMBER;
    dateDivorce DATE;
BEGIN
    FOR i IN 1..500 LOOP
        dateMariage := dbms.random.value(TO_DATE('01-01-1900', 'DD-MM-YYYY'), TO_DATE('01-01-2000', 'DD-MM-YYYY'));
        lieuMariage := dbms_random.string('ABCDEFGHIJKLMNOPQRSTUVWXYZ', 10);
        epoux := dbms_random.value(1, 1000);
        epouse := dbms_random.value(1, 1000);
        a := dbms_random.value(0, 1);
        IF a = 1 THEN
            dateDivorce := dateMariage + dbms_random.value(TO_DATE('01-01-0', 'DD-MM-YYYY'), TO_DATE('01-01-100', 'DD-MM-YYYY'));
        ELSE
            dateDivorce := NULL;
        END IF;
        INSERT INTO mariage VALUES (i, epoux, epouse, dateMariage, lieuMariage);
    END LOOP;
END;
'''

**Annexe 8 : jeu de requêtes**
'''sql
-- affichage de tous les mariages pour la personne 54, avec les noms des époux et épouses
SELECT epoux.nom, epoux.prenom, epouse.nom, epouse.prenom, mariage.dateMariage, mariage.lieuMariage, mariage.dateDivorce
FROM mariage
INNER JOIN personne epoux ON mariage.epoux = epoux.numP
INNER JOIN personne epouse ON mariage.epouse = epouse.numP
WHERE epoux.numP = 54 OR epouse.numP = 54;
ORDER BY mariage.dateMariage;


-- affichage des départements classés par nombre de personnes nées
SELECT numeroDepartement, COUNT(*) as nombrePersonnes
FROM Geographie INNER JOIN personne1 ON Geographie.numDepartement = personne1.departementNaissance
GROUP BY numeroDepartement
ORDER BY nombrePersonnes DESC;

-- affichage des personnes nées dans un département donné
SELECT personne.nom, personne.prenom, personne.dateNaissance
FROM personne
WHERE personne.departementNaissance = 75;
ORDER BY personne.dateNaissance ASC;

-- affichage des personnes mortes en Côte d'Or en 1990
SELECT personne1.nom, personne1.prenom, personne1.dateDeces
FROM personne1
WHERE personne1.departementDeces = 21 AND EXTRACT(YEAR FROM personne1.dateDeces) = 1990;
ORDER BY personne1.dateDeces ASC;

-- affichage des naissances en Lozère en 1999
SELECT nom, prenom, dateNaissance
FROM personne1
WHERE departementNaissance = 48 AND EXTRACT(YEAR FROM dateNaissance) = 1999;
ORDER BY dateNaissance ASC;

-- classement des années par nombre de mariages
Select EXTRACT(YEAR FROM dateMariage) as annee, COUNT(*) as nombreMariages
FROM mariage
GROUP BY annee
ORDER BY nombreMariages DESC;

-- classement des années par nombre de divorces
Select EXTRACT(YEAR FROM dateDivorce) as annee, COUNT(*) as nombreDivorces
FROM mariage
WHERE dateDivorce IS NOT NULL
GROUP BY annee
ORDER BY nombreDivorces DESC;

-- affichage des personnes mortes avant leurs 18 ans
SELECT nom, prenom, dateNaissance, dateDeces, departementNaissance, departementDeces
FROM personne1
WHERE dateDeces - dateNaissance < 18*365.25;
ORDER BY dateDeces ASC;

-- affichage des homonymes
SELECT nom, prenom, COUNT(*) as nombreHomonymes
FROM personne1
GROUP BY nom, prenom
HAVING COUNT(*) > 1
ORDER BY nom, prenom;

-- affiche des gens nés en 1999 et de leur parents
SELECT 
    enfant.prenom AS prenom_enfant, 
    enfant.nom AS nom_enfant, 
    pere.prenom AS prenom_pere, 
    pere.nom AS nom_pere, 
    mere.prenom AS prenom_mere, 
    mere.nom AS nom_mere
FROM 
    PERSONNE enfant
LEFT JOIN 
    PERSONNE pere ON enfant.pere = pere.numP
LEFT JOIN 
    PERSONNE mere ON enfant.mere = mere.numP
WHERE 
    EXTRACT(YEAR FROM enfant.dateNaissance) = 1999;

--affichage des mariages dans le 75 en 2010
SELECT 
    epoux.prenom AS prenom_epoux, 
    epoux.nom AS nom_epoux, 
    epouse.prenom AS prenom_epouse, 
    epouse.nom AS nom_epouse, 
    MARIAGE_T.dateMariage, 
    MARIAGE_T.lieuMariage, 
    MARIAGE_T.dateDivorce
FROM 
    MARIAGE_T
INNER JOIN 
    GEOGRAPHIE ON MARIAGE_T.lieuMariage = GEOGRAPHIE.nomLieu
INNER JOIN 
    PERSONNE epoux ON MARIAGE_T.epoux = epoux.numP
INNER JOIN 
    PERSONNE epouse ON MARIAGE_T.epouse = epouse.numP
WHERE 
    GEOGRAPHIE.codeDepartement = 75 AND EXTRACT(YEAR FROM MARIAGE_T.dateMariage) = 2010;

-- affichage des personnes qui se sont mariées après 2000
SELECT p.nom, p.prenom
FROM PERSONNE p
WHERE p.numP IN (
    SELECT m.epoux
    FROM MARIAGE m
    WHERE EXTRACT(YEAR FROM m.dateMariage) > 2000
    UNION
    SELECT m.epouse
    FROM MARIAGE m
    WHERE EXTRACT(YEAR FROM m.dateMariage) > 2000
);

-- affichage des personnes vivantes les plus vieilles de chaque département
SELECT 
    p.nom, 
    p.prenom, 
    p.dateNaissance, 
    p.departementNaissance
FROM
    PERSONNE p
WHERE
    p.dateDeces IS NULL
AND
    p.dateNaissance = (
        SELECT 
            MIN(p2.dateNaissance)
        FROM 
            PERSONNE p2
        WHERE 
            p2.departementNaissance = p.departementNaissance
    );
ORDER BY p.departementNaissance;

-- affichage des personnes ayant eu le plus d'enfants
SELECT 
    p.nom, 
    p.prenom, 
    COUNT(*) AS nombreEnfants   
FROM
    PERSONNE p
WHERE
    p.numP IN (
        SELECT 
            p2.mere
        FROM 
            PERSONNE p2
        UNION
        SELECT 
            p3.pere
        FROM 
            PERSONNE p3
    )
GROUP BY p.numP
ORDER BY nombreEnfants DESC;

-- affichage des personnes ayant eu le plus de mariages
SELECT 
    p.nom, 
    p.prenom, 
    COUNT(*) AS nombreMariages
FROM
    PERSONNE p
WHERE
    p.numP IN (
        SELECT 
            m.epoux
        FROM 
            MARIAGE m
        UNION
        SELECT 
            m.epouse
        FROM 
            MARIAGE m
    )
GROUP BY p.numP
ORDER BY nombreMariages DESC;
'''

