

CREATE VIEW [dbo].[DatabaseLogLastObjectChanged]
AS
	SELECT TOP 1000 
		MAX([PostTime]) AS [PostTime]
		,[Event]
		,[Object]
	FROM [dbo].[DatabaseLogTsql]
	GROUP BY [Object],[Event]
	ORDER BY MAX([PostTime]) DESC
