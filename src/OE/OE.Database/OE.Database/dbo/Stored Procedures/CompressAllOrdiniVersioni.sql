
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-03-10
-- Description:	LOOP su Comprime dati XML dello storico
-- =============================================
CREATE PROCEDURE[dbo].[CompressAllOrdiniVersioni]
AS
BEGIN
	DECLARE @Batch INT = 1000
	DECLARE @Run INT = 0
	
	WHILE EXISTS (SELECT * FROM dbo.OrdiniVersioni WITH(NOLOCK)
			WHERE StatoCompressione = 0)
	BEGIN
		PRINT ''
		PRINT 'Start compression '  + CONVERT(VARCHAR, GETDATE(), 120) 

		EXEC dbo.CompressOrdiniVersioni @Batch
		
		PRINT 'Run = '  + CONVERT(VARCHAR, @Run) 
			+ ' - CompressOrdiniVersioni Batch=' + CONVERT(VARCHAR, @Batch)
		PRINT '--End compression '  + CONVERT(VARCHAR, GETDATE(), 120) 
		
		SET @Run = @Run + 1
	END
END
