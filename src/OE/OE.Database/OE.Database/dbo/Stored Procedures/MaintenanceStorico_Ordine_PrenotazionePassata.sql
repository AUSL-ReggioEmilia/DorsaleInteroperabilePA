
CREATE PROCEDURE [dbo].[MaintenanceStorico_Ordine_PrenotazionePassata]
 @BATCH_SIZE INT=1000
,@DEBUG BIT=0
,@LOG BIT=0
AS
BEGIN
--MODIFICHE:
-- 2013-01-17 Sandro: Primo rilascio 
-- 2014-11-19 Sandro: Nuova Func che tiene conto degli errati
-- 2020-04-21 Sandro: Ennuple di giorni di archiviazione

	SET NOCOUNT ON

	-- Giorni minimi per un prefiltro
	--
	DECLARE @NR_GG_MIN INT
	SELECT @NR_GG_MIN = [GiorniOrdiniPrenotazioniPassate] FROM [dbo].[GetArchiviazioneMinima]()

	-- Se (@BATCH_SIZE <= 0), non c'è limite
	-- Numero massimo di ordini da storicizzare nel range. 
	--
	DECLARE @TOP as int
	SET @TOP = CASE WHEN @BATCH_SIZE < 1 THEN 2147483647
									ELSE @BATCH_SIZE END

	-- Contatori
	DECLARE @TOT_ORDERS as int = 0
	DECLARE @TOT_HISTORY_ORDERS as int = 0
	
	BEGIN TRY
		PRINT 'Inizio query Ordini PRENOTAZIONE PASSATA da storicizzare ' + CONVERT(varchar(40), GETDATE(), 120)
	
		DECLARE @IdOrdine uniqueidentifier, @DataModifica datetime2(0)
		DECLARE mainCursor CURSOR STATIC READ_ONLY FOR
	
		-- Riferimento agli ordini che sono da storicizzare CON Prenotazione passata anche se non completati
		SELECT TOP (@TOP) o.ID, o.DataModifica
			FROM OrdiniTestate o WITH(NOLOCK)

				-- Ennupla configurata per Richiedente-Unita operativa-Erogante dei giorni di ritardo
				--
				CROSS APPLY [dbo].[GetEnnupleArchiviazioneRigheRichieste](o.IdSistemaRichiedente, o.IDUnitaOperativaRichiedente, o.Id) e

			-- Primo filtro con il MIN delle date
			--
			WHERE o.DataModifica <= DATEADD(dd, -@NR_GG_MIN, GETDATE())
					AND o.DataPrenotazione <= DATEADD(dd, -@NR_GG_MIN, GETDATE())

					-- Filtro con i giorni delle ENNUPLE
					--
					AND	o.DataModifica <= DATEADD(dd, -e.[GiorniOrdiniPrenotazioniPassate], GETDATE())
					AND o.DataPrenotazione <= DATEADD(dd,-e.[GiorniOrdiniPrenotazioniPassate],GETDATE())

			ORDER BY o.DataModifica
		
		OPEN mainCursor
		FETCH NEXT FROM mainCursor INTO @IdOrdine, @DataModifica
		
		PRINT 'Inizio loop su Ordini PRENOTAZIONE PASSATA  da storicizzare ' + CONVERT(varchar(40), GETDATE(), 120)
		PRINT ''
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @DEBUG = 1
			BEGIN
				PRINT '[Debug] Storicizzazione della richiesta ' + CAST(@IdOrdine as varchar(max)) + ' del ' + CONVERT(varchar(40), @DataModifica, 120)

			END ELSE BEGIN

				-- Esegue archiviazione
				DECLARE @retValue INT = 0
				EXEC @retValue = [dbo].[MaintenanceStorico_OrdinePerId] @IdOrdine, @DEBUG, @LOG
		
				IF @retValue = 0
				BEGIN
					PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione della richiesta ' + CAST(@IdOrdine as varchar(max))
							+ ' del ' + CONVERT(varchar(40), @DataModifica, 120)
							+ ' completata con successo.'
				
					SET @TOT_HISTORY_ORDERS = @TOT_HISTORY_ORDERS + 1

				END ELSE BEGIN
				
					--ERRORE 
					PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione della richiesta ' + CAST(@IdOrdine as varchar(max)) + ' fallita!'
				END
			END

			-- Altro record
			SET @TOT_ORDERS = @TOT_ORDERS + 1
			
			FETCH NEXT FROM mainCursor INTO @IdOrdine, @DataModifica
		END
		CLOSE mainCursor
		DEALLOCATE mainCursor
		
		PRINT ''
		PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione completata. Totale ordini storicizzati ' + CAST(@TOT_HISTORY_ORDERS as varchar(max)) + ' su ' + CAST(@TOT_ORDERS as varchar(max))
	END TRY
	BEGIN CATCH
	
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
