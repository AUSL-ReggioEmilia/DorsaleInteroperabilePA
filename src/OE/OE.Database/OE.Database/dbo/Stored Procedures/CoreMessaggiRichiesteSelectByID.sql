

-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-24-11
-- Description:	Seleziona un messaggio di richiesta by sistema richiedente
-- =============================================
CREATE PROCEDURE [dbo].[CoreMessaggiRichiesteSelectByID]
	@ID uniqueidentifier
AS
BEGIN
-- Modify author: Alessandro Nosstini
-- Modify date: 2013-03-25

	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT  ID
			  , DataInserimento
			  , DataModifica
			  , IDTicketInserimento
			  , IDTicketModifica
			  , IDOrdineTestata
			  , IDSistemaRichiedente
			  , IDRichiestaRichiedente
			  , Messaggio
			  , Stato
			  , Fault
			  , StatoOrderEntry
			  , DettaglioErrore		  
		FROM MessaggiRichieste
		WHERE ID = @ID
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiRichiesteSelectByID] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiRichiesteSelectByID] TO [DataAccessWs]
    AS [dbo];

