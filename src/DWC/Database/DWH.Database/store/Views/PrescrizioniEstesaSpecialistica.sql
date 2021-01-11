
CREATE VIEW [store].[PrescrizioniEstesaSpecialistica]
AS
	SELECT *
	FROM dbo.[PrescrizioniEstesaSpecialistica_History]
	
	UNION ALL
	
	SELECT *
	FROM dbo.[PrescrizioniEstesaSpecialistica_Recent]