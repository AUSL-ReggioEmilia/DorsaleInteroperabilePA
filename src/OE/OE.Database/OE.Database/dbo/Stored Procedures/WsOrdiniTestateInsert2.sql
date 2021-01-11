-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-06, 
-- Modify date: 2014-02-13, @AnteprimaPrestazioni
-- Modify date: 2015-01-29 SANDRO: nuova SP per ottenere il numero di ordine per anno
-- Modify date: 2020-02-25 SANDRO: Aggiunge alla coda della tabella dei fatti una notifica
--
-- Description:	Inserisce una nuova testata ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateInsert2]
	  @IDTicketInserimento uniqueidentifier
	, @Anno int
	, @IDUnitaOperativaRichiedente uniqueidentifier
	, @IDSistemaRichiedente uniqueidentifier
	, @NumeroNosologico varchar(64)
	, @IDRichiestaRichiedente varchar(64)
	, @DataRichiesta datetime
	, @StatoOrderEntry varchar(16)
	, @SottoStatoOrderEntry varchar(16)
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
	, @DataPrenotazione datetime2(0)
	, @AnteprimaPrestazioni varchar(max) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
	IF ISNULL(@Data, '') = '' SET @Data = @DataInserimento
	
	DECLARE @Numero int
	EXEC [dbo].[CoreOrdiniOttieniProssimoNumero] @Anno, @Numero OUTPUT
	
	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------		
		INSERT INTO OrdiniTestate
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, Anno
			, Numero
			, IDUnitaOperativaRichiedente
			, IDSistemaRichiedente
			, NumeroNosologico
			, IDRichiestaRichiedente
			, DataRichiesta
			, StatoOrderEntry
			, SottoStatoOrderEntry
			, DataModificaStato
			, StatoRichiedente
			, Data
			, Operatore
			, Priorita
			, TipoEpisodio
			, AnagraficaCodice
			, AnagraficaNome
			, PazienteIdRichiedente
			, PazienteIdSac
			, PazienteRegime
			, PazienteCognome
			, PazienteNome
			, PazienteDataNascita
			, PazienteSesso
			, PazienteCodiceFiscale
			, Paziente
			, Consensi
			, Note
			, Regime
			, DataPrenotazione
			, AnteprimaPrestazioni
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataInserimento
			, @IDTicketInserimento
			, @IDTicketInserimento
			, @Anno
			, @Numero
			, @IDUnitaOperativaRichiedente
			, @IDSistemaRichiedente
			, @NumeroNosologico
			, @IDRichiestaRichiedente
			, @DataRichiesta
			, @StatoOrderEntry
			, @SottoStatoOrderEntry
			, @DataInserimento
			, @StatoRichiedente
			, @Data
			, @Operatore
			, @Priorita
			, @TipoEpisodio
			, @AnagraficaCodice
			, @AnagraficaNome
			, @PazienteIdRichiedente
			, @PazienteIdSac
			, @PazienteRegime
			, @PazienteCognome
			, @PazienteNome
			, @PazienteDataNascita
			, @PazienteSesso
			, @PazienteCodiceFiscale
			, @Paziente
			, @Consensi
			, @Note
			, @Regime
			, @DataPrenotazione
			, @AnteprimaPrestazioni
		)		
	
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
    ON OBJECT::[dbo].[WsOrdiniTestateInsert2] TO [DataAccessWs]
    AS [dbo];

