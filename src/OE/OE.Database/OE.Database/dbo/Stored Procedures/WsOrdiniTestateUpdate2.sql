-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-06, 
-- Modify date: 2014-02-13, @AnteprimaPrestazioni
-- Modify date: 2020-02-25 SANDRO: Aggiunge alla coda della tabella dei fatti una notifica
--
-- Description:	Aggiorna la testata ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateUpdate2]
  @ID UNIQUEIDENTIFIER
, @IDTicketModifica UNIQUEIDENTIFIER
, @IDUnitaOperativaRichiedente UNIQUEIDENTIFIER
, @IDSistemaRichiedente UNIQUEIDENTIFIER
, @NumeroNosologico VARCHAR (64)
, @IDRichiestaRichiedente VARCHAR (64)
, @DataRichiesta DATETIME
, @StatoOrderEntry VARCHAR (16)
, @DataModificaStato DATETIME
, @StatoRichiedente XML
, @Data DATETIME
, @Operatore XML
, @Priorita XML
, @TipoEpisodio XML
, @AnagraficaCodice VARCHAR (64)
, @AnagraficaNome VARCHAR (16)
, @PazienteIdRichiedente VARCHAR (64)
, @PazienteIdSac UNIQUEIDENTIFIER
, @PazienteRegime VARCHAR (16)
, @PazienteCognome VARCHAR (64)
, @PazienteNome VARCHAR (64)
, @PazienteDataNascita DATETIME
, @PazienteSesso VARCHAR (1)
, @PazienteCodiceFiscale VARCHAR (16)
, @Paziente XML, @Consensi XML
, @Note VARCHAR(MAX)
, @Regime XML
, @DataPrenotazione DATETIME2 (0)
, @AnteprimaPrestazioni VARCHAR(max) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		-- dati per rollback
		DECLARE @DatiRollback xml
		
		-- Scrivo ROLLBACK solo se era già in SR (inviato a erogante)
		--
		-- Note del 2019-12-16
		-- Salvare qui il ROLLBACK non è consistente perchè i dati delle righe non sono ancora stati aggiornati
		-- I dati da salvare dovrebbero essere generati sul codice .NET
		-- in più non è prevista una procedura di aggiornamento di una richiesta già in SR
		-- Manca comunque anch enel metodo di INSERT
		--
		DECLARE @StatoOrderEntryCorrente varchar(16)
		SELECT @StatoOrderEntryCorrente = StatoOrderEntry FROM OrdiniTestate WHERE ID = @ID
		
		IF @StatoOrderEntryCorrente = 'SR'
			SET @DatiRollback = dbo.GetXMLOrdine(@ID)
		ELSE
			SET @DatiRollback = NULL
	
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniTestate
			SET
				  DataModifica = @DataModifica
				, IDTicketModifica = @IDTicketModifica
				, IDUnitaOperativaRichiedente = @IDUnitaOperativaRichiedente
				, NumeroNosologico = @NumeroNosologico
				, DataRichiesta = @DataRichiesta
				, StatoOrderEntry = @StatoOrderEntry
				, DataModificaStato = @DataModificaStato
				, StatoRichiedente = @StatoRichiedente
				, Data = @Data
				, Operatore = @Operatore
				, Priorita = @Priorita
				, TipoEpisodio = @TipoEpisodio
				, AnagraficaCodice = @AnagraficaCodice
				, AnagraficaNome = @AnagraficaNome
				, PazienteIdRichiedente = @PazienteIdRichiedente
				, PazienteIdSac = @PazienteIdSac
				, PazienteRegime = @PazienteRegime
				, PazienteCognome = @PazienteCognome
				, PazienteNome = @PazienteNome
				, PazienteDataNascita = @PazienteDataNascita
				, PazienteSesso = @PazienteSesso
				, PazienteCodiceFiscale = @PazienteCodiceFiscale
				, Paziente = @Paziente
				, Consensi = @Consensi
				, Note = @Note
				, DatiRollback = @DatiRollback
				, Regime = @Regime
				, DataPrenotazione = @DataPrenotazione
				, AnteprimaPrestazioni = @AnteprimaPrestazioni
			WHERE
				ID = @ID
								
		DECLARE @RowCount INT
		SELECT @RowCount = @@ROWCOUNT

		--
		-- Aggiornero la tabella dei fatti per le ricerche di pianificazione
		--
		INSERT INTO [dbo].[RicercaOrdiniCoda] ([IdOrdineTestata]) VALUES (@ID)

		--
		-- Ritorna le righe inserite
		--
		SELECT @RowCount AS [ROWCOUNT]
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
		
		SELECT @@ROWCOUNT AS [ROWCOUNT]
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsOrdiniTestateUpdate2] TO [DataAccessWs]
    AS [dbo];

