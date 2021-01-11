
-- =============================================
-- Author:		Ettore
-- Create date: 2017-03-15
-- Description:	Esegue la rinotifica di tutti gli eventi di un nosologico
-- Modify date: 2017-12-28 - Per gli eventi di un ricovero costruisce prima evento di ERASE
--							 Per gli eventi di prenotazione invia la sequenza degli eventi
-- Modify date: 2018-01-11 - Notifica anche a SOLE (solo eventi relativi a RICOVERI)
-- Modify date: 2019-01-15 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaEventiAggiungi])
-- Modify date: 2019-02-25 - SANDRO - Aggiunto @StatoCodice a EXEC [sole].[CodaEventiAggiungi]

-- =============================================
CREATE PROCEDURE [dbo].[BeRicoveroNotificaEventi]
(
 @AziendaErogante VARCHAR(16) 
,@NumeroNosologico VARCHAR(64) 
)
AS 
BEGIN 

	SET NOCOUNT ON;
	----------------------------------------------------------
	-- Log eventi in caso di aggiornamento
	----------------------------------------------------------
	DECLARE @SistemaErogante AS VARCHAR(16)
	DECLARE @OperazioneLog AS smallint = 1 --sempre modifica
	DECLARE @IdCorrelazione AS VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @XmlEventoErase  AS XML
	DECLARE @XmlEventoEraseSole  AS XML
	DECLARE @IdEventoErase UNIQUEIDENTIFIER
	DECLARE @IdEventoEraseSole UNIQUEIDENTIFIER

	--
	-- 2019-01-15 Agginta DataModifica
	--
	DECLARE @TableEventi AS TABLE(IdEvento UNIQUEIDENTIFIER, AziendaErogante VARCHAR(16), SistemaErogante VARCHAR(16), StatoCodice TINYINT
								, IdPaziente UNIQUEIDENTIFIER, DataModificaEsterno DATETIME, TipoEventoCodice VARCHAR(16), DataModifica DATETIME)

	INSERT INTO @TableEventi(IdEvento, AziendaErogante, SistemaErogante, StatoCodice
							, IdPaziente, DataModificaEsterno, TipoEventoCodice, DataModifica)
	SELECT Id, AziendaErogante, SistemaErogante, StatoCodice
			,IdPaziente, DataModificaEsterno, TipoEventoCodice, DataModifica
	FROM [store].[EventiBase]
	WHERE AziendaErogante = @AziendaErogante
		AND NumeroNosologico = @NumeroNosologico 
		AND TipoEventoCodice <> 'LA' --escludo l'evento FITTIZIO "LA"
	ORDER BY DataModificaEsterno ASC --nell'ordine in cui sono entrati
	--
	-- Verifico che tutti gli eventi siano associati ad un paziente
	--
	IF EXISTS(SELECT * FROM @TableEventi WHERE IdPaziente = '00000000-0000-0000-0000-000000000000')
	BEGIN 
		DECLARE @MsgError VARCHAR(128) = 'Almeno uno degli eventi del nosologico risulta non associato al paziente!'
		RAISERROR(@MsgError, 16,1)
		RETURN
	END 

	DECLARE @IdEventoIniziale UNIQUEIDENTIFIER
	DECLARE @TipoEventoInizialeCodice VARCHAR(16)
	SELECT TOP 1 
		@IdEventoIniziale = IdEvento 
		, @SistemaERogante = SistemaErogante
		, @TipoEventoInizialeCodice = TipoEventoCodice
	FROM @TableEventi
	WHERE TipoEventoCodice IN ('A', 'IL')
	ORDER BY DataModificaEsterno

	--
	-- Verifico che esista l'evento di accettazione, perchè lo uso per creare l'evento di ERASE
	--
	IF @IdEventoIniziale IS NULL
	BEGIN
		DECLARE @ErroMsg AS VARCHAR(200)
		SET @ErroMsg = 'Il ricovero [' +  @AziendaErogante + ', ' + @NumeroNosologico + ']  non ha l''evento iniziale A o IL'
		RAISERROR(@ErroMsg, 16, 1)
		RETURN
	END

	--
	-- Valorizzo il timeout di correlazione una volta per tutte
	-- e l'IdCorrelazione
	--
	SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)
	SELECT @IdCorrelazione = [dbo].[GetCodaEventiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante,  @NumeroNosologico)


	BEGIN TRANSACTION 
	BEGIN TRY
		IF @TipoEventoInizialeCodice = 'A' -- IL NOSOLOGICO E' UN RICOVERO
		BEGIN
			---------------------------------------
			-- RINOTIFICA CODA STANDARD
			---------------------------------------
			SET @IdEventoErase = NEWID()
			--
			-- Creo l'evento di annullamento per la coda standard
			--
			SELECT @XmlEventoErase  = [dbo].[CreaEventoAnnullamentoRicovero] (dbo.GetEventoXml2(@IdEventoIniziale), @IdEventoErase, 'E', 'Cancellazione')
			--
			-- Inserisco la notifica dell'evento di annullamento nella coda standard
			--
			INSERT INTO dbo.CodaEventiOutput (IdEvento, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
			VALUES(@IdEventoErase, @OperazioneLog , @IdCorrelazione, @TimeoutCorrelazione, 0, @XmlEventoErase )
			--
			-- Eseguo l'inserimento degli altri eventi in ordine ascendente nella coda standard
			--			
			INSERT INTO dbo.CodaEventiOutput (IdEvento, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
			SELECT 
				IdEvento
				, @OperazioneLog		--costante=1
				, @IdCorrelazione
				, @TimeoutCorrelazione	--costante
				, 0						--costante
				, dbo.GetEventoXml2(IdEvento) AS Messaggio
			FROM 
				@TableEventi 
			ORDER BY DataModificaEsterno ASC --nell'ordine in cui sono entrati


			---------------------------------------
			-- RINOTIFICA CODA SOLE
			---------------------------------------

			--
			-- Prendo alcune informazioni dalla tabella dei ricoveri
			-- 2019-01-15 Agginta CodiceFiscale
			--
			DECLARE @TipoRicoveroCodice VARCHAR(16)
			DECLARE @RicoveroStatoCodice TINYINT

			SELECT @TipoRicoveroCodice = TipoRicoveroCodice
					, @RicoveroStatoCodice = StatoCodice
			FROM [store].[RicoveriBase]
			WHERE AziendaErogante = @AziendaErogante
				AND NumeroNosologico = @NumeroNosologico 

			-------------------------------------------------------------------------------
			-- Eseguo l'inserimento nella tabella di coda SOLE:
			--   l'inserimento nella coda SOLE deve essere fatto solo dopo il controllo
			------------------------------------------------------------------------------
			IF [sole].[IsEventoInviabile](@TipoEventoInizialeCodice, @TipoRicoveroCodice, @RicoveroStatoCodice, 0) = 1
			BEGIN 
				SET @IdEventoEraseSole = NEWID()
				--
				-- Creo l'evento di annullamento per la coda Sole
				--
				SELECT @XmlEventoEraseSole  = [dbo].[CreaEventoAnnullamentoRicovero] ([sole].[OttieneEventoXml](@IdEventoIniziale)
																						, @IdEventoEraseSole, 'E', 'Cancellazione')
--				------------------------------------------------------------
				-- Eseguo l'inserimento dell'evento di erase nella coda SOLE
				-- Data minima + ordinamento per IdSequenza garantisce ordinamento di lettura
				DECLARE @DataModificaMinima DATETIME
				SELECT @DataModificaMinima = MIN(DataModifica) FROM @TableEventi 
				--	2019-01-16
				--Operazione tipo 2

				EXEC [sole].[CodaEventiAggiungi] @IdEventoEraseSole, 2, 'DAE', @AziendaErogante, @SistemaErogante, 0
												, 'E', @DataModificaMinima, @NumeroNosologico, @XmlEventoEraseSole
				--
				-- Inserisco gli altri eventi nell'ordine di ingresso
				--
				DECLARE @Cur_IdEvento uniqueidentifier
				DECLARE @Cur_AziendaErogante varchar(16)
				DECLARE @Cur_SistemaErogante VARCHAR(16)
				DECLARE @Cur_StatoCodice TINYINT
				DECLARE @Cur_TipoEventoCodice VARCHAR(16)
				DECLARE @Cur_DataModifica DATETIME

				DECLARE curEventi CURSOR STATIC READ_ONLY FOR	
				SELECT IdEvento
					, AziendaErogante
					, SistemaErogante
					, StatoCodice
					, TipoEventoCodice
					, DataModifica
				FROM @TableEventi 
				ORDER BY DataModificaEsterno ASC --nell'ordine in cui sono entrati

				OPEN curEventi
				FETCH NEXT FROM curEventi INTO @Cur_IdEvento, @Cur_AziendaErogante, @Cur_SistemaErogante, @Cur_StatoCodice, @Cur_TipoEventoCodice, @Cur_DataModifica
				WHILE (@@fetch_status <> -1)
					BEGIN
					IF (@@fetch_status <> -2)
						BEGIN
							------------------------------------------------------------
							-- Eseguo l'inserimento dell'evento di erase nella coda SOLE
							--
							EXEC [sole].[CodaEventiAggiungi] @Cur_IdEvento, @OperazioneLog, 'DAE', @Cur_AziendaErogante, @Cur_SistemaErogante, @Cur_StatoCodice
															, @Cur_TipoEventoCodice, @Cur_DataModifica, @NumeroNosologico, NULL
						END
					-- Prossima riga
					FETCH NEXT FROM curEventi INTO @Cur_IdEvento, @Cur_AziendaErogante, @Cur_SistemaErogante, @Cur_StatoCodice, @Cur_TipoEventoCodice, @Cur_DataModifica
				END
				-- Fine
				CLOSE curEventi
				DEALLOCATE curEventi
			
			END
		END
		ELSE IF @TipoEventoInizialeCodice = 'IL'  -- IL NOSOLOGICO E' LISTA DI PRENOTAZIONE 
		BEGIN 
			--PER LE PRENOTAZIONI NON SI DEVE NOTIFICARE A SOLE
			--
			-- Eseguo l'inserimento degli altri eventi in ordine ascendente nella coda standard
			--			
			INSERT INTO CodaEventiOutput (IdEvento, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
			SELECT 
				IdEvento
				, @OperazioneLog		--costante=1
				, @IdCorrelazione
				, @TimeoutCorrelazione	--costante
				, 0						--costante
				, dbo.GetEventoXml2(IdEvento) AS Messaggio
			FROM 
				@TableEventi 
			ORDER BY DataModificaEsterno ASC --nell'ordine in cui sono entrati
		END 

		--
		-- COMMIT
		--
		COMMIT
	END TRY
	BEGIN CATCH
		--
		-- ROLLBACK
		--
		IF @@TRANCOUNT > 0 
			ROLLBACK
		--
		-- RAISE DELL'ERRORE
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BeRicoveroNotificaEventi. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	END CATCH

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRicoveroNotificaEventi] TO [ExecuteFrontEnd]
    AS [dbo];

