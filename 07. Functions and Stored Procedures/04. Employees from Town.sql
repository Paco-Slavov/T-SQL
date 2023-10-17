CREATE PROCEDURE [usp_GetEmployeesFromTown] @townName VARCHAR(50)
		AS
		BEGIN
				SELECT [e].[FirstName],
					   [e].[LastName]
				FROM [Employees]
				  AS [e]
				INNER JOIN[Addresses]
				  AS [a]
				  ON [e].[AddressID] = [a].[AddressID]
				INNER JOIN[Towns]
				  AS [t]
				  ON [a].[TownID] = [t].[TownID]
				WHERE [t].[Name] = @townName
		END
		
EXEC [dbo].[usp_GetEmployeesFromTown] 'Monroe'