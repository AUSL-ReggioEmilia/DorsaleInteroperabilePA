



-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-08
-- Description:	Aggiorna un messaggio di richiesta
-- =============================================
CREATE PROCEDURE [dbo].[CoreMessaggiRichiesteUpdateByID2]
	  @IDTicketModifica uniqueidentifier	  
	, @ID uniqueidentifier
	, @IDOrdineTestata uniqueidentifier
	, @Stato tinyint
	, @Fault xml
	, @DettaglioErrore varchar(max)

AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		
		UPDATE MessaggiRichieste
			SET
				  DataModifica = @DataModifica
				, IDTicketModifica = @IDTicketModifica
				, IDOrdineTestata = @IDOrdineTestata
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
    ON OBJECT::[dbo].[CoreMessaggiRichiesteUpdateByID2] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiRichiesteUpdateByID2] TO [DataAccessWs]
    AS [dbo];

