


CREATE VIEW [store].[AllegatiAttributi]
AS
	SELECT *
	FROM dbo.AllegatiAttributi_History
	
	UNION ALL
	
	SELECT *
	FROM dbo.AllegatiAttributi_Recent


