


-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-07-20
-- Modify date: 2011-07-20
-- Description:	Aggiorna una riga richiesta
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteUpdate]
	  @IDTicketModifica uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
	, @IDRigaRichiedente varchar(64)	  
	, @StatoOrderEntry varchar(16)
	, @DataModificaStato datetime
	, @IDPrestazione uniqueidentifier
	, @IDSistemaErogante uniqueidentifier
	, @IDRigaOrderEntry varchar(64)
	, @IDRigaErogante varchar(64)
	, @IDRichiestaErogante varchar(64)
	, @StatoRichiedente xml
	, @Consensi xml
	
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniRigheRichieste
			SET
				  DataModifica = @DataModifica
				, IDTicketModifica = @IDTicketModifica
				, StatoOrderEntry = @StatoOrderEntry
				, DataModificaStato = @DataModificaStato
				, IDPrestazione = @IDPrestazione
				, IDSistemaErogante = @IDSistemaErogante
				, IDRigaOrderEntry = @IDRigaOrderEntry
				, IDRigaRichiedente = @IDRigaRichiedente
				, IDRigaErogante = @IDRigaErogante
				, IDRichiestaErogante = @IDRichiestaErogante
				, StatoRichiedente = @StatoRichiedente
				, Consensi = @Consensi
		WHERE
				IDOrdineTestata = @IDOrdineTestata
			AND IDRigaRichiedente = @IDRigaRichiedente
			
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
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteUpdate] TO [DataAccessWs]
    AS [dbo];

