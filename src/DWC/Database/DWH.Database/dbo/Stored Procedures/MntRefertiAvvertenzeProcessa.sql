





-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-25
-- Description:	Processa la coda dei referti per i quali bisogna calcolare le avvertenze
--				Utilizza la dbo.MntRefertiAvvertenzeCodaOttieni per ottenere i dati dalla coda
--				Se c'è un errore inserisce in dbo.RefertiAvvertenzeCodaProcessateErrore
--				Se c'è un errore nella MntRefertiAvvertenzeCalcola() inserisce in dbo.RefertiAvvertenzeCodaProcessateErrore
--				e processa l'avvertenza successiva
-- =============================================
CREATE PROCEDURE [dbo].[MntRefertiAvvertenzeProcessa]
(
 @NoInformation BIT = 1
,@BatchSize INT = 1000
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @SeparatoreAvvertenze VARCHAR(1) = '|'
	DECLARE @CountTotali INT = 0
	-----------------------------------------------
	DECLARE @DataProcessoUtc DATETIME2
	DECLARE @IdSequenza INT
	DECLARE @IdReferto UNIQUEIDENTIFIER
	DECLARE @DataInserimentoUtc DATETIME2
	--Dati del referto 
	DECLARE @RefertoAvvertenze VARCHAR(8000) --memorizza tutte le avvertenze associate ad un singolo referto 
	DECLARE @RefertoAziendaErogante VARCHAR(16)
	DECLARE @RefertoSistemaErogante VARCHAR(16)
	DECLARE @RefertoDataPartizione SMALLDATETIME
	--Tabella temporanea delle avvertenze: memorizza le avvertenze in ordine di priorità
	DECLARE @TempTab_RefertiAvvertenze TABLE (Id UNIQUEIDENTIFIER, Query VARCHAR(MAX), Severita TINYINT, Risultato VARCHAR(1024))  
	DECLARE @IdRefertiAvvertenze UNIQUEIDENTIFIER
	DECLARE @AvvertenzeQuery VARCHAR(MAX)
	DECLARE @AvvertenzeSeverita TINYINT 
	DECLARE @AvvertenzeRisultato VARCHAR(1024)
	--------------------------------------------------------
	DECLARE @AvvertenzeSeveritaMAX TINYINT --memorizza la severità massima associata al blocco delle avvertenze per un referto 

	BEGIN TRY
		--
		-- Leggo il primo referto in coda
		--
		EXEC [dbo].[MntRefertiAvvertenzeCodaOttieni] 
						@DataProcessoUtc = @DataProcessoUtc OUTPUT
						, @IdSequenza = @IdSequenza			OUTPUT
						, @IdReferto = @IdReferto			OUTPUT
						, @DataInserimentoUtc = @DataInserimentoUtc OUTPUT
		--
		-- Se ho letto un referto dalla coda processa i dati del referto
		--
		WHILE (NOT @IdReferto IS NULL)
		BEGIN
			-- Log referto corrente
			IF @NoInformation = 0
			BEGIN
				PRINT CONVERT(VARCHAR(20), GETDATE(), 120)
						+ ' IdReferto: '	+ CONVERT(VARCHAR(40), @IdReferto)
						+ ' DataInserimentoUtc: ' + CONVERT(VARCHAR(20), @DataInserimentoUtc, 120)
			END

			-- Reset delle variabili -------------------------------------------
			SET @RefertoAvvertenze = ''
			SET @AvvertenzeSeverita = NULL
			SET @IdRefertiAvvertenze = NULL
			DELETE FROM @TempTab_RefertiAvvertenze
			SET @RefertoAziendaErogante = NULL
			SET @RefertoSistemaErogante = NULL
			SET @RefertoDataPartizione = NULL
			SET @AvvertenzeSeveritaMAX = 0
			---------------------------------------------------------------------

			-- Leggo i dati del referto 
			SELECT 
				@RefertoAziendaErogante = AziendaErogante 
				, @RefertoSistemaErogante = SistemaErogante 
				, @RefertoDataPartizione = DataPartizione
			FROM 
				store.RefertiBase WHERE Id= @IdReferto

			--
			-- Devo trovare nella tabella di configurazione delle avvertenze tutte le avvertenze abilitate associate al tipo di referto 
			-- Popolo la tabella @TempTab_RefertiAvvertenze
			--
			INSERT INTO @TempTab_RefertiAvvertenze (Id, Query, Severita, Risultato)
			SELECT 
				Id, Query, Severita, Risultato
			FROM 
				RefertiAvvertenze 
			WHERE AziendaErogante = @RefertoAziendaErogante 
				AND SistemaErogante = @RefertoSistemaErogante 
				AND Abilitata = 1 
			ORDER BY Priorita ASC --0 -> priorità maggiore

			--
			-- Inizio il loop sulle avvertenze
			--
			-- Leggo la prima avvertenza dalla tabella @TempTab_RefertiAvvertenze già ordinata per priorità
			SELECT TOP 1 
				@IdRefertiAvvertenze = Id 
				, @AvvertenzeQuery = Query
				, @AvvertenzeSeverita = Severita
				, @AvvertenzeRisultato = Risultato 
			FROM @TempTab_RefertiAvvertenze

			WHILE (NOT @IdRefertiAvvertenze IS NULL)
			BEGIN
				DECLARE @Avvertenza VARCHAR(1024) 
				SET @Avvertenza = ''

				BEGIN TRY
					-- Per ogni avvertenza eseguo la MntRefertiAvvertenzeCalcola
					EXEC dbo.MntRefertiAvvertenzeCalcola @IdReferto, @IdRefertiAvvertenze, @AvvertenzeQuery, @AvvertenzeRisultato, @Avvertenza OUTPUT 
					
					--Scrivo il risultato dell'avvertenza corrente
					IF ISNULL(@Avvertenza, '') <> ''
						PRINT '    @IdRefertiAvvertenze: ' + CAST(@IdRefertiAvvertenze AS VARCHAR(40)) +  '  Avvertenza: ' + @Avvertenza

				END TRY
				BEGIN CATCH
					--Segnalo comunque un errore nella tabella degli errori, ma vado avanti
					DECLARE @xact_state0 INT
					DECLARE @msg0 NVARCHAR(2000)
					SELECT @xact_state0 = xact_state(), @msg0 = error_message()

					DECLARE @ErrMessage0 NVARCHAR(4000);
					SELECT @ErrMessage0 = N'MntRefertiAvvertenzeCalcola. In catch: ' + @msg0 
											+ N' xact_state:' + cast(@xact_state0 AS NVARCHAR(5))
											+ N' @IdRefertiAvvertenze:' + CAST(@IdRefertiAvvertenze AS varchar(40))
					-- Scrivo l'errore 
					PRINT CONVERT(VARCHAR(20), GETDATE(), 120) +' Errore: ' + CHAR(13) + CHAR(10) + @ErrMessage0
					-- Scrivo l'errore nella tabella "RefertiAvvertenzeCodaProcessateErrore"
					INSERT INTO dbo.RefertiAvvertenzeCodaProcessateErrore(DataProcessoUtc,IdSequenza,IdReferto,DataInserimentoUtc,Errore)
					VALUES (@DataProcessoUtc, @IdSequenza, @IdReferto, @DataInserimentoUtc, @ErrMessage0 )

					SET @Avvertenza = ''
				END CATCH 

				--Concateno le avvertenze con il separatore				
				IF ISNULL(@Avvertenza, '') <> ''
				BEGIN
					SET @RefertoAvvertenze = @RefertoAvvertenze + @Avvertenza + @SeparatoreAvvertenze
					IF @AvvertenzeSeveritaMAX < @AvvertenzeSeverita 
						SET @AvvertenzeSeveritaMAX = @AvvertenzeSeverita 
				END 
				
				--Cancello dalla tabella temporanea delle avvertenze associate al tipo di referto l'avvertenza appena processata  
				DELETE FROM @TempTab_RefertiAvvertenze WHERE Id = @IdRefertiAvvertenze

				--FONDAMENTALE: resetto @IdRefertiAvvertenze  altrimenti dopo che è stato letto l'ultimo 
				--				record la variabile rimane valorizzata e il WHILE diventa infinito
				SET @IdRefertiAvvertenze = NULL 

				--Ricavo l'avvertenza successiva del referto 
				SELECT TOP 1 
					@IdRefertiAvvertenze = Id 
					, @AvvertenzeQuery = Query
					, @AvvertenzeSeverita = Severita
					, @AvvertenzeRisultato = Risultato 
				FROM @TempTab_RefertiAvvertenze

			END 

			-- Inserimento attributo "Dwh@Avvertenze" e "Dwh@AvvertenzeSeverita" 
			IF ISNULL(@RefertoAvvertenze, '') <> ''
			BEGIN
				--Tolgo il separatore
				IF RIGHT(@RefertoAvvertenze, LEN(@SeparatoreAvvertenze)) = @SeparatoreAvvertenze 
					SET @RefertoAvvertenze = LEFT(@RefertoAvvertenze, LEN(@RefertoAvvertenze) - LEN(@SeparatoreAvvertenze))
				--
				-- Inizio transazione
				--
				BEGIN TRANSACTION
				--Cancello per sicurezza gli attributi che vado ad inserire; in realta non dovrebbero esserci perchè cancellati a seguito di un aggiornamento
				DELETE FROM store.RefertiAttributi 
				WHERE IdRefertiBase = @IdReferto 
					AND DataPartizione = @RefertoDataPartizione 
					AND Nome IN ('Dwh@Avvertenze', 'Dwh@AvvertenzeSeverita')
				OPTION(RECOMPILE)

				--Inserimento degli attributi
				INSERT INTO store.RefertiAttributi(IdRefertiBase, Nome,Valore,DataPartizione)
				VALUES (@IdReferto , 'Dwh@Avvertenze', @RefertoAvvertenze, @RefertoDataPartizione)
				INSERT INTO store.RefertiAttributi(IdRefertiBase, Nome,Valore,DataPartizione)
				VALUES (@IdReferto , 'Dwh@AvvertenzeSeverita', @AvvertenzeSeveritaMAX, @RefertoDataPartizione)
				--
				-- Commit della transazione
				--
				COMMIT
			END
			--
			-- Prossimo record
			--
			SET @CountTotali = @CountTotali + 1
			IF @BatchSize > @CountTotali 
			BEGIN
				--
				-- Legge dalla coda
				--
				SET @IdReferto = NULL
				SET @DataInserimentoUtc = NULL

				EXEC [dbo].[MntRefertiAvvertenzeCodaOttieni] 
							@DataProcessoUtc = @DataProcessoUtc OUTPUT
							, @IdSequenza = @IdSequenza			OUTPUT
							, @IdReferto = @IdReferto			OUTPUT
							, @DataInserimentoUtc = @DataInserimentoUtc OUTPUT
			END
		END
	END TRY  
	BEGIN CATCH 
		--
		-- ROLLBACK
		--
		IF @@TRANCOUNT > 0 
			ROLLBACK

		-- Memorizzo l'errore
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @ErrMessage NVARCHAR(4000);
		SELECT @ErrMessage = N'MntRefertiAvvertenzeProcessa. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));

		-- Scrivo l'errore 
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120) +' Errore: ' + CHAR(13) + CHAR(10) + @ErrMessage 

		-- Scrivo l'errore nella tabella "RefertiAvvertenzeCodaProcessateErrore"
		INSERT INTO dbo.RefertiAvvertenzeCodaProcessateErrore(DataProcessoUtc,IdSequenza,IdReferto,DataInserimentoUtc,Errore)
		VALUES (@DataProcessoUtc, @IdSequenza, @IdReferto, @DataInserimentoUtc, @ErrMessage )

	END CATCH


	--Segnalazione del numero di referti processati
	IF @NoInformation = 0
	BEGIN
		PRINT ''
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ' Numero Referti Processati: '	+ CONVERT(VARCHAR(10), @CountTotali)
	END
END