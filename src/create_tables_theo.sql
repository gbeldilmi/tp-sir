/* GEOGRAPHIE (
  numDepartement,
  nom,
  prefecture
) */
create table if not exists GEOGRAPHIE_T (
  numDepartement primary key,
  nom varchar2(255) not null,
  prefecture varchar2(255) not null
);
/* GEOGRAPHIE_G */
create materialized view if not exists GEOGRAPHIE_G 
  refresh fast on demand
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
  numP primary key,
  nom varchar2(255) not null,
  prenom varchar2(255) not null,
  email varchar2(255) not null,
  sexe varchar2(1) not null,
  dateNaissance date not null,
  departementNaissance varchar2(255) not null,
  dateDeces date optional,
  departementDeces varchar2(255) optional
); -- */
/* PERSONNE2 (
  numP,
  mere,
  pere
) */
create table if not exists PERSONNE2 (
  numP primary key,
  mere, -- foreign key (numP) references PERSONNE1(numP),
  pere -- foreign key (numP) references PERSONNE1(numP)
); -- */
/* PERSONNE_T = PERSONNE1 join PERSONNE2 */
create view if not exists PERSONNE_T as
  select * from PERSONNE1 join PERSONNE2 on PERSONNE1.numP = PERSONNE2.numP;
/* PERSONNE_G */
create materialized view if not exists PERSONNE_G 
  refresh fast on demand
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
  epoux not null, -- foreign key (numP) references PERSONNE(numP),
  epouse not null, -- foreign key (numP) references PERSONNE(numP),
  dateMariage date not null,
  lieuMariage varchar2(255) not null,
  dateDivorce date optional
); -- */
/* MARIAGE_G */
create materialized view if not exists MARIAGE_G
  refresh fast on demand
  as select * from MARIAGE_G@db_link;
/* MARIAGE = MARIAGE_T union MARIAGE_G */
create view if not exists MARIAGE as
  select * from MARIAGE_T
  union select * from MARIAGE_G;

