CREATE DATABASE [Minions]

USE [Minions]

CREATE TABLE [Minions] (
	 [Id] INT PRIMARY KEY
	,[Name] NVARCHAR(50) NOT NULL
	,[Age] INT NOT NULL
)

CREATE TABLE [Towns] (
	 [Id] INT PRIMARY KEY
	,[Name] NVARCHAR(70) NOT NULL
)

ALTER TABLE [Minions]
ADD [TownId] INT FOREIGN KEY REFERENCES [Towns]([Id])NOT NULL

ALTER TABLE [Minions]
ALTER COLUMN [Age] INT

--4

GO

INSERT INTO [Towns]([Id], [Name])
	VALUES
(1, 'Sofia'),
(2, 'Plovdiv'),
(3, 'Varna')

INSERT INTO [Minions]([Id], [Name], [Age], [TownId])
	VALUES
(1, 'Kevin', 22, 1),
(2, 'Bob', 15, 3),
(3, 'Steward', NULL, 2)

GO

TRUNCATE TABLE [Minions]

--7

CREATE TABLE [People]
(
	 [Id] INT PRIMARY KEY IDENTITY
	,[Name] NVARCHAR(200) NOT NULL
	,[Picture] VARBINARY(MAX)
	 CHECK (DATALENGTH([Picture]) <= 2000000)
	,[Height] DECIMAL(3,2)
	,[Weight] DECIMAL(5,2)
	,[Gender] CHAR(1) NOT NULL
	CHECK([Gender] = 'm' OR [Gender] = 'f')
	,[Birthdate] DATE NOT NULL
	,[Biography] NVARCHAR(MAX)
)

INSERT INTO [People]([Name], [Height],[Weight],[Gender],[Birthdate])
	VALUES
('Stephanie', 1.65, 57.3, 'f', '2001-12-08')
,('Nikolay' , 1.83, 81.1, 'm', '1987-06-13')
,('Ivan' , 1.80, 85.7, 'm', '1968-03-17')
,('Gabriela' , NULL, NULL, 'f', '1980-09-27')
,('Hristina' , 1.69, 60.4, 'f', '1998-11-05')

--8

CREATE TABLE [Users]
(
	 [Id] INT PRIMARY KEY IDENTITY
	,[Username] VARCHAR(30)
	,[Password] VARCHAR (26)
	,[ProfilePicture] VARBINARY (MAX)
	CHECK (DATALENGTH([ProfilePicture]) <= 900000)
	,[LastLoginTime] DATE
	,[IsDeleted] BIT NOT NULL
)

INSERT INTO [Users] ([Username], [Password],[IsDeleted])
	VALUES
('TheBest', 'numberone', 1)
,('monster' , 'jashda' , 0)
,('Hacker', 'impossible', 1)
,('FallenAngel' , 'tattoolover' , 0)
,('Shadow' , 'ghost' , 1)

--13

CREATE TABLE [Directors]
(
	 [Id] INT PRIMARY KEY IDENTITY
	,[DirectorName] VARCHAR(50) NOT NULL
	,[Notes] NVARCHAR(500)
)

CREATE TABLE [Genres]
(
	 [Id] INT PRIMARY KEY IDENTITY
	,[GenreName] VARCHAR (50) NOT NULL
	,[Notes] NVARCHAR (500)
)

CREATE TABLE [Categories]
(
	 [Id] INT PRIMARY KEY IDENTITY
	,[CategoryName] VARCHAR (50) NOT NULL
	,[Notes] NVARCHAR (500)
)

CREATE TABLE [Movies]
(
	 [Id] INT PRIMARY KEY IDENTITY
	,[Title] VARCHAR(50) NOT NULL
	,[DirectorId] INT FOREIGN KEY REFERENCES [Directors](Id) NOT NULL
	,[CopyrightYear] INT NOT NULL
	,[Length] TIME NOT NULL
	,[GenreId] INT FOREIGN KEY REFERENCES [Genres](Id) NOT NULL
	,[CategoryId] INT FOREIGN KEY REFERENCES [Categories](Id) NOT NULL
	,[Rating] DECIMAL (2,1) NOT NULL
	,[Notes] NVARCHAR(500)
)

INSERT INTO [Directors]
	VALUES	
('Brian Williams', NULL),
('Isabel Robinson' , NULL),
('Nathaniel Walker', NULL),
('Claude Martin' , NULL),
('Lauren Smith', NULL)

INSERT INTO [Genres] 
	VALUES
('Action', NULL),
('Horror', NULL),
('Triler', NULL),
('Fantasy' , NULL),
('Comedy', NULL)

INSERT INTO [Categories] 
	VALUES
('Short', NULL),
('TV' , NULL),
('Documentary', NULL),
('Long', NULL),
('Biography', NULL)

INSERT INTO [Movies]
	VALUES
('The Shawshank Redemption', 1, 1994, '02:22:00', 2, 3, 9.4, NULL),
('The Godfather', 2, 1972, '02:55:00', 3, 4, 9.2, NULL),
('Schindler`s List', 3, 1993, '03:15:00', 4, 5, 9.0, NULL),
('Pulp Fiction', 4, 1994, '02:34:00', 5, 1, 8.9, NULL),
('Fight Club', 5, 1999, '02:19:00', 1, 2, 8.8, NULL)
