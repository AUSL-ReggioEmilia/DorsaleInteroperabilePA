


CREATE VIEW [store].[EventiBase]
AS
	SELECT *
	FROM dbo.EventiBase_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.EventiBase_Recent


