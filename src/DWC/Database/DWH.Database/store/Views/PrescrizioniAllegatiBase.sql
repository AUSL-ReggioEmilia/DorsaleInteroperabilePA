

CREATE VIEW [store].[PrescrizioniAllegatiBase]
AS
	SELECT *
	FROM dbo.PrescrizioniAllegatiBase_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.PrescrizioniAllegatiBase_Recent