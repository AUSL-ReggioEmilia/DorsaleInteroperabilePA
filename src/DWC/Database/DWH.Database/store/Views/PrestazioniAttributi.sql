


CREATE VIEW [store].[PrestazioniAttributi]
AS
	SELECT *
	FROM dbo.PrestazioniAttributi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.PrestazioniAttributi_Recent


