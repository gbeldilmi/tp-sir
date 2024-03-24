-- affichage de tous les mariages pour une personne donnée
DECLARE
    numCherche NUMBER;
BEGIN
    SELECT sexe INTO genre FROM personne WHERE numP = numCherche;
    IF genre = 'M' THEN
        SELECT mariage.dateMariage, mariage.lieuMariage, personne.nom as nomEpoux, personne.prenom as prenomEpoux, personne.nom as nomEpouse, personne.prenom as prenomEpouse
        FROM mariage INNER JOIN personne ON mariage.epoux = personne.numP INNER JOIN personne ON mariage.epouse = personne.numP
        WHERE mariage.epoux = numCherche;
    ELSE
        SELECT mariage.dateMariage, mariage.lieuMariage, personne.nom as nomEpoux, personne.prenom as prenomEpoux, personne.nom as nomEpouse, personne.prenom as prenomEpouse
        FROM mariage INNER JOIN personne ON mariage.epoux = personne.numP INNER JOIN personne ON mariage.epouse = personne.numP
        WHERE mariage.epouse = numCherche;
    END IF;
END;

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

