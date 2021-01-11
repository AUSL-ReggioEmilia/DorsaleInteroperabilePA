

CREATE VIEW [dbo].[DatabaseLogLastObjectChanged]
AS
	SELECT TOP 1000 
		MAX([PostTime]) AS [PostTime]
		,[Event]
		,[Schema]
		,[Object]
	FROM [dbo].[DatabaseLogTsql]
	GROUP BY [Object],[Event],[Schema]
	ORDER BY MAX([PostTime]) DESC
	
