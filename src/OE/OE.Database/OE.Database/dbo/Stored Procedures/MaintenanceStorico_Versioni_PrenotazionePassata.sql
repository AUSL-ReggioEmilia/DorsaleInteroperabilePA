
CREATE PROCEDURE [dbo].[MaintenanceStorico_Versioni_PrenotazionePassata]
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
	SELECT @NR_GG_MIN = [GiorniVersioniPrenotazioniPassate] FROM [dbo].[GetArchiviazioneMinima]()

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
		PRINT 'Inizio query selezione versioni com PrenotazionePassata da storicizzare ' + CONVERT(varchar(40), GETDATE(), 120)
	
		DECLARE @IdOrdine uniqueidentifier, @DataModifica datetime2(0), @GiorniArchiviare int
		DECLARE mainCursor CURSOR STATIC READ_ONLY FOR
	
		-- Riferimento agli ordini che sono da storicizzare
		SELECT TOP(@TOP) ot.ID, ot.DataModifica, e.[GiorniVersioniPrenotazioniPassate]
			FROM OrdiniTestate ot WITH(NOLOCK)

				-- Ennupla configurata per Richiedente-Unita operativa-Erogante dei giorni di ritardo
				--
				CROSS APPLY [dbo].[GetEnnupleArchiviazioneRigheRichieste](ot.IdSistemaRichiedente, ot.IDUnitaOperativaRichiedente, ot.Id) e

			-- Primo filtro con il MIN delle date
			--
			WHERE ot.DataModifica <= DATEADD(dd, -@NR_GG_MIN, GETDATE())
					AND ot.DataPrenotazione <= DATEADD(dd, -@NR_GG_MIN, GETDATE())

					-- Filtro con i giorni delle ENNUPLE
					--
					AND	ot.DataModifica <= DATEADD(dd, -e.[GiorniVersioniPrenotazioniPassate], GETDATE())
					AND ot.DataPrenotazione <= DATEADD(dd,-e.[GiorniVersioniPrenotazioniPassate],GETDATE())
	
					--
					-- Ha versioni da archiviare
					--
					AND (
							EXISTS (SELECT * FROM OrdiniVersioni ov WITH(NOLOCK)
									WHERE ov.IDOrdineTestata = ot.Id
											AND ov.DataInserimento <= DATEADD(dd, -e.[GiorniVersioniPrenotazioniPassate], GETDATE())
									)
						OR
							EXISTS (SELECT * FROM OrdiniErogatiVersioni oev WITH(NOLOCK)
													INNER JOIN OrdiniErogatiTestate oet WITH(NOLOCK)
												ON ot.Id = oet.IDOrdineTestata
									WHERE oev.IDOrdineErogatoTestata = oet.Id
											AND oev.DataInserimento <= DATEADD(dd, -e.[GiorniVersioniPrenotazioniPassate], GETDATE())
									)
						)
					
			ORDER BY ot.DataModifica
		
		OPEN mainCursor
		FETCH NEXT FROM mainCursor INTO @IdOrdine, @DataModifica, @GiorniArchiviare
		
		PRINT 'Inizio loop sui versioni da storicizzare ' + CONVERT(varchar(40), GETDATE(), 120)
		PRINT ''
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
		
			IF @DEBUG = 1
			BEGIN
				PRINT '[Debug] Storicizzazione della versioni ' + CAST(@IdOrdine as varchar(max)) + ' del ' + CONVERT(varchar(40), @DataModifica, 120)

			END ELSE BEGIN

				-- Esegue archiviazione
				DECLARE @retValue INT = 0
				EXEC @retValue = [dbo].[MaintenanceStorico_VersioniPerId]  @IdOrdine, @GiorniArchiviare, @LOG
		
				IF @retValue = 0
				BEGIN
					PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione della versioni ' + CAST(@IdOrdine as varchar(max))
							+ ' del ' + CONVERT(varchar(40), @DataModifica, 120)
							+ ' completata con successo.'
				
					SET @TOT_HISTORY_ORDERS = @TOT_HISTORY_ORDERS + 1

				END ELSE BEGIN
				
					--ERRORE 
					PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione della versioni ' + CAST(@IdOrdine as varchar(max)) + ' fallita!'
				END
			END

			-- Altro record
			SET @TOT_ORDERS = @TOT_ORDERS + 1
			
			FETCH NEXT FROM mainCursor INTO @IdOrdine, @DataModifica, @GiorniArchiviare
		END
		CLOSE mainCursor
		DEALLOCATE mainCursor
		
		PRINT ''
		PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione versioni completata. Totale versioni storicizzati ' + CAST(@TOT_HISTORY_ORDERS as varchar(max))
						+ ' su ' + CAST(@TOT_ORDERS as varchar(max))
	END TRY
	BEGIN CATCH
	
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
