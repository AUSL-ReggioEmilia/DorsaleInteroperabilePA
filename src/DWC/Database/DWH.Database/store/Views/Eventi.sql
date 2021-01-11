


CREATE VIEW [store].[Eventi]
AS
	SELECT *
	FROM dbo.Eventi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.Eventi_Recent



