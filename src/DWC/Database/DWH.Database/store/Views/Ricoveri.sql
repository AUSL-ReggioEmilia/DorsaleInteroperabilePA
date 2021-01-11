

CREATE VIEW [store].[Ricoveri]
AS
	SELECT *
	FROM dbo.Ricoveri_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.Ricoveri_Recent



