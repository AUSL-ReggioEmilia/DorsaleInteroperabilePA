





-- =============================================
-- Author:		ETTORE
-- Create date: 2017-11-21
-- Description:	Associazione delle note anamnestiche
-- =============================================
CREATE PROCEDURE [dbo].[MntNoteAnamnesticheAssociaPaziente]
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
	DECLARE curNoteAnamnestiche CURSOR STATIC READ_ONLY
	FOR
	SELECT 
		rb.Id AS IdNotaAnamnestica
		,rb.AziendaErogante
		,rb.SistemaErogante		
		,rb.DataNota AS DataNotaAnamnestica
		,rb.DataModifica AS DataModificaNotaAnamnestica
		,rb.IdEsterno AS IdEsternoNotaAnamnestica
		--Leggo gli attributi mancanti dall'XML
		, Attributi.value('(/Attributi/Attributo[@Nome="NomeAnagrafica"]/@Valore)[1]', 'varchar(64)') AS NomeAnagrafica
		, Attributi.value('(/Attributi/Attributo[@Nome="CodiceAnagraficaCentrale"]/@Valore)[1]', 'varchar(64)') AS CodiceAnagraficaCentrale
		--, Attributi.value('(/Attributi/Attributo[@Nome="IdEsternoPaziente"]/@Valore)[1]', 'varchar(64)') AS IdEsternoPaziente --questo non c'è
		, Nome
		, Cognome
		, CodiceSanitario
		, CodiceFiscale
		, DataNascita
		, DataPartizione
	FROM
		store.NoteAnamnestiche rb
	WHERE 
		IdPaziente = '00000000-0000-0000-0000-000000000000'
		AND (
			rb.DataNota BETWEEN @DaData AND @ToData
			OR 
			rb.DataModifica BETWEEN @DaData AND @ToData
			)

	DECLARE @IdNotaAnamnestica uniqueidentifier
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
	DECLARE @DataNotaAnamnestica datetime
	DECLARE @DataModificaNotaAnamnestica datetime
	DECLARE @IdEsternoNotaAnamnestica VARCHAR(64)
	DECLARE @IdPazienteSacAssociato UNIQUEIDENTIFIER
	DECLARE @DataPartizione SMALLDATETIME
	

	DECLARE @Associati int
	DECLARE @Corrente int
	DECLARE @Totale int

	OPEN curNoteAnamnestiche

	SET @Associati = 0
	SET @Corrente = 0
	SET @Totale = @@CURSOR_ROWS

	FETCH NEXT FROM curNoteAnamnestiche INTO @IdNotaAnamnestica, @AziendaErogante, @SistemaErogante, @DataNotaAnamnestica, @DataModificaNotaAnamnestica, @IdEsternoNotaAnamnestica
		, @NomeAnagrafica, @CodiceAnagrafica, @Nome, @Cognome, @CodiceSanitario, @CodiceFiscale, @DataNascita, @DataPartizione 
	WHILE (@@fetch_status <> -1)
		BEGIN
		SET @Corrente = @Corrente + 1
		IF (@@fetch_status <> -2)
			BEGIN
			SET @IdEsternoPaziente = NULL
		
			--PRINT 'MntNoteAnamnesticheAssociaPaziente: Paziente : @Nome=' + ISNULL(@Nome, 'Nullo')
			--		+ ' @Cognome=' + ISNULL( @Cognome, 'Nullo')
			--		+ ' @CodiceSanitario=' + ISNULL( @CodiceSanitario, 'Nullo')
			--		+ ' @CodiceFiscale=' + ISNULL( @CodiceFiscale, 'Nullo')
			--		+ ' @DataNascita=' + ISNULL(CONVERT(VARCHAR(20), @DataNascita, 102), 'Nullo')
			--		+ ' @NomeAnagrafica=' + ISNULL(@NomeAnagrafica, 'Nullo')
			--		+ ' @CodiceAnagrafica=' + ISNULL( @CodiceAnagrafica, 'Nullo')
			--		+ ' @AziendaErogante=' + ISNULL(@AziendaErogante, 'Nullo')
			--		+ ' @SistemaErogante=' + ISNULL(@SistemaErogante, 'Nullo')
			--		+ ' @DataNotaAnamnestica=' + ISNULL(CONVERT(VARCHAR(40), @DataNotaAnamnestica, 120), 'Nullo')
			--		+ ' @DataModificaNotaAnamnestica=' + ISNULL(CONVERT(VARCHAR(40), @DataModificaNotaAnamnestica, 120), 'Nullo')
			
			-- ==================================================================================================
			-- Aggiusto eventualmente l'IdEsterno del paziente
			-- ==================================================================================================
			IF (@IdEsternoPaziente IS NULL)
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
				-- Paziente trovato: aggiorno il NotaAnamnestica e inserisco nella coda delle notifiche
				-- =============================================
				PRINT 'NotaAnamnestica con Id=' + CONVERT(VARCHAR(40), @IdNotaAnamnestica) + ' associato al IdPaziente=' + CONVERT(VARCHAR(40), @IdPazienteSacAssociato)
				-- Aggiorno NotaAnamnestica
				UPDATE store.NoteAnamnesticheBase
					SET IdPaziente=@IdPazienteSacAssociato
						,DataModifica=GETDATE()
					WHERE Id=@IdNotaAnamnestica
				-- Inserisco record di notifica
				-- solo se la NotaAnamnestica è non è più vecchia di N giorni
				-- o è stata movimentata negli ultimi N giorni
				IF (@DataNotaAnamnestica >= DATEADD(day, - @NotificaSeMovimentatoDaNGiorni, GETDATE()) )
					OR (@DataModificaNotaAnamnestica >= DATEADD(day, - @NotificaSeMovimentatoDaNGiorni, GETDATE()) )
				BEGIN
					DECLARE @IdCorrelazione VARCHAR(64)
					DECLARE @TimeoutCorrelazione INT
					--
					-- Valorizzo l'Id di correlazione
					--
					SELECT @IdCorrelazione =  [dbo].[GetCodaNoteAnamnesticheOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante, @IdEsternoNotaAnamnestica)
					--
					-- Valorizzo il timeout di correlazione
					--
					SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)
					--
					-- Eseguo l'inserimento (sempre log di modifica: Operazione=1)
					--
					INSERT INTO CodaNoteAnamnesticheOutput (IdNotaAnamnestica,Operazione, IdCorrelazione, CorrelazioneTimeout,  OrdineInvio, Messaggio)
					VALUES(@IdNotaAnamnestica, 1 , @IdCorrelazione , @TimeoutCorrelazione , 0, dbo.GetNotaAnamnesticaXML(@IdNotaAnamnestica, @DataPartizione))
				END
				--
				-- Comando il ricalcolo dell'anteprima delle note anamnestiche
				--
				EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPazienteSacAssociato, 0, 0, 1
				--
				-- Eseguo log dell'operazione
				--
				INSERT INTO dbo.LogMntAggancioPaziente(Oggetto, IdPaziente, AziendaErogante, SistemaErogante, IdOggetto, IdEsternoOggetto)
				VALUES ('NotaAnamnestica', @IdPazienteSacAssociato, @AziendaErogante , @SistemaErogante, @IdNotaAnamnestica, @IdEsternoNotaAnamnestica)

				SET @Associati = @Associati + 1
			END
			ELSE
			BEGIN
				PRINT 'NotaAnamnestica Id=' + CONVERT(VARCHAR(40), @IdNotaAnamnestica) + ' orfano!'
			END
			END
			PRINT ''
			-- Prossima riga
			FETCH NEXT FROM curNoteAnamnestiche INTO @IdNotaAnamnestica, @AziendaErogante, @SistemaErogante, @DataNotaAnamnestica, @DataModificaNotaAnamnestica, @IdEsternoNotaAnamnestica
				, @NomeAnagrafica, @CodiceAnagrafica, @Nome, @Cognome, @CodiceSanitario, @CodiceFiscale, @DataNascita, @DataPartizione 
		END
	-- Fine
	PRINT 'Note anamnestiche associate: ' + CONVERT(VARCHAR(10), @Associati) + ' su ' + CONVERT(VARCHAR(10), @Totale)

	CLOSE curNoteAnamnestiche
	DEALLOCATE curNoteAnamnestiche
END