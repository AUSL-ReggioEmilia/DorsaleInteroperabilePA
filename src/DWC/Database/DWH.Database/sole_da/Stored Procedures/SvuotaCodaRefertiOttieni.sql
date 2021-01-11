
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-12-05
-- Modify date: 2019-01-15 Rename, cambio schema e refactory
-- Modify date: 2019-02-11 MessaggioXml compresso e AbilitazioniXml binary
--							Usabile via LinkedServer
-- Modify date: 2019-04-11 Motivo della rimozione
-- Modify date: 2019-05-10 Aggiunto camopo NumeroNosologico alle code
-- Modify date: 2019-06-26 Modificato controllo esistenza XML
-- Modify date: 2020-03-19 Ritorna i dati come parametro di output
-- Modify date: 2020-03-31 Aggiunto controllo Prestazioni per ByPass Blocchi
--
-- Description:	Svuota la coda di invio Referti a SOLE
-- =============================================
CREATE PROCEDURE [sole_da].[SvuotaCodaRefertiOttieni]
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
	IF EXISTS(SELECT * FROM [sole].[CodaReferti] WITH(NOLOCK))
	BEGIN

		DECLARE @Now DATETIME
		DECLARE @Operazione SMALLINT
		DECLARE @IdReferto UNIQUEIDENTIFIER
		DECLARE @AziendaErogante VARCHAR(16)
		DECLARE @SistemaErogante VARCHAR(16)
		DECLARE @DisabilitaControlliBloccoInvio BIT
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
			SET @Messaggio = NULL
			SET @Now = NULL
			SET @Operazione = NULL
			SET @IdReferto = NULL
			SET @AziendaErogante = NULL
			SET @SistemaErogante = NULL

			-- Default non disabilita
			--
			SET @DisabilitaControlliBloccoInvio = 0
			--
			-- FONDAMENTALE: si deve restituire un solo record per volta
			--
			SELECT TOP 1 @IdSequenza = IdSequenza
						,@Operazione = Operazione
						,@IdReferto = IdReferto
						,@Messaggio = Messaggio
						,@AziendaErogante = AziendaErogante
						,@SistemaErogante = SistemaErogante
			FROM [sole].[CodaReferti] WITH (READPAST, UPDLOCK)
			WHERE
				-- non modificati da N ore
				[DataModificaReferto] < DATEADD(HOUR, [OreRitardoInvio] * -1, GETDATE())

			   	-- se priorità > 7 solo di notte
				AND ([Priorita] <= 7
					OR	(DATEPART(HOUR, GETDATE()) > 19 OR DATEPART(HOUR, GETDATE()) < 7)
					)
			ORDER BY [Priorita], [DataModificaReferto], [IdSequenza]
			
			--
			-- Recupero altri dati (XML se serve)
			--
			IF NOT @IdSequenza IS NULL
			BEGIN
				-- 2019-06-26
				-- Se non è cancellazione rileggo il messaggio
				--
				IF @Operazione <> 2
				BEGIN
					--
					-- Leggo dati ControlloPrestazioni da @Messaggio
					--
					IF NOT @Messaggio IS NULL
					BEGIN
						DECLARE @XmlControllo XML
						SET @XmlControllo = CONVERT(XML, dbo.decompress(@Messaggio))
						--
						-- Se trovate, setto DisabilitaControlliBloccoInvio
						--
						IF ISNULL(@XmlControllo.value('ControlloPrestazioni[1]/@Trovati', 'INT'), 0) > 0
							SET @DisabilitaControlliBloccoInvio = @XmlControllo.value('ControlloPrestazioni[1]/@DisabilitaControlliBloccoInvio', 'BIT')
					
					END -- not Messaggio IS NULL
					--
					-- XML del referto dal DB
					--
					DECLARE @XmlRefertoSole XML		--No set NULL inline
					SET @XmlRefertoSole = NULL		--Reset per sicurezza

					SET @XmlRefertoSole = [sole].[OttieneRefertoXml](@IdReferto)
					SET @Messaggio = dbo.compress(CONVERT(VARBINARY(MAX), @XmlRefertoSole))
				END
				--
				-- Controllo xml
				--
				IF @Messaggio IS NULL
				BEGIN
					--
					-- Non invio e rimuovo dalla coda (salvo in altra)
					--
					INSERT INTO [sole].[CodaRefertiRimossi]([Record], [IdReferto], [Motivo])
					VALUES ([dbo].[compress](CONVERT( VARBINARY(MAX), 
											(SELECT *
											FROM [sole].[CodaReferti] Referto
											WHERE [IdSequenza] = @IdSequenza
											FOR XML AUTO, ROOT('SoleCoda'))
							)), @IdReferto, 'Messaggio Xml non trovato')

					DELETE FROM [sole].[CodaReferti] WHERE [IdSequenza] = @IdSequenza
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
				INSERT INTO [sole].[CodaRefertiInviati]
					([IdSequenza], [DataInserimento], [IdReferto], [Operazione], [Sorgente]
					, [AziendaErogante], [SistemaErogante], [StatoRichiestaCodice], [DataModificaReferto]
					, [Priorita], [OreRitardoInvio], [Messaggio], [NumeroNosologico])
				SELECT [IdSequenza], [DataInserimento], [IdReferto], [Operazione], [Sorgente]
					, [AziendaErogante], [SistemaErogante], [StatoRichiestaCodice], [DataModificaReferto]
					, [Priorita], [OreRitardoInvio], @Messaggio, [NumeroNosologico]

				FROM [sole].[CodaReferti]
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Restituisco i DATI
				--
				SET @Proprieta = CONVERT(VARBINARY(MAX), ( SELECT * FROM (
										SELECT [IdSequenza], [DataInserimento], Proprieta.[IdReferto], [Operazione], [Sorgente]
											, [AziendaErogante], [SistemaErogante], [StatoRichiestaCodice], [DataModificaReferto]
											, [Priorita], [OreRitardoInvio]

											, o.[Oscurato]
											, ISNULL(o.[Confidenziale], 0) [Confidenziale]
											, [dbo].[IsRefertoLiberaProfessione](Proprieta.[IdReferto]) [LiberaProfessione]

											, @DisabilitaControlliBloccoInvio [DisabilitaControlliBloccoInvio]

										FROM [sole].[CodaReferti] Proprieta
											OUTER APPLY [sole].[OttieniOscuramentiPerReferto](Proprieta.[IdReferto]) o		

										WHERE [IdSequenza] = @IdSequenza) Proprieta

										FOR XML AUTO))

				SET @Abilitazioni = CONVERT(VARBINARY(MAX),
											( SELECT   [Abilitato], [DataInizio], [DataFine], [TipologiaSole]
												, [Mittente], [OreRitardoInvio]
												, [DisabilitaControlloRegime], [DisabilitaControlloInviabile], [DisabilitaControlloConsensi]
												, [Priorita], [CorrelazioneInvio]
												, [InviaOscurati], [InviaConfidenziali], [InviaLiberaProfessione]
											
											FROM [Sole].[AbilitazioniSistemi] Abilitazione

											WHERE TipoErogante = 'Referto'
												AND AziendaErogante = @AziendaErogante
												AND SistemaErogante = @SistemaErogante

											FOR XML AUTO)
											)
				--
				-- Cancello  la restituita
				--
				DELETE FROM [sole].[CodaReferti] WHERE [IdSequenza] = @IdSequenza
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
			SELECT @report = N'[sole_da].[SvuotaCodaRefertiOttieni]. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
			RAISERROR(@report, 16, 1)
			PRINT @report;
			
			RETURN 1
		END CATCH

	END ELSE BEGIN
		RETURN 0
	END 

END