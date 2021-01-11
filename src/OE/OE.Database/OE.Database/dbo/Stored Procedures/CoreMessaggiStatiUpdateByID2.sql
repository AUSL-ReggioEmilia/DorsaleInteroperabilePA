




-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-08
-- Description:	Aggiorna un messaggio di stato
-- =============================================
CREATE PROCEDURE [dbo].[CoreMessaggiStatiUpdateByID2]
	  @IDTicketModifica uniqueidentifier	  
	, @ID uniqueidentifier		  
	, @IDOrdineErogatoTestata uniqueidentifier	  
	, @Stato tinyint
	, @Fault xml
	, @DettaglioErrore varchar(max)

AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
	
		UPDATE MessaggiStati
			SET
				  DataModifica = @DataModifica
				, IDTicketModifica = @IDTicketModifica
				, IDOrdineErogatoTestata = @IDOrdineErogatoTestata
				, Stato = @Stato
				, Fault = @Fault
				, DettaglioErrore = @DettaglioErrore
				
			WHERE 
					IDTicketInserimento = @IDTicketModifica
				AND ID = @ID
				AND Stato = 0
			
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
    ON OBJECT::[dbo].[CoreMessaggiStatiUpdateByID2] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiStatiUpdateByID2] TO [DataAccessWs]
    AS [dbo];

