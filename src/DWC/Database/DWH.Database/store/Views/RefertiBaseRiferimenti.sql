


CREATE VIEW [store].[RefertiBaseRiferimenti]
AS
	SELECT *
	FROM dbo.RefertiBaseRiferimenti_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.RefertiBaseRiferimenti_Recent
	


