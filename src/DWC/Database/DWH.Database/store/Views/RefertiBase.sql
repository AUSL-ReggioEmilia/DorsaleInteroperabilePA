



CREATE VIEW [store].[RefertiBase]
AS
	SELECT *
	FROM dbo.RefertiBase_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.RefertiBase_Recent


