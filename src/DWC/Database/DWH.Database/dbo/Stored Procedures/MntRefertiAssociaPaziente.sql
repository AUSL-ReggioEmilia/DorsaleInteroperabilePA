-- =============================================
-- Author:		
-- Create date: 
-- Description:	Manteinance di riassociazione referti al paziente
-- Modify date: 2017-12-11 ETTORE: Aggiunto inserimento in Coda SOLE
--				Essendo il primo aggancio al paziente si deve notificare a SOLE
-- Modify date: 2018-01-08 ETTORE: Aggiunto log aggancio paziente
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Modify date: 2019-01-21 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaRefertiAggiungi])
-- =============================================
CREATE PROCEDURE [dbo].[MntRefertiAssociaPaziente]
(
	 @DaData datetime = NULL
	, @ToData datetime = NULL
	, @NotificaSeMovimentatoDaNGiorni INT = 30 --notifica solo i movimentati entro N giorni
)
AS
BEGIN
/*
	MODIFICA ETTORE 2015-02-02: utilizzo della nuova funzione di aggancio paziente
*/
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
	DECLARE curReferti CURSOR STATIC READ_ONLY
	FOR
	SELECT 
		rb.Id AS IdReferto
		,rb.AziendaErogante
		,rb.SistemaErogante		
		,rb.DataReferto AS DataReferto
		,rb.DataModifica AS DataModificaReferto
		,rb.IdEsterno AS IdEsternoReferto
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( rb.Id, 'NomeAnagraficaCentrale')) AS NomeAnagrafica
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( rb.Id, 'CodiceAnagraficaCentrale')) AS CodiceAnagrafica
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( rb.Id, 'IdEsternoPaziente')) AS IdEsternoPaziente
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( rb.Id, 'Nome')) AS Nome
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( rb.Id, 'Cognome')) AS Cognome
		,CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( rb.Id, 'CodiceSanitario')) AS CodiceSanitario
		,CONVERT(VARCHAR(16), dbo.GetRefertiAttributo( rb.Id, 'CodiceFiscale')) AS CodiceFiscale
		,dbo.GetRefertiAttributoDatetime(rb.Id, 'DataNascita') AS DataNascita
		,StatoRichiestaCodice
	FROM
		--Leggo dalla RefertiBase (se in futuro filtriamo la referti per escludere IdPaziente='{00000000-0000-0000-0000-000000000000}' tutto funziona)
		store.RefertiBase rb
	WHERE 
		IdPaziente = '00000000-0000-0000-0000-000000000000'
		AND (
			rb.DataReferto BETWEEN @DaData AND @ToData
			OR 
			rb.DataModifica BETWEEN @DaData AND @ToData
			)

	DECLARE @IdReferto uniqueidentifier
	DECLARE @AziendaErogante varchar(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @NomeAnagrafica varchar(64)
	DECLARE @CodiceAnagrafica varchar(64)
	DECLARE @IdEsternoPaziente varchar(64)	
	DECLARE @Nome varchar(64)
	DECLARE @Cognome varchar(64)
	DECLARE @CodiceSanitario varchar(64)
	DECLARE @CodiceFiscale varchar(64)
	DECLARE @DataNascita datetime
	DECLARE @DataReferto datetime
	DECLARE @DataModificaReferto datetime
	DECLARE @IdEsternoReferto VARCHAR(64)
	DECLARE @IdPazienteSacAssociato UNIQUEIDENTIFIER
	DECLARE @StatoRichiestaCodice TINYINT
	

	DECLARE @Associati int
	DECLARE @Corrente int
	DECLARE @Totale int

	OPEN curReferti

	SET @Associati = 0
	SET @Corrente = 0
	SET @Totale = @@CURSOR_ROWS

	FETCH NEXT FROM curReferti INTO @IdReferto, @AziendaErogante, @SistemaErogante, @DataReferto, @DataModificaReferto,	@IdEsternoReferto
		, @NomeAnagrafica, @CodiceAnagrafica, @IdEsternoPaziente, @Nome, @Cognome, @CodiceSanitario, @CodiceFiscale, @DataNascita, @StatoRichiestaCodice
	WHILE (@@fetch_status <> -1)
		BEGIN
		SET @Corrente = @Corrente + 1
		IF (@@fetch_status <> -2)
			BEGIN
			
			--PRINT 'MntRefertiAssociaPaziente: Paziente del referto: @Nome=' + ISNULL(@Nome, 'Nullo')
			--		+ ' @Cognome=' + ISNULL( @Cognome, 'Nullo')
			--		+ ' @CodiceSanitario=' + ISNULL( @CodiceSanitario, 'Nullo')
			--		+ ' @CodiceFiscale=' + ISNULL( @CodiceFiscale, 'Nullo')
			--		+ ' @DataNascita=' + ISNULL(CONVERT(VARCHAR(20), @DataNascita, 102), 'Nullo')
			--		+ ' @NomeAnagrafica=' + ISNULL(@NomeAnagrafica, 'Nullo')
			--		+ ' @CodiceAnagrafica=' + ISNULL( @CodiceAnagrafica, 'Nullo')
			--		+ ' @AziendaErogante=' + ISNULL(@AziendaErogante, 'Nullo')
			--		+ ' @SistemaErogante=' + ISNULL(@SistemaErogante, 'Nullo')
			--		+ ' @IdEsternoPaziente=' + ISNULL(@IdEsternoPaziente, 'Nullo')
			--		+ ' @DataReferto=' + ISNULL(CONVERT(VARCHAR(40), @DataReferto, 120), 'Nullo')
			--		+ ' @DataModificaReferto=' + ISNULL(CONVERT(VARCHAR(40), @DataModificaReferto, 120), 'Nullo')
			
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
				-- Paziente trovato: aggiorno il referto e inserisco nella coda delle notifiche
				-- =============================================
				PRINT 'Referto con Id=' + CONVERT(VARCHAR(40), @IdReferto) + ' associato al IdPaziente=' + CONVERT(VARCHAR(40), @IdPazienteSacAssociato)
				
				DECLARE @DataModifica DATETIME = GETDATE()

				-- Aggiorno referto
				UPDATE store.RefertiBase
					SET IdPaziente = @IdPazienteSacAssociato
						,DataModifica = @DataModifica
					WHERE Id=@IdReferto

				-- Inserisco record di notifica
				-- solo se il referto è non è più vecchio di N giorni
				-- o è stato movimentato negli ultimi N giorni
				IF (@DataReferto >= DATEADD(day, - @NotificaSeMovimentatoDaNGiorni, GETDATE()) )
					OR (@DataModificaReferto >= DATEADD(day, - @NotificaSeMovimentatoDaNGiorni, GETDATE()) )
				BEGIN
					DECLARE @IdCorrelazione VARCHAR(64)
					DECLARE @TimeoutCorrelazione INT
					--
					-- Valorizzo l'Id di correlazione
					--
					SELECT @IdCorrelazione =  [dbo].[GetCodaRefertiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante, @IdEsternoReferto)
					--
					-- Valorizzo il timeout di correlazione
					--
					SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)

					-------------------------------------------------------------------------------------------------------
					-- Eseguo l'inserimento nella tabella di output standard (sempre log di modifica: Operazione=1)
					-------------------------------------------------------------------------------------------------------
					INSERT INTO CodaRefertiOutput (IdReferto,Operazione, IdCorrelazione, CorrelazioneTimeout,  OrdineInvio, Messaggio)
					VALUES(@IdReferto, 1 , @IdCorrelazione , @TimeoutCorrelazione , dbo.GetCodaRefertiOutputOrdineInvio(@SistemaErogante), dbo.GetRefertoXml2(@IdReferto))
					
					-------------------------------------------------------------------------------------------------------
					-- Eseguo l'inserimento nella tabella di output SOLE (sempre log di modifica: Operazione=1)
					-------------------------------------------------------------------------------------------------------
					EXEC [sole].[CodaRefertiAggiungi] @IdReferto, 1, 'Mnt', @AziendaErogante
								, @SistemaErogante, @StatoRichiestaCodice
								, @DataModifica, NULL
				END
				--
				-- Comando il ricalcolo dell'anteprima referti
				--
				EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPazienteSacAssociato, 1, 0
				--
				-- Eseguo log dell'operazione
				--
				INSERT INTO dbo.LogMntAggancioPaziente(Oggetto, IdPaziente, AziendaErogante, SistemaErogante, IdOggetto, IdEsternoOggetto)
				VALUES ('Referto', @IdPazienteSacAssociato, @AziendaErogante , @SistemaErogante, @IdReferto, @IdEsternoReferto)

				SET @Associati = @Associati + 1
			END	ELSE BEGIN
				PRINT 'Referto Id=' + CONVERT(VARCHAR(40), @IdReferto) + ' orfano!'
			END

			END
			PRINT ''
		-- Prossima riga
		FETCH NEXT FROM curReferti INTO @IdReferto, @AziendaErogante, @SistemaErogante, @DataReferto, @DataModificaReferto,	@IdEsternoReferto
			, @NomeAnagrafica, @CodiceAnagrafica, @IdEsternoPaziente, @Nome, @Cognome, @CodiceSanitario, @CodiceFiscale, @DataNascita, @StatoRichiestaCodice
		END
	-- Fine
	PRINT 'Referti associati: ' + CONVERT(VARCHAR(10), @Associati) + ' su ' + CONVERT(VARCHAR(10), @Totale)

	CLOSE curReferti
	DEALLOCATE curReferti
END





