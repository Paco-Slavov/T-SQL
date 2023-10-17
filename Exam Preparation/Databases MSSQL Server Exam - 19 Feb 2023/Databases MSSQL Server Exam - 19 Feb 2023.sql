CREATE DATABASE Boardgames
USE Boardgames

-- 01. DDL
CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)


CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY,
	StreetName NVARCHAR(100) NOT NULL,
	StreetNumber INT NOT NULL,
	Town VARCHAR(30) NOT NULL,
	Country VARCHAR(50) NOT NULL,
	ZIP INT NOT NULL
)


CREATE TABLE Publishers
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL UNIQUE,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL,
	Website NVARCHAR(40),
	Phone NVARCHAR(20)
)


CREATE TABLE PlayersRanges
(
	Id INT PRIMARY KEY IDENTITY,
	PlayersMin INT NOT NULL,
	PlayersMax INT NOT NULL
)


CREATE TABLE Boardgames
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	YearPublished INT NOT NULL,
	Rating DECIMAL(18,2) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	PublisherId INT FOREIGN KEY REFERENCES Publishers(Id) NOT NULL,
	PlayersRangeId INT FOREIGN KEY REFERENCES PlayersRanges(Id) NOT NULL
)


CREATE TABLE Creators
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(30) NOT NULL,
)


CREATE TABLE CreatorsBoardgames
(
	CreatorId INT NOT NULL FOREIGN KEY REFERENCES Creators(Id),
    BoardgameId INT NOT NULL FOREIGN KEY REFERENCES Boardgames(Id),
    PRIMARY KEY (CreatorId, BoardgameId)
)

--02. Insert

INSERT INTO Boardgames([Name], YearPublished, Rating, CategoryId, PublisherId,PlayersRangeId)
	VALUES
		('Deep Blue',		  2019, 5.67, 1, 15, 7),
		('Paris',			  2016, 9.78, 7, 1,  5),
		('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
		('Bleeding Kansas',	  2020, 3.25, 3, 7,  4),
		('One Small Step',	  2019, 5.75, 5, 9,  2)

INSERT INTO Publishers([Name], AddressId, Website, Phone)
	VALUES
		('Agman Games', 5, 'www.agmangames.com', '+16546135542'),
		('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
		('BattleBooks', 13, 'www.battlebooks.com', '+12345678907')
		
--03. Update

UPDATE PlayersRanges
SET PlayersMax += 1
WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
SET [Name] = CONCAT([Name], 'V2')
WHERE YearPublished >= 2020

--04. Delete

DELETE FROM CreatorsBoardgames WHERE BoardgameId IN (1,16,31,47)
DELETE FROM Boardgames WHERE PublisherId IN (1,16)
DELETE FROM Publishers WHERE AddressId IN (5)
DELETE FROM Addresses WHERE SUBSTRING(Town, 1, 1) = 'L'

--05. Boardgames by Year of Publication

  SELECT [Name], Rating
  FROM Boardgames
  ORDER BY YearPublished, [Name] DESC
  
--06. Boardgames by Category

  SELECT 
		b.Id, 
		b.[Name],
		b.YearPublished,
		c.[Name] AS CategoryName
  FROM BoardGames AS b
 JOIN Categories AS c ON b.CategoryId = c.Id
 WHERE c.[Name] IN ('Strategy Games', 'Wargames')
 ORDER BY b.YearPublished DESC
  
--07. Creators without Boardgames

 SELECT 
		cr.Id,
		CONCAT(cr.FirstName, ' ', cr.LastName) AS CreatorName, 
		cr.Email
 FROM Creators AS cr
LEFT JOIN CreatorsBoardGames AS cb ON cb.CreatorId = cr.Id
WHERE cb.BoardgameId IS NULL

--08. First 5 Boardgames

SELECT TOP(5)
	b.[Name],
	b.Rating,
	c.[Name] AS CategoryName
FROM BoardGames AS b
JOIN Categories AS c ON b.CategoryId = c.Id
JOIN PlayersRanges AS pr ON b.PlayersRangeId = pr.Id
WHERE b.Rating > 7 AND b.[Name] LIKE '%a%' OR b.Rating > 7.5 AND pr.PlayersMin = 2 AND pr.PlayersMax = 5
ORDER BY b.[Name], b.Rating

--09. Creators with Emails

SELECT
	CONCAT(cr.FirstName, ' ', cr.LastName) AS FullName,
	cr.Email,
	MAX(b.Rating) AS Rating
FROM Creators AS cr
JOIN CreatorsBoardGames AS cb ON cr.Id = cb.CreatorId
JOIN BoardGames AS b ON cb.BoardgameId = b.Id
WHERE cr.Email LIKE '%.com'
GROUP BY cr.FirstName, cr.LastName, cr.Email
ORDER BY FullName

--10. Creators by Rating

SELECT	cr.LastName,
		CEILING(AVG(b.Rating)) AS AverageRating,
		p.[Name] AS PublisherName
FROM Creators AS cr
JOIN CreatorsBoardGames AS cb ON cb.CreatorId = cr.Id
JOIN BoardGames AS b ON b.Id = cb.BoardgameId
JOIN Publishers AS p ON p.Id = b.PublisherId
WHERE p.[Name] IN ('Stonemaier Games')
GROUP BY cr.LastName, p.[Name]
ORDER BY AVG(b.Rating) DESC

--11. Creator with Boardgames

CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR (30))
RETURNS INT
BEGIN
	DECLARE @creatorId INT =
	(
		Select Id
		FROM Creators
		WHERE FirstName = @name
	)
	RETURN
	(
		SELECT COUNT(*)
		FROM CreatorsBoardGames
		WHERE CreatorId = @creatorId
	)
END

SELECT dbo.udf_CreatorWithBoardgames('Bruno')

--12. Search for Boardgame with Specific Category

CREATE PROC usp_SearchByCategory(@category VARCHAR(50))
AS
	SELECT 
	b.[Name],
	b.YearPublished,
	b.Rating,
	c.[Name] AS CategoryName,
	p.[Name] AS PublisherName,
	CONCAT(pr.PlayersMin, ' ', 'people') AS MinPlayers,
	CONCAT(pr.PlayersMax, ' ', 'people') AS MaxPlayers
FROM BoardGames AS b
JOIN Categories AS c ON b.CategoryId = c.Id
JOIN Publishers AS p ON b.PublisherId = p.Id
JOIN PlayersRanges AS pr ON b.PlayersRangeId = pr.Id
WHERE c.[Name] IN (@category)
ORDER BY p.[Name], b.YearPublished DESC

EXEC usp_SearchByCategory 'Wargames'