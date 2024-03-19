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


/*-----------------------------------*/

/*Vérifications des personnes*/
/*-----------------------------------*/
create or replace trigger check_departement_personne
before insert or update on PERSONNE
for each row
begin
    SELECT departementNaissance INTO departementNaissance FROM PERSONNE WHERE numP = :new.numP;
    SELECT departementDeces INTO departementDeces FROM PERSONNE WHERE numP = :new.numP;
    SELECT numDepartement INTO numDepartements FROM GEOGRAPHIE;
    IF departementNaissance NOT IN numDepartements OR departementDeces NOT IN numDepartements THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec un département non existant');
    END IF;
end;

create or replace trigger check_dates
before insert or update on PERSONNE
for each row
begin
    SELECT dateNaissance INTO dateNaissance FROM PERSONNE WHERE numP = :new.numP;
    SELECT dateDeces INTO dateDeces FROM PERSONNE WHERE numP = :new.numP;
    IF dateNaissance > dateDeces OR dateNaissance > SYSDATE OR dateDeces > SYSDATE THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec une date de naissance ou de décès invalide');
    END IF;
end;

create or replace trigger check_parents 
before insert or update on PERSONNE
for each row
begin
    SELECT pere INTO pere FROM PERSONNE WHERE numP = :new.numP;
    SELECT mere INTO mere FROM PERSONNE WHERE numP = :new.numP;
    SELECT numP INTO personnes FROM PERSONNE;
    IF pere NOT IN personnes OR mere NOT IN personnes OR pere = mere OR pere = :new.numP OR mere = :new.numP OR pere is null OR mere is null THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec des parents invalides');
    END IF;
end;

create or replace trigger check_email
before insert or update on PERSONNE
for each row
begin
    SELECT email INTO email FROM PERSONNE WHERE numP = :new.numP;
    IF email NOT LIKE '%@%' THEN
        RAISE_APPLICATION_ERROR(-20000, 'Impossible de créer une personne avec un email invalide');
    END IF;
end;

create or replace trigger check_sexe
before insert or update on PERSONNE
for each row
begin
    SELECT sexe INTO sexe FROM PERSONNE WHERE numP = :new.numP;
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

