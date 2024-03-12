/* PERSONNE (
  numP,
  nom,
  prenom,
  email,
  sexe,
  dateNaissance,
  departementNaissance,
  dateDeces,
  departementDeces,
  mere,
  pere
) */
create table if not exists PERSONNE (
  numP primary key,
  nom varchar2(255) not null,
  prenom varchar2(255) not null,
  email varchar2(255) not null,
  sexe varchar2(1) not null,
  dateNaissance date not null,
  departementNaissance varchar2(255) not null,
  dateDeces date optional,
  departementDeces varchar2(255) optional,
  mere foreign key (numP) references PERSONNE(numP),
  pere foreign key (numP) references PERSONNE(numP)
); -- */

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

/* PERSONNE2 (
  numP,
  mere,
  pere
) */


/* MARIAGE (
  epoux,
  epouse,
  dateMariage,
  lieuMariage,
  dateDivorce
) */
create table if not exists MARIAGE (
  epoux foreign key (numP) references PERSONNE(numP),
  epouse foreign key (numP) references PERSONNE(numP),
  dateMariage date not null,
  lieuMariage varchar2(255) not null,
  dateDivorce date optional
); -- */

/* GEOGRAPHIE (
  numDepartement,
  nom,
  prefecture
) */
create table if not exists GEOGRAPHIE (
  numDepartement primary key,
  nom varchar2(255) not null,
  prefecture varchar2(255) not null
); -- */

