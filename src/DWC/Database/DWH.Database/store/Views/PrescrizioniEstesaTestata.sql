




CREATE VIEW [store].[PrescrizioniEstesaTestata]
AS
	SELECT *
	FROM dbo.[PrescrizioniEstesaTestata_History]
	
	UNION ALL
	
	SELECT *
	FROM dbo.[PrescrizioniEstesaTestata_Recent]