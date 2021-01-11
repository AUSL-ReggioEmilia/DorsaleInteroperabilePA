

CREATE VIEW [store].[PrescrizioniAttributi]
AS
	SELECT *
	FROM dbo.PrescrizioniAttributi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.PrescrizioniAttributi_Recent