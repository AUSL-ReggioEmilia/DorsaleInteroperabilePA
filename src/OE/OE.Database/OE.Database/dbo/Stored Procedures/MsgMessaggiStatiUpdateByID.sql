﻿


-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-11
-- Modify date: 2011-03-10
-- Description:	Aggiorna un messaggio di stato
-- =============================================
CREATE PROCEDURE [dbo].[MsgMessaggiStatiUpdateByID]
	  @IDTicketModifica uniqueidentifier	  
	, @ID uniqueidentifier		  
	, @IDOrdineErogatoTestata uniqueidentifier	  
	, @Stato tinyint
	, @Fault xml

AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE MessaggiStati
			SET
				  DataModifica = @DataModifica
				, IDTicketModifica = @IDTicketModifica
				, IDOrdineErogatoTestata = @IDOrdineErogatoTestata
				, Stato = @Stato
				, Fault = @Fault				
				
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
    ON OBJECT::[dbo].[MsgMessaggiStatiUpdateByID] TO [DataAccessMsg]
    AS [dbo];

