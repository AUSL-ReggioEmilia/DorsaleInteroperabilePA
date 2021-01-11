
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 
-- Modify date: 2011-11-08 (+parametro @DataPrenotazione)
-- Modify date: 2018-11-08 SANDRO: Aggirnamento campo StatoOrderEntryAggregato
--									su tutte le testate dell'ordine
-- Modify date: 2020-02-25 SANDRO: Aggiunge alla coda della tabella dei fatti una notifica
--
-- Description:	Inserisce una nuova testata ordine erogata
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniErogatiTestateInsert2]
	  @IDTicketInserimento uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
	, @IDSistemaRichiedente uniqueidentifier
	, @IDRichiestaRichiedente varchar(64)
	, @IDSistemaErogante uniqueidentifier
	, @IDRichiestaErogante varchar(64)
	, @StatoOrderEntry varchar(16)
	, @SottoStatoOrderEntry varchar(16)
	, @StatoRisposta varchar(16)
	, @DataModificaStato datetime
	, @StatoErogante xml
	, @Data datetime
	, @Operatore xml
	, @AnagraficaCodice varchar(64)
	, @AnagraficaNome varchar(16)
	, @PazienteIdRichiedente varchar(64)
	, @PazienteIdSac uniqueidentifier
	, @PazienteCognome varchar(64)
	, @PazienteNome varchar(64)
	, @PazienteDataNascita datetime
	, @PazienteSesso varchar(1)
	, @PazienteCodiceFiscale varchar(16)
	, @Paziente xml
	, @Consensi xml
	, @Note varchar(max)
	, @DataPrenotazione datetime
	, @IDSplit tinyint
	
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier = NEWID()
	DECLARE @DataInserimento datetime = GETDATE()
	DECLARE @RetCount int = 0
	
	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------		
		INSERT INTO OrdiniErogatiTestate
		(
			  ID
			, DataInserimento
			, DataModifica
			, IDTicketInserimento
			, IDTicketModifica
			, IDOrdineTestata
			, IDSistemaRichiedente
			, IDRichiestaRichiedente
			, IDSistemaErogante
			, IDRichiestaErogante
			, StatoOrderEntry
			, SottoStatoOrderEntry
			, StatoRisposta
			, DataModificaStato
			, StatoErogante
			, Data
			, Operatore
			, AnagraficaCodice
			, AnagraficaNome
			, PazienteIdRichiedente
			, PazienteIdSac
			, PazienteCognome
			, PazienteNome
			, PazienteDataNascita
			, PazienteSesso
			, PazienteCodiceFiscale
			, Paziente
			, Consensi
			, Note
			, DataPrenotazione
			, IDSplit
		)
		VALUES
		(
			  @ID
			, @DataInserimento
			, @DataInserimento --DataModifica
			, @IDTicketInserimento
			, @IDTicketInserimento --IDTicketModifica
			, @IDOrdineTestata
			, @IDSistemaRichiedente
			, @IDRichiestaRichiedente
			, @IDSistemaErogante
			, @IDRichiestaErogante
			, @StatoOrderEntry
			, @SottoStatoOrderEntry
			, @StatoRisposta
			, @DataModificaStato
			, @StatoErogante
			, @Data
			, @Operatore
			, @AnagraficaCodice
			, @AnagraficaNome
			, @PazienteIdRichiedente
			, @PazienteIdSac
			, @PazienteCognome
			, @PazienteNome
			, @PazienteDataNascita
			, @PazienteSesso
			, @PazienteCodiceFiscale
			, @Paziente
			, @Consensi
			, @Note
			, @DataPrenotazione
			, @IDSplit
		)
					
		SET @RetCount = @@ROWCOUNT

		-------------------------------------------------------
		-- Update tutte le testate erogate
		-- con stato order entry aggregato tra le testate
		--
		-- VERIFICARE possibili DEAD-LOCKED
		-------------------------------------------------------

		IF NOT @StatoRisposta IS NULL
		BEGIN

			UPDATE OrdiniErogatiTestate
				SET   StatoOrderEntryAggregato = [dbo].[GetMinStatoErogatoTestateOrderEntry]([IDOrdineTestata])
			WHERE [IDOrdineTestata] = @IDOrdineTestata

			--
			-- Aggiornero la tabella dei fatti per le ricerche di pianificazione
			--
			INSERT INTO [dbo].[RicercaOrdiniCoda] ([IdOrdineTestata]) VALUES (@IDOrdineTestata)
		END
		--
		-- Ret value
		--
		SELECT @RetCount AS [ROWCOUNT]
										
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
		
		SELECT 0 AS [ROWCOUNT]
	END CATCH
	
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniErogatiTestateInsert2] TO [DataAccessMsg]
    AS [dbo];

