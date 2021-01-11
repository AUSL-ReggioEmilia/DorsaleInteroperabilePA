



-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-13
-- Modify date: 2011-03-10
-- Description:	Seleziona un messaggio di richiesta by sistema richiedente
-- =============================================
CREATE PROCEDURE [dbo].[MsgMessaggiRichiesteSelectByID]
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
			  , IDOrdineTestata
			  , IDSistemaRichiedente
			  , IDRichiestaRichiedente
			  , Messaggio
			  , Stato
			  
		FROM 
			MessaggiRichieste
					
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
    ON OBJECT::[dbo].[MsgMessaggiRichiesteSelectByID] TO [DataAccessMsg]
    AS [dbo];

