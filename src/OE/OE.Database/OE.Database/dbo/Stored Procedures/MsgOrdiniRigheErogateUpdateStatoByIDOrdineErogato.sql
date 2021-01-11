










-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-05-16
-- Modify date: 2011-05-16
-- Description:	Aggiorna tutte le righe erogate
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateUpdateStatoByIDOrdineErogato]
	  @IDTicketModifica uniqueidentifier
	, @IDOrdineErogatoTestata uniqueidentifier
	, @StatoOrderEntry varchar(16)
	, @DataModificaStato as datetime
	
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
	
		DECLARE @DataModifica datetime
		SET @DataModifica = GETDATE()
	
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniRigheErogate
			SET 
				  DataModifica = @DataModifica
				, StatoOrderEntry = @StatoOrderEntry
				, DataModificaStato = @DataModificaStato
				
			WHERE 
				IDOrdineErogatoTestata = @IDOrdineErogatoTestata
				
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
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateUpdateStatoByIDOrdineErogato] TO [DataAccessMsg]
    AS [dbo];

