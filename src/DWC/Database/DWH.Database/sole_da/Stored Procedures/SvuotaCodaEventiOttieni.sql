
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-12-05
-- Modify date: 2019-01-15 Rename, cambio schema e refactory
-- Modify date: 2019-02-11 MessaggioXml compresso e AbilitazioniXml binary
--							Usabile via LinkedServer
-- Modify date: 2019-02-25 Rivaluta se RicoveroStatoCodice NULL
-- Modify date: 2019-04-11 Motivo della rimozione
-- Modify date: 2019-05-10 Aggiunto camopo NumeroNosologico alle code
-- Modify date: 2019-06-26 Modificato controllo esistenza XML
-- Modify date: 2020-03-19 Ritorna i dati come parametro di output
--
-- Description:	Svuota la coda di invio eventi a SOLE
-- =============================================
CREATE PROCEDURE [sole_da].[SvuotaCodaEventiOttieni]
(
@IdSequenza INT OUTPUT
, @Proprieta VARBINARY(MAX) OUTPUT
, @Messaggio VARBINARY(MAX) OUTPUT
, @Abilitazioni VARBINARY(MAX) OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	--
	-- Controlla se ci sono dati
	--
	IF EXISTS(SELECT * FROM [sole].[CodaEventi] WITH(NOLOCK))
	BEGIN

		DECLARE @Now DATETIME
		DECLARE @Operazione SMALLINT
		DECLARE @IdEvento UNIQUEIDENTIFIER
		DECLARE @TipoRicoveroCodice VARCHAR(16)
		DECLARE @AziendaErogante VARCHAR(16)
		DECLARE @SistemaErogante VARCHAR(16)
		--
		-- Imposto il livello di serializzazione che verrà usato dalla SP (meno forte di quello di default di BizTalk)
		--
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED

		BEGIN TRANSACTION 
		BEGIN TRY
		--
		-- In caso di recod non valido, lo cancella e ne prende un altro
		--
NEXT_ITEM:

			SET @IdSequenza = NULL
			SET @Operazione = NULL
			SET @IdEvento = NULL
			SET @TipoRicoveroCodice = NULL
			SET @Messaggio = NULL
			SET @AziendaErogante = NULL
			SET @SistemaErogante = NULL
			--
			-- FONDAMENTALE: si deve restituire un solo record per volta
			--
			SELECT TOP 1 @IdSequenza = IdSequenza
						,@Operazione = Operazione
						,@IdEvento = IdEvento
						,@TipoRicoveroCodice = TipoRicoveroCodice
						,@Messaggio = Messaggio
						,@AziendaErogante = AziendaErogante
						,@SistemaErogante = SistemaErogante
			FROM [sole].[CodaEventi] WITH (READPAST, UPDLOCK)
			WHERE
				-- non modificati da N ore
				[DataModificaEvento] < DATEADD(HOUR, [OreRitardoInvio] * -1, GETDATE())

			   	-- se priorità > 7 solo di notte
				AND ([Priorita] <= 7
					OR	(DATEPART(HOUR, GETDATE()) > 19 OR DATEPART(HOUR, GETDATE()) < 7)
					)
			ORDER BY [Priorita], [DataModificaEvento], IdSequenza
			--
			-- Se trovato ma manca il Ricovero codice
			--
			-- RIVALUTO
			--
			DECLARE @Inviabile BIT
			SET @Inviabile = 1

			IF NOT @IdSequenza IS NULL AND (ISNULL(@TipoRicoveroCodice, '') = '')
			BEGIN
				DECLARE @RicoveroStatoCodice TINYINT = 255
				DECLARE @TipoEventoCodice VARCHAR(16) = NULL
				--
				-- Cerca Ricovero codice
				--
				SELECT @TipoRicoveroCodice = r.[TipoRicoveroCodice]
						,@RicoveroStatoCodice = r.[StatoCodice]
						,@TipoEventoCodice = e.[TipoEventoCodice]
				FROM [store].[RicoveriBase] r
					INNER JOIN [store].[EventiBase] e
						ON r.[AziendaErogante] = e.AziendaErogante
						AND r.[NumeroNosologico] = e.NumeroNosologico
				WHERE e.[Id] = @IdEvento
				--
				-- Aggiorno dato mancante
				--
				UPDATE [sole].[CodaEventi]
				SET TipoRicoveroCodice = ISNULL(@TipoRicoveroCodice, '')
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Ricontrollo se inviabile
				-- 2019-04-03
				SET @Inviabile = [sole].[IsEventoInviabile](@TipoEventoCodice, @TipoRicoveroCodice, @RicoveroStatoCodice, 0)
			END
			--
			-- Se non è una cancellazione
			-- Valuto se NON inviabile
			-- Valuto se esiste ancora
			--
			IF NOT @IdSequenza IS NULL
			BEGIN
				-- 2019-06-26
				-- Se non è cancellazione rileggo il messaggio
				--
				IF @Operazione <> 2
				BEGIN
					DECLARE @XmlEventoSole XML		--No set NULL inline
					SET @XmlEventoSole = NULL		--Reset per sicurezza
					SET @XmlEventoSole = [sole].[OttieneEventoXml](@IdEvento)
					SET @Messaggio = dbo.compress(CONVERT(VARBINARY(MAX), @XmlEventoSole))
				END

				IF @Inviabile = 0 OR @Messaggio IS NULL
				BEGIN
					DECLARE @Motivo VARCHAR(64)
					SELECT @Motivo = CASE WHEN @Inviabile = 0 THEN 'Non inviabile'
										WHEN @Messaggio IS NULL THEN 'Messaggio Xml non trovato'
										ELSE NULL END
					--
					-- Non invio e rimuovo dalla coda (salvo in altra)
					--
					INSERT INTO [sole].[CodaEventiRimossi]([Record], [IdEvento], [Motivo])
					VALUES ([dbo].[compress](CONVERT( VARBINARY(MAX), 
											(SELECT *
											FROM [sole].[CodaEventi] Evento
											WHERE [IdSequenza] = @IdSequenza
											FOR XML AUTO, BINARY BASE64, ROOT('SoleCoda'))
							)), @IdEvento, @Motivo)

					DELETE FROM [sole].[CodaEventi] WHERE [IdSequenza] = @IdSequenza
					SET @IdSequenza = NULL
					--
					-- Prende il prossimo record
					--
					GOTO NEXT_ITEM
				END
			END
			--
			-- Se trovato
			--
			IF NOT @IdSequenza IS NULL AND NOT @Messaggio IS NULL
			BEGIN 
				--
				-- Inserisco record nello storico	
				--
				INSERT INTO [sole].[CodaEventiInviati]
					([IdSequenza], [DataInserimento], [IdEvento], [Operazione], [Sorgente]
					, [AziendaErogante], [SistemaErogante], [TipoEventoCodice], [TipoRicoveroCodice], [DataModificaEvento]
					, [Priorita], [OreRitardoInvio], [Messaggio], [NumeroNosologico])
				SELECT [IdSequenza], [DataInserimento], [IdEvento], [Operazione], [Sorgente]
					, [AziendaErogante], [SistemaErogante], [TipoEventoCodice], [TipoRicoveroCodice], [DataModificaEvento]
					, [Priorita], [OreRitardoInvio], @Messaggio, [NumeroNosologico]

				FROM [sole].[CodaEventi]
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Restituisco i DATI
				--
				SET @Proprieta = CONVERT(VARBINARY(MAX), ( SELECT * FROM (
										SELECT [IdSequenza], [DataInserimento], Proprieta.[IdEvento], [Operazione], [Sorgente]
											, [AziendaErogante], [SistemaErogante], [TipoEventoCodice], [TipoRicoveroCodice], [DataModificaEvento]
											, [Priorita], [OreRitardoInvio]

											, o.[Oscurato]
											, ISNULL(o.[Confidenziale], 0) [Confidenziale]
											, [dbo].[IsEventoLiberaProfessione](Proprieta.[IdEvento]) [LiberaProfessione]

										FROM [sole].[CodaEventi] Proprieta
											OUTER APPLY [sole].[OttieniOscuramentiPerEvento](Proprieta.[IdEvento]) o		
										WHERE [IdSequenza] = @IdSequenza) Proprieta

										FOR XML AUTO))

				SET @Abilitazioni = CONVERT(VARBINARY(MAX),
											( SELECT   [Abilitato], [DataInizio], [DataFine], [TipologiaSole]
												, [Mittente], [OreRitardoInvio]
												, [DisabilitaControlloRegime], [DisabilitaControlloInviabile], [DisabilitaControlloConsensi]
												, [Priorita], [CorrelazioneInvio]
												, [InviaOscurati], [InviaConfidenziali], [InviaLiberaProfessione]
											
											FROM [Sole].[AbilitazioniSistemi] Abilitazione

											WHERE TipoErogante = 'Evento'
												AND AziendaErogante = @AziendaErogante
												AND SistemaErogante = @SistemaErogante

											FOR XML AUTO)
											)
				--
				-- Cancello  la restituita
				--
				DELETE FROM [sole].[CodaEventi] WHERE [IdSequenza] = @IdSequenza
			END
			--
			-- Commit delle modifiche
			--
			COMMIT
			RETURN 0

		END TRY
		BEGIN CATCH
			--
			-- Rollback delle modifiche
			--
			ROLLBACK
			--
			-- Raise dell'errore
			--
			DECLARE @xact_state INT
			DECLARE @msg NVARCHAR(2000)
			SELECT @xact_state = xact_state(), @msg = error_message()

			DECLARE @report NVARCHAR(4000);
			SELECT @report = N'[sole_da].[SvuotaCodaEventiOttieni]. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
			RAISERROR(@report, 16, 1)
			PRINT @report;
			
			RETURN 1
		END CATCH

	END ELSE BEGIN
		RETURN 0
	END 

END