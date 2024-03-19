/* GEOGRAPHIE (
  numDepartement,
  nom,
  prefecture
) */
create table if not exists GEOGRAPHIE_G (
  numDepartement primary key,
  nom varchar2(255) not null,
  prefecture varchar2(255) not null
);
/* GEOGRAPHIE_T */
create materialized view if not exists GEOGRAPHIE_T 
  refresh fast on demand
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
/* PERSONNE_G = PERSONNE1 join PERSONNE2 */
create view if not exists PERSONNE_G as
  select * from PERSONNE1 join PERSONNE2 on PERSONNE1.numP = PERSONNE2.numP;
/* PERSONNE_T */
create materialized view if not exists PERSONNE_T 
  refresh fast on demand
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
  epoux not null, -- foreign key (numP) references PERSONNE(numP),
  epouse not null, -- foreign key (numP) references PERSONNE(numP),
  dateMariage date not null,
  lieuMariage varchar2(255) not null,
  dateDivorce date optional
); -- */
/* MARIAGE_T */
create materialized view if not exists MARIAGE_T 
  refresh fast on demand
  as select * from MARIAGE_T@db_link;
/* MARIAGE = MARIAGE_G union MARIAGE_T */
create view if not exists MARIAGE as
  select * from MARIAGE_G
  union select * from MARIAGE_T;

