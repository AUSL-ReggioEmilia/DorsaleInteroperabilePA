
-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-11-08 (+parametro @Regime; @DataPrenotazione)
-- Modify date: 2014-02-13 (+parametro @AnteprimaPrestazioni)
-- Modify date: 2020-02-25 SANDRO: Aggiunge alla coda della tabella dei fatti una notifica
--
-- Description:	Aggiorna la testata d'ordine by ID
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniTestateUpdate]
	  @ID uniqueidentifier
	, @IDTicketModifica uniqueidentifier
	, @IDUnitaOperativaRichiedente uniqueidentifier	
	, @IDSistemaRichiedente uniqueidentifier
	, @NumeroNosologico varchar(64)
	, @IDRichiestaRichiedente varchar(64)
	, @DataRichiesta datetime
	, @StatoOrderEntry varchar(16)
	, @DataModificaStato datetime
	, @StatoRichiedente xml
	, @Data datetime
	, @Operatore xml
	, @Priorita xml
	, @TipoEpisodio xml
	, @AnagraficaCodice varchar(64)
	, @AnagraficaNome  varchar(16)
	, @PazienteIdRichiedente varchar(64)
	, @PazienteIdSac uniqueidentifier
	, @PazienteRegime varchar(16)
	, @PazienteCognome varchar(64)
	, @PazienteNome varchar(64)
	, @PazienteDataNascita datetime
	, @PazienteSesso varchar(1)
	, @PazienteCodiceFiscale varchar(16)
	, @Paziente xml
	, @Consensi xml
	, @Note varchar(max)
	, @Regime xml
	, @DataPrenotazione datetime
	, @AnteprimaPrestazioni varchar(max) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		-- dati per rollback
		DECLARE @DatiRollback xml
		SET @DatiRollback = dbo.GetXMLOrdine(@ID)	
	
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
    ON OBJECT::[dbo].[MsgOrdiniTestateUpdate] TO [DataAccessMsg]
    AS [dbo];

