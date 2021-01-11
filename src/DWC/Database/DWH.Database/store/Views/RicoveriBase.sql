


CREATE VIEW [store].[RicoveriBase]
AS
	SELECT *
	FROM dbo.RicoveriBase_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.RicoveriBase_Recent


