

CREATE VIEW [store].[Prescrizioni]
AS
	SELECT *
	FROM dbo.Prescrizioni_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.Prescrizioni_Recent