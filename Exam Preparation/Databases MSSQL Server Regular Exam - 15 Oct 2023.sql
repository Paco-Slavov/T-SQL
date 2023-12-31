CREATE DATABASE TouristAgency

USE TouristAgency

GO

--01. Task

CREATE TABLE Countries
(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR (50) NOT NULL
)

CREATE TABLE Destinations
(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	CountryId INT FOREIGN KEY REFERENCES Countries(Id)NOT NULL
)

CREATE TABLE Rooms
(
	Id INT PRIMARY KEY IDENTITY,
	Type VARCHAR(40) NOT NULL,
	Price DECIMAL(18,2) NOT NULL,
	BedCount INT CONSTRAINT BedCount CHECK (BedCount BETWEEN 0 AND 10) NOT NULL
)

CREATE TABLE Hotels
(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	DestinationId INT FOREIGN KEY REFERENCES Destinations(Id) NOT NULL
)

CREATE TABLE Tourists
(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(80) NOT NULL,
	PhoneNumber VARCHAR(20) NOT NULL,
	Email VARCHAR(80),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL
)

CREATE TABLE Bookings
(
	Id INT PRIMARY KEY IDENTITY,
	ArrivalDate DATETIME2 NOT NULL,
	DepartureDate DATETIME2 NOT NULL,
	AdultsCount INT CONSTRAINT AdultsCount CHECK (AdultsCount BETWEEN 1 AND 10) NOT NULL,
	ChildrenCount INT CONSTRAINT ChildrenCount CHECK (ChildrenCount BETWEEN 0 AND 9) NOT NULL,
	TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL
)

CREATE TABLE HotelsRooms
(
	HotelId INT FOREIGN KEY REFERENCES Hotels(Id) NOT NULL,
	RoomId INT FOREIGN KEY REFERENCES Rooms(Id) NOT NULL,
	PRIMARY KEY (HotelId, RoomId)
)

--02.Task

INSERT INTO Tourists (Name, PhoneNumber, Email, CountryId)
	VALUES
	
	('John Rivers' , '653-551-1555' , 'john.rivers@example.com', 6),
	('Adeline Aglaé' , '122-654-8726', 'adeline.aglae@example.com', 2),
	('Sergio Ramirez' , '233-465-2876', 's.ramirez@example.com', 3),
	('Johan Müller', '322-876-9826', 'j.muller@example.com' , 7),
	('Eden Smith', '551-874-2234', 'eden.smith@example.com', 6)

INSERT INTO Bookings (ArrivalDate, DepartureDate, AdultsCount, ChildrenCount,
			TouristId, HotelId, RoomId)
	VALUES
	
	('2024-03-01' , '2024-03-11' , 1 , 0, 21 , 3 , 5),
	('2023-12-28' , '2024-01-06', 2	, 1	, 22 , 13 , 3),
	('2023-11-15' , '2023-11-20' , 1 , 2 , 23 , 19 , 7),
	('2023-12-05', '2023-12-09', 4 , 0 , 24 , 6 , 4),
	('2024-05-01', '2024-05-07', 6 , 0 , 25 , 14 , 6)
	
--03. Task

UPDATE Bookings
SET DepartureDate = DATEADD (DAY, 1, DepartureDate)
WHERE MONTH(ArrivalDate) = 12 AND YEAR (ArrivalDate) = 2023

UPDATE Tourists
SET Email =	NULL
WHERE Name LIKE '%MA%'

--04. Task

DELETE
FROM Bookings
WHERE TouristId IN (6,16,25)

DELETE
FROM Tourists
WHERE Name LIKE '% Smith'

--05. Task

SELECT 
    CONVERT(NVARCHAR(10), ArrivalDate, 120) AS ArrivalDate,
    AdultsCount,
    ChildrenCount
	FROM Bookings AS b
INNER JOIN Rooms AS r ON b.RoomId = r.Id
	ORDER BY r.Price DESC, ArrivalDate ASC;
	
--06. Task

SELECT h.Id,
	   h.Name
FROM Hotels AS h
INNER JOIN HotelsRooms AS hr ON h.Id = hr.HotelId
INNER JOIN Rooms AS r ON hr.RoomId = r.Id
LEFT JOIN Bookings AS b ON h.Id = b.HotelId
WHERE r.Type = 'VIP Apartment'
GROUP BY h.Id ,h.Name
ORDER BY COUNT(b.Id) DESC

--07. Task

SELECT t.Id,
	   t.Name,
	   t.PhoneNumber
FROM Tourists
AS t
WHERE t.Id NOT IN (SELECT DISTINCT TouristId FROM Bookings)
ORDER BY t.Name 

--08. Таsk

SELECT TOP (10)
		   h.Name AS HotelName,
		   d.Name AS DestionationName,
		   c.[Name] AS CountryName
FROM Bookings
AS b
JOIN Hotels AS h ON b.HotelId = h.Id
JOIN Destinations AS d ON h.DestinationId = D.Id
JOIN Countries AS c ON c.Id = d.CountryId
WHERE b.ArrivalDate < '2023-12-31' AND h.Id % 2 = 1
ORDER BY c.Name, b.ArrivalDate 

--09. Task

SELECT h.Name AS HotelName,
	   r.Price AS RoomPrice
FROM Tourists AS t
JOIN Bookings AS b ON b.TouristId = t.Id
JOIN Hotels AS h ON b.HotelId = h.Id
JOIN Rooms AS r ON b.RoomId = r.Id
WHERE t.Name NOT LIKE '%EZ' 
ORDER BY r.Price DESC

--10. Task

SELECT
    h.Name AS HotelName,
    SUM(r.Price * DATEDIFF(DAY, b.ArrivalDate, b.DepartureDate)) AS TotalRevenue
FROM
    Bookings AS b
INNER JOIN Hotels AS h ON b.HotelId = h.Id
INNER JOIN Rooms AS r ON b.RoomId = r.Id
GROUP BY
    h.Name
ORDER BY
    TotalRevenue DESC;
    
GO

--11. Task

CREATE FUNCTION udf_RoomsWithTourists (@roomType NVARCHAR(80))
RETURNS INT
AS
BEGIN
	DECLARE @TotalTourists INT
	
	SELECT @TotalTourists = SUM(AdultsCount + ChildrenCount)
	FROM Bookings AS b
	INNER JOIN Rooms AS r ON b.RoomId = r.Id
	WHERE r.Type = @roomType
	
	RETURN ISNULL(@TotalTourists, 0)
END

GO

--12. Task

CREATE PROC usp_SearchByCountry(@country NVARCHAR(50))
AS
BEGIN
	SELECT t.Name,
		   t.PhoneNumber,
		   t.Email,
		   ISNULL(COUNT(b.Id), 0) AS CountOfBookings
	FROM Tourists AS t
	INNER JOIN Bookings AS b ON t.Id = b.TouristId
	WHERE t.CountryId = (SELECT Id FROM Countries WHERE Name = @country)
	GROUP BY t.Name, t.PhoneNumber, t.Email
	ORDER BY t.Name, CountOfBookings DESC
END 

EXEC usp_SearchByCountry 'Greece'