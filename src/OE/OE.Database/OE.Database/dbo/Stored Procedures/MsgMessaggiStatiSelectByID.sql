



-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-13
-- Modify date: 2010-12-21
-- Description:	Seleziona un messaggio di stato by id
-- =============================================
CREATE PROCEDURE [dbo].[MsgMessaggiStatiSelectByID]
	@ID uniqueidentifier

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT 
			    ID
			  , DataInserimento
			  , DataModifica
			  , IDTicketInserimento
			  , IDTicketModifica
			  , IDOrdineErogatoTestata
			  , IDSistemaRichiedente
			  , IDRichiestaRichiedente
			  , Messaggio
			  , Stato
			  
		FROM 
			MessaggiStati
		
		WHERE 
				ID = @ID
			AND Stato = 0
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END
























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgMessaggiStatiSelectByID] TO [DataAccessMsg]
    AS [dbo];

