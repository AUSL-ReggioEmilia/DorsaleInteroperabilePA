


CREATE VIEW [store].[Prestazioni]
AS
	SELECT *
	FROM dbo.Prestazioni_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.Prestazioni_Recent


