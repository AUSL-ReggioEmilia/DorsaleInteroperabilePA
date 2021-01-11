

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-01-17
-- Description:	Storicizza il db order entry
-- =============================================
CREATE PROCEDURE [dbo].[MaintenanceCancella_MessaggiRichiesteOrfani]
 @NR_GG_NO_HISTORY INT=7
,@BATCH_SIZE INT=1000
AS
BEGIN
-- Modifiche:
-- 2013-01-17 Sandro: Primo rilascio 
-- 2020-04-22 Sandro: Review 

	SET NOCOUNT ON
		
	DECLARE @DEBUG bit = 0
	
	-- @NR_GG_NO_HISTORY
	-- Totale dei giorni che non saranno storicizzati.
	--
	SET @NR_GG_NO_HISTORY = CASE WHEN @NR_GG_NO_HISTORY < 1 THEN 1
									ELSE @NR_GG_NO_HISTORY END

	-- Se (@BATCH_SIZE <= 0), non c'è limite
	-- Numero massimo di ordini da storicizzare nel range. 
	--
	DECLARE @TOP as int
	SET @TOP = CASE WHEN @BATCH_SIZE < 1 THEN 2147483647
									ELSE @BATCH_SIZE END
	
	-- Contatori
	DECLARE @TOT_ORDERS as int = 0

	BEGIN TRY
	
		DELETE TOP (@TOP) [dbo].[MessaggiRichieste]
		WHERE DataInserimento <= DATEADD(dd,-@NR_GG_NO_HISTORY,GETDATE())
			AND IDOrdineTestata IS NULL
	
		SET @TOT_ORDERS = @@ROWCOUNT
	END TRY
	BEGIN CATCH
	
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
	PRINT '[' + cast(getdate() as varchar(30)) + '] Cancellazione completata. Totale MessaggiRichieste eliminati '
			 + cast(@TOT_ORDERS as varchar(10))
END


