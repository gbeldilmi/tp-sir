CREATE OR REPLACE TRIGGER check_site_insert_personne1
INSTEAD OF INSERT ON personne
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        DELETE FROM personne1@db_link WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne1@db_link VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
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
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        UPDATE personne1@db_link SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        DELETE FROM personne1@db_link WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        UPDATE personne1 SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_delete_personne1
INSTEAD OF DELETE ON personne1
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        DELETE FROM personne1@db_link WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        DELETE FROM personne1 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_insert_personne2
INSTEAD OF INSERT ON personne2
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        DELETE FROM personne2@db_link WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne2@db_link VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        INSERT INTO personne2 VALUES (:new.numDepartement, :new.nom, :new.prenom, :new.dateNaissance, :new.lieuNaissance, :new.dateDeces, :new.lieuDeces);
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_update_personne2
INSTEAD OF UPDATE ON personne2
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
        UPDATE personne2@db_link SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        DELETE FROM personne2@db_link WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
        UPDATE personne2 SET numDepartement = :new.numDepartement, nom = :new.nom, prenom = :new.prenom, dateNaissance = :new.dateNaissance, lieuNaissance = :new.lieuNaissance, dateDeces = :new.dateDeces, lieuDeces = :new.lieuDeces WHERE numP = :old.numP;
    END IF;
END;

CREATE OR REPLACE TRIGGER check_site_delete_personne2
INSTEAD OF DELETE ON personne2
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        DELETE FROM personne2@db_link WHERE numP = :old.numP; -- Suppression de la personne de la base de données distante
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        DELETE FROM personne2 WHERE numP = :old.numP; -- Suppression de la personne de la base de données locale
    END IF;
END;

CREATE OR REPLACE TRIGGER check_mariage_insert
BEFORE INSERT ON mariage
FOR EACH ROW
BEGIN
    INSERT INTO mariage@db_link VALUES (:new.numP1, :new.numP2, :new.dateMariage, :new.lieuMariage);
END;

CREATE OR REPLACE TRIGGER check_mariage_update
BEFORE UPDATE ON mariage
FOR EACH ROW
BEGIN
    UPDATE mariage@db_link SET numP1 = :new.numP1, numP2 = :new.numP2, dateMariage = :new.dateMariage, lieuMariage = :new.lieuMariage WHERE numP1 = :old.numP1 AND numP2 = :old.numP2;
END;

CREATE OR REPLACE TRIGGER check_mariage_delete
BEFORE DELETE ON mariage
FOR EACH ROW
BEGIN
    DELETE FROM mariage@db_link WHERE numP1 = :old.numP1 AND numP2 = :old.numP2;
END;

CREATE OR REPLACE TRIGGER check_geographie_insert
BEFORE INSERT ON geographie
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        INSERT INTO geographie@db_link VALUES (:new.numDepartement, :new.nomDepartement, :new.nomRegion, :new.nomPays);
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        INSERT INTO geographie VALUES (:new.numDepartement, :new.nomDepartement, :new.nomRegion, :new.nomPays);
    END IF;
END;

CREATE OR REPLACE TRIGGER check_geographie_update
BEFORE UPDATE ON geographie
FOR EACH ROW
BEGIN
    IF :new.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        UPDATE geographie@db_link SET numDepartement = :new.numDepartement, nomDepartement = :new.nomDepartement, nomRegion = :new.nomRegion, nomPays = :new.nomPays WHERE numDepartement = :old.numDepartement;
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        UPDATE geographie SET numDepartement = :new.numDepartement, nomDepartement = :new.nomDepartement, nomRegion = :new.nomRegion, nomPays = :new.nomPays WHERE numDepartement = :old.numDepartement;
    END IF;
END;

CREATE OR REPLACE TRIGGER check_geographie_delete
BEFORE DELETE ON geographie
FOR EACH ROW
BEGIN
    IF :old.numDepartement MOD 2 = 0 THEN
        -- Si le numéro de département est pair, effectuez la requête sur la base de données distante
        DELETE FROM geographie@db_link WHERE numDepartement = :old.numDepartement;
    ELSE
        -- Si le numéro de département est impair, effectuez la requête en local
        DELETE FROM geographie WHERE numDepartement = :old.numDepartement;
    END IF;
END;

