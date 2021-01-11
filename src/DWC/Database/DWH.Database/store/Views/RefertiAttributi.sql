


CREATE VIEW [store].[RefertiAttributi]
AS
	SELECT *
	FROM dbo.RefertiAttributi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.RefertiAttributi_Recent


