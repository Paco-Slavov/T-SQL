CREATE DATABASE Zoo

USE Zoo

GO

--01. DDL

CREATE TABLE Owners
	(
		Id INT PRIMARY KEY IDENTITY,
		Name VARCHAR (50) NOT NULL,
		PhoneNumber VARCHAR(15) NOT NULL,
		[Address] VARCHAR (50)
	)

CREATE TABLE AnimalTypes
	(
		Id INT PRIMARY KEY IDENTITY,
		AnimalType VARCHAR(30) NOT NULL
	)
	
CREATE TABLE Cages
	(
		Id INT PRIMARY KEY IDENTITY,
		AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
	)

CREATE TABLE Animals
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] VARCHAR(30) NOT NULL,
		BirthDate DATE NOT NULL,
		OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
		AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
	)
	
CREATE TABLE AnimalsCages
	(
		CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL,
		AnimalId INT FOREIGN KEY REFERENCES Animals(Id) NOT NULL,
		PRIMARY KEY (CageId, AnimalId)
	)
	
CREATE TABLE VolunteersDepartments
	(
		Id INT PRIMARY KEY IDENTITY,
		DepartmentName VARCHAR(30) NOT NULL
	)
	
CREATE TABLE Volunteers
	(
		Id INT PRIMARY KEY IDENTITY,
		[Name] VARCHAR(50) NOT NULL,
		PhoneNumber VARCHAR(15) NOT NULL,
		[Address] VARCHAR(50),
		AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
		DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
	)

--02. Insert

INSERT INTO Volunteers(Name, PhoneNumber, Address, AnimalId, DepartmentId)
	VALUES 
		('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1),
		('Dimitur Stoev', '0877564223', NULL, 42, 4),
		('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7),
		('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
		('Boryana Mileva', '0888112233', NULL, 31, 5)
		
INSERT INTO Animals (Name, BirthDate, OwnerId, AnimalTypeId)
	VALUES	
			('Giraffe', '2018-09-21', 21, 1),
			('Harpy Eagle', '2015-04-17', 15, 3),
			('Hamadryas Baboon', '2017-11-02', NULL, 1),
			('Tuatara', '2021-06-30', 2, 4)
			
--03. Update

UPDATE [Animals]
SET [OwnerId] = 
				(
					SELECT Id
					FROM Owners
					WHERE [Name] = 'Kaloqn Stoqnov'
				)
WHERE OwnerId IS NULL

--04. Delete

DELETE FROM Volunteers
WHERE [DepartmentId] = 2

SELECT *
FROM VolunteersDepartments

DELETE
FROM VolunteersDepartments
WHERE Id = 2

--05. Volunteers

SELECT 
		Name,
		PhoneNumber,
		[Address],
		AnimalId,
		DepartmentId
FROM Volunteers
ORDER BY Name, AnimalId, DepartmentId

--06. Animals data

SELECT 
		Name,
		at.AnimalType,
		FORMAT(Birthdate, 'dd.MM.yyyy') AS BirthDate
FROM Animals AS a
JOIN AnimalTypes AS at ON a.AnimalTypeId = at.Id
ORDER BY Name

--07. Owners and Their Animals

SELECT TOP (5) o.Name AS Owner, COUNT(*) AS CountOfAnimals
FROM Owners AS o
JOIN Animals AS a ON a.OwnerId = o.Id
GROUP BY o.Name
ORDER BY CountOfAnimals DESC, Owner

--08. Owners, Animals and Cages

SELECT CONCAT(o.Name, '-', a.Name) AS OwnersAnimals , o.PhoneNumber, c.Id AS CageId
FROM Owners AS o
JOIN Animals AS a ON a.OwnerId = o.Id
JOIN AnimalTypes AS at ON at.Id = a.AnimalTypeId
JOIN AnimalsCages AS ac ON ac.AnimalId = a.Id
JOIN Cages AS c ON c.Id = ac.CageId
WHERE AnimalType = 'Mammals'
ORDER BY o.Name, a.Name DESC

--09. Volunteers in Sofia

	SELECT  v.Name,
			v.PhoneNumber,
			LTRIM(REPLACE(REPLACE(v.[Address], 'Sofia', ''), ',' ,''))
	  FROM [Volunteers]
		AS v
INNER JOIN [VolunteersDepartments]
		AS vd
		ON v.DepartmentId = vd.Id
	WHERE vd.DepartmentName = 'Education program assistant' AND
		  v.[Address] LIKE '%Sofia%'
  ORDER BY v.Name
  
  --10. Animals for Adoption
  
  SELECT a.Name,
		 DATEPART(YEAR, a.BirthDate)
		 AS BirthYear,
		 at.AnimalType
  FROM Animals
  AS a
  INNER JOIN AnimalTypes
  AS at
  ON a.AnimalTypeId = at.Id
  WHERE a.OwnerId IS NULL AND
  DATEDIFF(YEAR, a.BirthDate, '01/01/2022') < 5 AND
  at.AnimalType <> 'Birds'
  ORDER BY a.Name
  
  GO
  
  --
  
 CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
 RETURNS INT 
		  AS
	   BEGIN
			DECLARE @departmentId INT;
			SET @departmentId = (
									SELECT Id
									FROM VolunteersDepartments
									WHERE DepartmentName = @VolunteersDepartment
								);
			DECLARE @departmentVolunteersCount INT;
			SET @departmentVolunteersCount = (
													SELECT COUNT (*)
													FROM Volunteers
													WHERE DepartmentId = @departmentId
											 );
			RETURN @departmentVolunteersCount;									 
		END

GO
--12. Animals with Owner or Not

CREATE PROC usp_AnimalsWithOwnersOrNot (@AnimalName VARCHAR(50))
	     AS
	  BEGIN
			SELECT a.Name,
				   ISNULL(o.Name, 'For adoption') 
			FROM Animals 
			AS a
	 LEFT JOIN [Owners]
			AS o
			ON a.OwnerId = o.Id
		 WHERE a.Name = @AnimalName
	  END