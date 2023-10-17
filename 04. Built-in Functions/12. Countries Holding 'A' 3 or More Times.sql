SELECT [CountryName]
	AS [Country Name],
		[ISOCode]
	AS  [ISO CODE]
	FROM [Countries]
	WHERE LOWER([CountryName]) LIKE '%a%a%a%'
ORDER BY [ISO Code]