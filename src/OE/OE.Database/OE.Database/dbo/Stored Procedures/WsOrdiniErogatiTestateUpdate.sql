




-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-07-20
-- Modify date: 2011-07-20
-- Description:	Aggiorna una testata ordine erogata by id sistema richiedente
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniErogatiTestateUpdate]
	  @ID uniqueidentifier
	, @IDTicketModifica uniqueidentifier
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
	
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniErogatiTestate
			SET
				  DataModifica = @DataModifica
				, IDTicketModifica = @IDTicketModifica
				--, IDOrdineTestata = @IDOrdineTestata
				--, IDSistemaRichiedente = @IDSistemaRichiedente				
				--, IDRichiestaRichiedente = @IDRichiestaRichiedente				
				--, IDSistemaErogante = @IDSistemaErogante
				, IDRichiestaErogante = @IDRichiestaErogante
				, StatoOrderEntry = @StatoOrderEntry
				, SottoStatoOrderEntry = @SottoStatoOrderEntry
				, StatoRisposta = @StatoRisposta
				, DataModificaStato = @DataModificaStato
				, StatoErogante = @StatoErogante
				, Data = @Data
				, Operatore = @Operatore
				, AnagraficaCodice = @AnagraficaCodice
				, AnagraficaNome = @AnagraficaNome
				, PazienteIdRichiedente = @PazienteIdRichiedente
				, PazienteIdSac = @PazienteIdSac
				, PazienteCognome = @PazienteCognome
				, PazienteNome = @PazienteNome
				, PazienteDataNascita = @PazienteDataNascita
				, PazienteSesso = @PazienteSesso
				, PazienteCodiceFiscale = @PazienteCodiceFiscale
				, Paziente = @Paziente
				, Consensi = @Consensi
				, Note = @Note
				
			WHERE 
				ID = @ID
					
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
    ON OBJECT::[dbo].[WsOrdiniErogatiTestateUpdate] TO [DataAccessWs]
    AS [dbo];

