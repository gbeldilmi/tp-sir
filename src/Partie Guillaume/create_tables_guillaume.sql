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
