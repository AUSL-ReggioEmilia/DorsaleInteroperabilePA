




-- =============================================
-- Author:		Ettore 
-- Create date: 2013-06-05 
-- Description:	Questa SP è specializzata per eventi di tipo Lista di attesa 
--				Gestisco solo eventi 'IL', 'ML', 'DL', 'RL', 'SL' (ADT-Lista di attesa)
--				Tutti gli eventi lista di attesa hanno negli attributi gli attributi anagrafici
--				Gli eventi di lista di attesa NON devono essere notificati a SOLE
-- Modify date : 2015-02-02 - ETTORE: utilizzo della nuova funzione di aggancio paziente
-- Modify date : 2016-09-08 - ETTORE: eliminato filtro per SistemaErogante = 'ADT' per gestione nuovo sistema erogante EIM-ADTSTR
-- Modify date: 2018-01-08 ETTORE: Aggiunto log aggancio paziente
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- =============================================
CREATE PROCEDURE [dbo].[MntEventiListaAttesaAssociaPaziente]
(
	 @DaData datetime = NULL
	, @ToData datetime = NULL
	, @NotificaSeMovimentatoDaNGiorni INT = 30 --notifica solo i movimentati entro N giorni	
)
AS
BEGIN
	SET NOCOUNT ON;

	-- =============================================
	-- Controllo parametri
	-- =============================================

	IF @DaData IS NULL
		SET @DaData = DATEADD(day, -30, GETDATE())

	IF @ToData IS NULL
		SET @ToData = GETDATE()
		
	IF @NotificaSeMovimentatoDaNGiorni IS NULL
		SET @NotificaSeMovimentatoDaNGiorni = 30

	-- =============================================
	-- Declare and using a READ_ONLY cursor
	-- =============================================
	DECLARE curEventi CURSOR STATIC READ_ONLY
	FOR
	SELECT
		Ev.Id AS IdEvento
		, Ev.TipoEventoCodice 
		, Ev.AziendaErogante
		, Ev.SistemaErogante
		, Ev.NumeroNosologico --questo è il codice della lista di attesa
		, Ev.DataEvento AS DataEvento
		, Ev.DataModifica AS DataModifica 
		, Ev.IdEsterno AS IdEsternoEvento
	FROM store.EventiBase AS Ev 
	WHERE 
		Ev.IdPaziente = '00000000-0000-0000-0000-000000000000'
		AND Ev.StatoCodice = 0	--Solo Eventi attivi (no annullati o erased)
		AND (
				Ev.DataEvento BETWEEN @DaData AND @ToData
				OR
				Ev.DataModifica BETWEEN @DaData AND @ToData --NUOVO
			)
		--AND Ev.SistemaErogante = 'ADT'
		-- Mi assicuro di analizzare solo eventi ADT di ricovero
		AND Ev.TipoEventoCodice IN ('IL','ML','DL','RL','SL')
	ORDER BY DataModificaEsterno --stesso ordine di inserimento

	DECLARE @IdEvento uniqueidentifier
	DECLARE @AziendaErogante varchar(16)
	DECLARE @SistemaErogante varchar(16)
	DECLARE @NomeAnagrafica varchar(64)
	DECLARE @CodiceAnagrafica varchar(64)
	DECLARE @Nome varchar(64)
	DECLARE @Cognome varchar(64)
	DECLARE @CodiceSanitario varchar(64)
	DECLARE @CodiceFiscale varchar(64)
	DECLARE @DataNascita datetime
	DECLARE @IdEsternoPaziente varchar(64)
	DECLARE @DataEvento datetime
	DECLARE @DataModifica datetime
	DECLARE @TipoEventoCodice VARCHAR(16)
	DECLARE @IdEsternoEvento VARCHAR(64)
	
	DECLARE @NumeroNosologico varchar(64)
	DECLARE @IdPazienteSacAssociato UNIQUEIDENTIFIER
	
	DECLARE @EventiAssociati int
	DECLARE @Corrente int
	DECLARE @Totale int

	OPEN curEventi

	SET @EventiAssociati = 0
	SET @Corrente = 0
	SET @Totale = @@CURSOR_ROWS

	FETCH NEXT FROM curEventi 
	INTO @IdEvento, @TipoEventoCodice, @AziendaErogante, @SistemaErogante, @NumeroNosologico, @DataEvento, @DataModifica, @IdEsternoEvento 

	WHILE (@@fetch_status <> -1)
	BEGIN
		SET @Corrente = @Corrente + 1

		IF (@@fetch_status <> -2)
		BEGIN
			SELECT @NomeAnagrafica = CONVERT(VARCHAR(64), dbo.GetEventiAttributo( @IdEvento, 'NomeAnagraficaCentrale')) 
			SELECT @CodiceAnagrafica = CONVERT(VARCHAR(64), dbo.GetEventiAttributo( @IdEvento, 'CodiceAnagraficaCentrale'))  
			SELECT @IdEsternoPaziente = CONVERT(VARCHAR(64), dbo.GetEventiAttributo( @IdEvento, 'IdEsternoPaziente'))  
			SELECT @Nome = CONVERT(VARCHAR(64), dbo.GetEventiAttributo( @IdEvento, 'Nome')) 
			SELECT @Cognome = CONVERT(VARCHAR(64), dbo.GetEventiAttributo( @IdEvento, 'Cognome'))
			SELECT @CodiceSanitario = CONVERT(VARCHAR(64), dbo.GetEventiAttributo( @IdEvento, 'CodiceSanitario')) 
			SELECT @CodiceFiscale = CONVERT(VARCHAR(16), dbo.GetEventiAttributo( @IdEvento, 'CodiceFiscale'))
			SELECT @DataNascita = dbo.GetEventiAttributoDatetime(@IdEvento, 'DataNascita')
		
			--PRINT 'Paziente: @Nome=' + ISNULL(@Nome, 'Nullo')
			--		+ ' @Cognome=' + ISNULL( @Cognome, 'Nullo')
			--		+ ' @CodiceSanitario=' + ISNULL( @CodiceSanitario, 'Nullo')
			--		+ ' @CodiceFiscale=' + ISNULL( @CodiceFiscale, 'Nullo')
			--		+ ' @DataNascita=' + ISNULL(CONVERT(VARCHAR(20), @DataNascita, 102), 'Nullo')
			--		+ ' @NomeAnagrafica=' + ISNULL(@NomeAnagrafica, 'Nullo')
			--		+ ' @CodiceAnagrafica=' + ISNULL( @CodiceAnagrafica, 'Nullo')
			--		+ ' @NumeroNosologico=' + ISNULL( @NumeroNosologico, 'Nullo')
			--		+ ' @IdEvento=' + ISNULL( CAST(@IdEvento AS VARCHAR(40)), 'Nullo')
			--		+ ' @AziendaErogante=' + ISNULL( @AziendaErogante , 'Nullo')
			--		+ ' @SistemaErogante=' + ISNULL( @SistemaErogante, 'Nullo')
			--		+ ' @DataEvento=' + ISNULL( CONVERT(VARCHAR(40), @DataEvento, 120) , 'Nullo')
			--		+ ' @DataModifica=' + ISNULL( CONVERT(VARCHAR(40), @DataModifica, 120) , 'Nullo')

			-- ==================================================================================================
			-- Aggiusto eventualmente l'IdEsterno del paziente
			-- ==================================================================================================
			IF (@IdEsternoPaziente IS NULL) OR (@IdEsternoPaziente = '')
				SET @IdEsternoPaziente = CAST(NEWID() AS VARCHAR(40))
			-- ==================================================================================================
			-- Eseguo un lookup del nome dell'anagrafica
			-- ==================================================================================================
			DECLARE @TblNomeAnagrafica AS TABLE (NomeAnagrafica VARCHAR(64))
			DELETE FROM @TblNomeAnagrafica
			
			INSERT INTO @TblNomeAnagrafica(NomeAnagrafica) 
			EXECUTE [dbo].[ExtPazienteLookUpNomeAnagraficaDiRicerca] 
			   @NomeAnagrafica = @NomeAnagrafica
			  ,@AziendaErogante = @AziendaErogante
			
			DECLARE @NomeAnagraficaLookUp AS VARCHAR(64)
			SET @NomeAnagraficaLookUp = NULL
			SELECT @NomeAnagraficaLookUp = NomeAnagrafica FROM @TblNomeAnagrafica
			
			IF ISNULL(@NomeAnagraficaLookUp, '') <> ''
				SET @NomeAnagrafica = @NomeAnagraficaLookUp
			
			-- ==================================================================================================
			-- Eseguo la SP di SacConnDwh.PazientiOutputCercaAggancioPaziente che esegue la SP sul Sac 
			-- impersonificando l'utente SAC_DWC
			-- la SP restituisce il guid del paziente trovato
			-- ==================================================================================================
			
			IF @NomeAnagrafica IS NULL SET @NomeAnagrafica = ''
			IF @CodiceAnagrafica IS NULL SET @CodiceAnagrafica = ''
			SET @IdPazienteSacAssociato = NULL			
			
			BEGIN TRY
				EXEC dbo.SacConnDwh_PazientiOutputCercaAggancioPaziente 
						@ProvenienzaDiRicerca = @NomeAnagrafica					--anagrafica
						, @IdProvenienzaDiRicerca = @CodiceAnagrafica			--codiceanagrafica
						, @IdProvenienzaDiInserimento = @IdEsternoPaziente		--IdEsternoPaziente o guid
						, @Tessera = @CodiceSanitario
						, @Cognome = @Cognome
						, @Nome = @Nome
						, @DataNascita = @DataNascita
						, @Sesso = NULL
						, @ComuneNascitaCodice = NULL
						, @NazionalitaCodice = NULL
						, @CodiceFiscale = @CodiceFiscale
						, @IdPazienteSac = @IdPazienteSacAssociato OUT
			END TRY
			BEGIN CATCH
				SET @IdPazienteSacAssociato = NULL
			END CATCH

			IF (NOT @IdPazienteSacAssociato IS NULL) AND (@IdPazienteSacAssociato <> '00000000-0000-0000-0000-000000000000')
			BEGIN
				-- =============================================
				-- Paziente trovato: aggiorno eventi eventi associati al ricovero che non sono associati al paziente 
				-- e il record del ricovero e inserisco nella coda delle notifiche
				-- =============================================
				PRINT 'Evento ' + CAST(@IdEvento AS VARCHAR(40)) + ' della lista di attesa ' + @AziendaErogante + '-' + @NumeroNosologico + ' -> associato a IdPaziente=' + CONVERT(VARCHAR(40), @IdPazienteSacAssociato)
			
				--
				-- Attenzione:
				-- aggiorno comunque tutti gli eventi del ricovero a cui appartiene l'evento con l'IdPaziente trovato!
				--
				UPDATE store.EventiBase
					SET IdPaziente=@IdPazienteSacAssociato
						, DataModifica = GETDATE() --nella versione precedente non veniva aggiornata la DataModifica degli eventi!!!
				WHERE 
					AziendaErogante = @AziendaErogante
					AND SistemaErogante = @SistemaErogante
					AND NumeroNosologico = @NumeroNosologico
				--
				-- Allineo il record del ricovero con lo stesso IdPaziente
				--
				UPDATE store.RicoveriBase
					SET IdPaziente=@IdPazienteSacAssociato,
						DataModifica = GETDATE()
				WHERE 
					AziendaErogante = @AziendaErogante
					AND SistemaErogante = @SistemaErogante
					AND NumeroNosologico = @NumeroNosologico
					
				--
				-- Notifico la modifica della lista di attesa solo se non è più vecchia di N giorni
				-- inserisco nel log il nosologico modificato
				--
				IF (@DataEvento >= DATEADD(day, - @NotificaSeMovimentatoDaNGiorni, GETDATE()) )
						OR (@DataModifica >= DATEADD(day, - @NotificaSeMovimentatoDaNGiorni, GETDATE()) )
				BEGIN
				
					DECLARE @IdCorrelazione VARCHAR(64)
					DECLARE @TimeoutCorrelazione INT
					--
					-- Valorizzo l'Id di correlazione
					--
					SELECT @IdCorrelazione =  [dbo].[GetCodaEventiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante,  @NumeroNosologico)
					--
					-- Valorizzo il timeout di correlazione
					--
					SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput',	'TimeoutCorrelazione'), 1)
					--
					-- Eseguo l'inserimento nella tabella delle notifiche degli eventi
					--			
					INSERT INTO CodaEventiOutput (IdEvento, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
					VALUES(@IdEvento, 1 , @IdCorrelazione, @TimeoutCorrelazione, 0, dbo.GetEventoXml2(@IdEvento))
		
				END
				
				--
				-- Comando il ricalcolo dell'anteprima ricoveri
				--
				EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPazienteSacAssociato, 0, 1
				--
				-- Eseguo log dell'operazione
				--
				INSERT INTO dbo.LogMntAggancioPaziente(Oggetto, IdPaziente, AziendaErogante, SistemaErogante, IdOggetto, IdEsternoOggetto)
				VALUES ('Prenotazione', @IdPazienteSacAssociato, @AziendaErogante , @SistemaErogante, @IdEvento, @IdEsternoEvento)
				
				--
				-- Memorizzo il numero di episodi riassociati
				-- 
				SET @EventiAssociati = @EventiAssociati + 1				
			END
			ELSE
			BEGIN
				PRINT 'Evento ' + CAST(@IdEvento AS VARCHAR(40)) + ' della prenotazione ' + @AziendaErogante + '-' + @NumeroNosologico + ' -> orfano!'  
			END
			PRINT ''
		END
		-- Prossima riga
		FETCH NEXT FROM curEventi 
		INTO @IdEvento, @TipoEventoCodice, @AziendaErogante, @SistemaErogante, @NumeroNosologico, @DataEvento, @DataModifica, @IdEsternoEvento 
	END
	-- Fine
	PRINT 'Eventi di Prenotazioni associati: ' + CONVERT(VARCHAR(10), @EventiAssociati) + ' su ' + CONVERT(VARCHAR(10), @Totale)

	CLOSE curEventi
	DEALLOCATE curEventi
END
