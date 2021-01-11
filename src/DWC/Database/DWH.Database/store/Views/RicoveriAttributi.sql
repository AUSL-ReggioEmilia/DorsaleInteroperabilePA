


CREATE VIEW [store].[RicoveriAttributi]
AS
	SELECT *
	FROM dbo.RicoveriAttributi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.RicoveriAttributi_Recent


