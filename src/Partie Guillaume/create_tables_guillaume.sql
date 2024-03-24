/* GEOGRAPHIE (
  numDepartement,
  nom,
  prefecture
) */
create table if not exists GEOGRAPHIE_G (
  numDepartement integer primary key unique,
  nom varchar2(255) not null,
  prefecture varchar2(255) not null
);
/* GEOGRAPHIE_T */
create materialized view if not exists GEOGRAPHIE_T
refresh on demand
  as select * from GEOGRAPHIE_T@db_link;

/* GEOGRAPHIE = GEOGRAPHIE_G union GEOGRAPHIE_T */
create view if not exists GEOGRAPHIE as
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
/* PERSONNE_G = PERSONNE1 join PERSONNE2 */
create view if not exists PERSONNE_G as
  select * from PERSONNE1 inner join PERSONNE2 on PERSONNE1.numP = PERSONNE2.numP;
/* PERSONNE_T */
create materialized view if not exists PERSONNE_T 
refresh on demand
  as select * from PERSONNE_T@db_link;
/* PERSONNE = PERSONNE_G union PERSONNE_T */
create view if not exists PERSONNE as
  select * from PERSONNE_G
  union select * from PERSONNE_T;


/* MARIAGE (
  epoux,
  epouse,
  dateMariage,
  lieuMariage,
  dateDivorce
) */
create table if not exists MARIAGE_G (
  epoux integer not null, foreign key references PERSONNE(numP),
  epouse integer null,  foreign key references PERSONNE(numP),
  dateMariage date not null,
  lieuMariage varchar2(255) not null,
  dateDivorce date,
  primary key unique (epoux, epouse, dateMariage)
); -- */
/* MARIAGE = synomym MARIAGE_G */
create synonym if not exists MARIAGE for MARIAGE_G;
