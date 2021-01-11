

CREATE VIEW [store].[PrescrizioniBase]
AS
	SELECT *
	FROM dbo.PrescrizioniBase_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.PrescrizioniBase_Recent