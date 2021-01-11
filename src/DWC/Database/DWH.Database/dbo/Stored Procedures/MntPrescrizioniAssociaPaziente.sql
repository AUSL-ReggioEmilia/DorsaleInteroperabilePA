





-- =============================================
-- Author:		ETTORE
-- Create date: 2015-11-26
-- Description:	Aggancio paziente batch
-- Modify date: 2018-01-08 ETTORE: Aggiunto log aggancio paziente
-- =============================================
CREATE PROCEDURE [dbo].[MntPrescrizioniAssociaPaziente]
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
	DECLARE curPrescrizioni CURSOR STATIC READ_ONLY
	FOR
	SELECT 
		Pre.Id AS IdPrescrizione
		,Pre.DataPrescrizione AS DataPrescrizione
		,Pre.DataModifica AS DataModificaPrescrizione
		,Pre.IdEsterno AS IdEsternoPrescrizione
		--NomeAnagraficaCentrale e CodiceAnagraficaCentrale non esistono per le prescrizioni
		--, Attributi.value('(/Attributi/Attributo[@Nome="NomeAnagraficaCentrale"]/@Valore)[1]', 'varchar(64)') AS NomeAnagrafica 
		--, Attributi.value('(/Attributi/Attributo[@Nome="CodiceAnagraficaCentrale"]/@Valore)[1]', 'varchar(64)') AS CodiceAnagrafica
		--IdEsternoPaziente non esiste per le prescrizioni
		--, Attributi.value('(/Attributi/Attributo[@Nome="IdEsternoPaziente"]/@Valore)[1]', 'varchar(64)') AS IdEsternoPaziente
		, Attributi.value('(/Attributi/Attributo[@Nome="Nome"]/@Valore)[1]', 'varchar(64)') AS Nome
		, Attributi.value('(/Attributi/Attributo[@Nome="Cognome"]/@Valore)[1]', 'varchar(64)') AS Cognome
		, Attributi.value('(/Attributi/Attributo[@Nome="CodiceSanitario"]/@Valore)[1]', 'varchar(64)') AS CodiceSanitario		
		, Attributi.value('(/Attributi/Attributo[@Nome="CodiceFiscale"]/@Valore)[1]', 'varchar(16)') AS CodiceFiscale
		, Attributi.value('(/Attributi/Attributo[@Nome="DataNascita"]/@Valore)[1]', 'datetime') AS DataNascita
	FROM
		store.Prescrizioni Pre
	WHERE 
		Pre.IdPaziente = '00000000-0000-0000-0000-000000000000'
		AND (
			Pre.DataPrescrizione BETWEEN @DaData AND @ToData
			OR 
			Pre.DataModifica BETWEEN @DaData AND @ToData
			)

	DECLARE @IdPrescrizione uniqueidentifier
	DECLARE @NomeAnagrafica varchar(64)
	DECLARE @CodiceAnagrafica varchar(64)
	DECLARE @IdEsternoPaziente varchar(64)	
	DECLARE @Nome varchar(64)
	DECLARE @Cognome varchar(64)
	DECLARE @CodiceSanitario varchar(64)
	DECLARE @CodiceFiscale varchar(64)
	DECLARE @DataNascita datetime
	DECLARE @DataPrescrizione datetime
	DECLARE @DataModificaPrescrizione datetime
	DECLARE @IdEsternoPrescrizione VARCHAR(64)
	DECLARE @IdPazienteSacAssociato UNIQUEIDENTIFIER
	

	DECLARE @Associati int
	DECLARE @Corrente int
	DECLARE @Totale int

	OPEN curPrescrizioni

	SET @Associati = 0
	SET @Corrente = 0
	SET @Totale = @@CURSOR_ROWS

	FETCH NEXT FROM curPrescrizioni INTO @IdPrescrizione, @DataPrescrizione, @DataModificaPrescrizione,	@IdEsternoPrescrizione
		, @Nome, @Cognome, @CodiceSanitario, @CodiceFiscale, @DataNascita
	WHILE (@@fetch_status <> -1)
		BEGIN
		SET @Corrente = @Corrente + 1
		IF (@@fetch_status <> -2)
			BEGIN
			
			SET @NomeAnagrafica = NULL
			SET @CodiceAnagrafica = NULL
			SET @IdEsternoPaziente = NULL
			
			PRINT 'MntPrescrizioniAssociaPaziente: Paziente della prescrizione: @Nome=' + ISNULL(@Nome, 'Nullo')
					+ ' @Cognome=' + ISNULL( @Cognome, 'Nullo')
					+ ' @CodiceSanitario=' + ISNULL( @CodiceSanitario, 'Nullo')
					+ ' @CodiceFiscale=' + ISNULL( @CodiceFiscale, 'Nullo')
					+ ' @DataNascita=' + ISNULL(CONVERT(VARCHAR(20), @DataNascita, 102), 'Nullo')
					--+ ' @NomeAnagrafica=' + ISNULL(@NomeAnagrafica, 'Nullo')
					--+ ' @CodiceAnagrafica=' + ISNULL( @CodiceAnagrafica, 'Nullo')
					--+ ' @IdEsternoPaziente=' + ISNULL(@IdEsternoPaziente, 'Nullo')
					+ ' @DataPrescrizione=' + ISNULL(CONVERT(VARCHAR(40), @DataPrescrizione, 120), 'Nullo')
					+ ' @DataModificaPrescrizione=' + ISNULL(CONVERT(VARCHAR(40), @DataModificaPrescrizione, 120), 'Nullo')
			
			-- ==================================================================================================
			-- Eseguo una verifica si IdEsternoPaziente e se vuoto lo valorizzo con un GUID
			-- ==================================================================================================
			IF ISNULL(@IdEsternoPaziente, '') = '' 
				SET @IdEsternoPaziente = NEWID()
				
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
				-- Paziente trovato: aggiorno la prescrizione e inserisco nella coda delle notifiche
				-- =============================================
				PRINT 'Prescrizione con Id=' + CONVERT(VARCHAR(40), @IdPrescrizione) + ' associata a IdPaziente=' + CONVERT(VARCHAR(40), @IdPazienteSacAssociato)
				--
				-- Aggiorno la prescrizione
				--
				UPDATE store.PrescrizioniBase
					SET IdPaziente=@IdPazienteSacAssociato
						,DataModifica=GETDATE()
					WHERE Id=@IdPrescrizione
				--
				-- Inserisco record di notifica
				-- solo se il referto è non è più vecchio di N giorni
				-- o è stato movimentato negli ultimi N giorni
				--
				IF (@DataPrescrizione >= DATEADD(day, - @NotificaSeMovimentatoDaNGiorni, GETDATE()) )
					OR (@DataModificaPrescrizione >= DATEADD(day, - @NotificaSeMovimentatoDaNGiorni, GETDATE()) )
				BEGIN
					DECLARE @IdCorrelazione VARCHAR(64)
					DECLARE @TimeoutCorrelazione INT
					DECLARE @OrdineInvio SMALLINT
					--
					-- Valorizzo l'Id di correlazione, timeout di correlazione, ordine di invio
					--
					SET @IdCorrelazione =  'SOLE'
					SET @TimeoutCorrelazione = 0
					SET @OrdineInvio = 0
					--
					-- Eseguo l'inserimento (sempre log di modifica: Operazione=1)
					--
					INSERT INTO CodaPrescrizioniOutput (IdPrescrizione,Operazione, IdCorrelazione, CorrelazioneTimeout,  OrdineInvio, Messaggio)
					VALUES(@IdPrescrizione, 1 , @IdCorrelazione , @TimeoutCorrelazione , @OrdineInvio, dbo.GetPrescrizioneXml(@IdPrescrizione))
				END
				--
				-- Bisognerebbe comandare il ricalcolo dell'anteprima anche per le prescrizioni
				--
				--EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPazienteSacAssociato, 1, 0
				
				--
				-- Eseguo log dell'operazione
				--
				INSERT INTO dbo.LogMntAggancioPaziente(Oggetto, IdPaziente, AziendaErogante, SistemaErogante, IdOggetto, IdEsternoOggetto)
				VALUES ('Prescrizione', @IdPazienteSacAssociato, '' , '', @IdPrescrizione, @IdEsternoPrescrizione)

				SET @Associati = @Associati + 1
			END
			ELSE
			BEGIN
				PRINT 'Prescrizione Id=' + CONVERT(VARCHAR(40), @IdPrescrizione) + ' orfano!'
			END
			END
			PRINT ''
		-- Prossima riga
		FETCH NEXT FROM curPrescrizioni INTO @IdPrescrizione, @DataPrescrizione, @DataModificaPrescrizione,	@IdEsternoPrescrizione
			, @Nome, @Cognome, @CodiceSanitario, @CodiceFiscale, @DataNascita
		END
	-- Fine
	PRINT 'Prescrizioni associate: ' + CONVERT(VARCHAR(10), @Associati) + ' su ' + CONVERT(VARCHAR(10), @Totale)

	CLOSE curPrescrizioni
	DEALLOCATE curPrescrizioni
END