
-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2011-24-11
-- Description:	Seleziona un messaggio di stato by id
-- =============================================
CREATE PROCEDURE [dbo].[CoreMessaggiStatiSelectByID]
	@ID uniqueidentifier
AS
BEGIN
-- Modify author: Alessandro Nostini
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
			  , IDOrdineErogatoTestata
			  , IDSistemaRichiedente
			  , IDRichiestaRichiedente
			  , Messaggio
			  , Stato
			  , Fault
			  , StatoOrderEntry
			  , DettaglioErrore
		FROM MessaggiStati
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
    ON OBJECT::[dbo].[CoreMessaggiStatiSelectByID] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiStatiSelectByID] TO [DataAccessWs]
    AS [dbo];

