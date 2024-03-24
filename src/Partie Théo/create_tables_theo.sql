/* GEOGRAPHIE (
  numDepartement,
  nom,
  prefecture
) */
create table if not exists GEOGRAPHIE_T (
  numDepartement integer primary key unique,
  nom varchar2(255) not null,
  prefecture varchar2(255) not null
);
/* GEOGRAPHIE_G */
create materialized view if not exists GEOGRAPHIE_G
refresh on demand
  as select * from GEOGRAPHIE_G@db_link;

/* GEOGRAPHIE = GEOGRAPHIE_T union GEOGRAPHIE_G */
create view if not exists GEOGRAPHIE as
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
create table if not exists PERSONNE1 (
  numP integer primary key unique foreign key references PERSONNE2(numP) on delete cascade,
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
create table if not exists PERSONNE2 (
  numP integer primary key foreign key unique references PERSONNE1(numP) on delete cascade,
  mere,  foreign key references PERSONNE1(numP),
  pere foreign key references PERSONNE1(numP)
); -- */
/* PERSONNE_T = PERSONNE1 join PERSONNE2 */
create view if not exists PERSONNE_T as
  select * from PERSONNE1 inner join PERSONNE2 on PERSONNE1.numP = PERSONNE2.numP;
/* PERSONNE_G */
create materialized view if not exists PERSONNE_G 
refresh on demand
  as select * from PERSONNE_G@db_link;
/* PERSONNE = PERSONNE_T union PERSONNE_G */
create view if not exists PERSONNE as
  select * from PERSONNE_T
  union select * from PERSONNE_G;


/* MARIAGE (
  epoux,
  epouse,
  dateMariage,
  lieuMariage,
  dateDivorce
) */
create table if not exists MARIAGE_T (
  epoux integer not null, foreign key references PERSONNE(numP),
  epouse integer null,  foreign key references PERSONNE(numP),
  dateMariage date not null,
  lieuMariage varchar2(255) not null,
  dateDivorce date,
  primary key unique (epoux, epouse, dateMariage)
); -- */
/* MARIAGE = synomym MARIAGE_T */
create synonym if not exists MARIAGE for MARIAGE_T;
