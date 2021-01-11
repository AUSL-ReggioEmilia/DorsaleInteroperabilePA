

CREATE VIEW [store].[PrescrizioniAllegati]
AS
	SELECT *
	FROM dbo.PrescrizioniAllegati_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.PrescrizioniAllegati_Recent