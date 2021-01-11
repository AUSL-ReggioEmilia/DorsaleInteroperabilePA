

CREATE VIEW [store].[Referti]
AS
	SELECT *
	FROM dbo.Referti_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.Referti_Recent
