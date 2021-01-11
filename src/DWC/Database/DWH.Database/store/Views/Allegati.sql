


CREATE VIEW [store].[Allegati]
AS
	SELECT *
	FROM dbo.Allegati_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.Allegati_Recent

