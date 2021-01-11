


CREATE VIEW [store].[PrescrizioniEstesaFarmaceutica]
AS
	SELECT *
	FROM dbo.[PrescrizioniEstesaFarmaceutica_History]
	
	UNION ALL
	
	SELECT *
	FROM dbo.[PrescrizioniEstesaFarmaceutica_Recent]