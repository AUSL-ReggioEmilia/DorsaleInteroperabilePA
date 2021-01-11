

CREATE PROCEDURE [dbo].[MaintenanceRestore_Ordine_PrenotazioneNonScaduta]
  @NR_GG_RESTORE INT=30
, @MAX_ORDERS_HISTORY INT=1000
, @DEBUG BIT=0
, @LOG BIT=0
AS
BEGIN
--MODIFICHE:
-- 2015-02-09 Sandro: Restore delle richieste con prenotazione non scaduta

	SET NOCOUNT ON
	
	-- @@NR_GG_RESTORE
	-- Numero dei giorni che saranno restorati.

	-- Se (@MAX_ORDERS_HISTORY <= 0), non c'è limite
	-- Numero massimo di ordini da storicizzare nel range. 

	SET @NR_GG_RESTORE = CASE WHEN @NR_GG_RESTORE < 1 THEN 1
									ELSE @NR_GG_RESTORE END

	DECLARE @TOP as int
	SET @TOP = CASE WHEN @MAX_ORDERS_HISTORY < 1 THEN 2147483647
									ELSE @MAX_ORDERS_HISTORY END

	-- Contatori
	DECLARE @TOT_ORDERS as int = 0
	DECLARE @TOT_HISTORY_ORDERS as int = 0
	
	BEGIN TRY
		PRINT 'Inizio query Ordini PRENOTAZIONE NON SCADUTA da restorare ' + CONVERT(varchar(40), GETDATE(), 120)

	
		DECLARE @IdOrdine uniqueidentifier
		DECLARE @DataModifica datetime2(0)
		DECLARE @DataPrenotazione datetime2(0)
		
		DECLARE mainCursor CURSOR STATIC READ_ONLY FOR
	
		-- Riferimento agli ordini che sono da storicizzare CON Prenotazione passata anche se non completati
		SELECT TOP (@TOP) ID, DataModifica, DataPrenotazione
			FROM dbo.OrdiniTestate WITH(NOLOCK)
			WHERE DataPrenotazione >= DATEADD(dd,-@NR_GG_RESTORE,GETDATE())
			ORDER BY DataPrenotazione
		
		OPEN mainCursor
		FETCH NEXT FROM mainCursor INTO @IdOrdine, @DataModifica, @DataPrenotazione
		
		PRINT 'Inizio loop su Ordini PRENOTAZIONE NON SCADUTA da restorare ' + CONVERT(varchar(40), GETDATE(), 120)
		PRINT ''
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @DEBUG = 1
			BEGIN
				PRINT '[Debug] Restore della richiesta ' + CAST(@IdOrdine as varchar(max)) + ' del ' + CONVERT(varchar(40), @DataModifica, 120)

			END ELSE BEGIN

				-- Esegue archiviazione
				DECLARE @retValue INT = 0
				EXEC @retValue = [dbo].[MaintenanceRestore_OrdinePerId] @IdOrdine, @LOG
		
				IF @retValue = 0
				BEGIN
					PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Restore della richiesta ' + CAST(@IdOrdine as varchar(max))
							+ ' del ' + CONVERT(varchar(40), @DataModifica, 120)
							+ ' prenotato per  ' + CONVERT(varchar(40), @DataPrenotazione, 120)
							+ ' completata con successo.'
				
					SET @TOT_HISTORY_ORDERS = @TOT_HISTORY_ORDERS + 1

				END ELSE BEGIN
				
					--ERRORE 
					PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Restore della richiesta ' + CAST(@IdOrdine as varchar(max)) + ' fallita!'
				END
			END

			-- Altro record
			SET @TOT_ORDERS = @TOT_ORDERS + 1
			
			FETCH NEXT FROM mainCursor INTO @IdOrdine, @DataModifica, @DataPrenotazione
		END
		CLOSE mainCursor
		DEALLOCATE mainCursor
		
		PRINT ''
		PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Restore completata. Totale ordini restorati ' + CAST(@TOT_HISTORY_ORDERS as varchar(max)) + ' su ' + CAST(@TOT_ORDERS as varchar(max))
	END TRY
	BEGIN CATCH
	
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END
