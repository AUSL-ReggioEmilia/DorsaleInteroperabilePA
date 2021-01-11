


CREATE VIEW [store].[PrestazioniBase]
AS
	SELECT *
	FROM dbo.PrestazioniBase_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.PrestazioniBase_Recent


