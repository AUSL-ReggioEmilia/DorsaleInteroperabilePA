-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-07-16
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[CompressAllMessaggiRichieste]
AS
BEGIN
	DECLARE @Batch INT = 1000
	DECLARE @Run INT = 0
	
	WHILE EXISTS (SELECT * FROM dbo.compress_MessaggiRichieste WITH(NOLOCK)
			WHERE StatoCompressione = 0)
	BEGIN
		PRINT ''
		PRINT 'Start compression '  + CONVERT(VARCHAR, GETDATE(), 120) 

		EXEC CompressMessaggiRichieste @Batch
		
		PRINT 'Run = '  + CONVERT(VARCHAR, @Run) 
			+ ' - CompressMessaggiRichieste Batch=' + CONVERT(VARCHAR, @Batch)
		PRINT '--End compression '  + CONVERT(VARCHAR, GETDATE(), 120) 
		
		SET @Run = @Run + 1
	END
END
