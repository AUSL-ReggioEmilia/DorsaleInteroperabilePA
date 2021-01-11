

CREATE VIEW [store].[PrescrizioniAllegatiAttributi]
AS
	SELECT *
	FROM dbo.PrescrizioniAllegatiAttributi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.PrescrizioniAllegatiAttributi_Recent