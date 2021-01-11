




-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-02-13
-- Description:	Inserisce una nuova testata ordine erogata
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniErogatiTestateInsert2]
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
	, @IDSplit tinyint
	
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataInserimento datetime
	SET @DataInserimento = GETDATE()
	
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
			, @IDSplit
		)
					
		SELECT @@ROWCOUNT AS [ROWCOUNT]
								
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
    ON OBJECT::[dbo].[WsOrdiniErogatiTestateInsert2] TO [DataAccessWs]
    AS [dbo];

