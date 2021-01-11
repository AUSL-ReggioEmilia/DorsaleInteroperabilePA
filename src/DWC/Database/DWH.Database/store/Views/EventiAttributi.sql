



CREATE VIEW [store].[EventiAttributi]
AS
	SELECT *
	FROM dbo.EventiAttributi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.EventiAttributi_Recent


