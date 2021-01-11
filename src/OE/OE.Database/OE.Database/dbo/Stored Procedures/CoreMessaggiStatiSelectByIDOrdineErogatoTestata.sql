
-- =============================================
-- Author: Alessandro Nostini
-- Modify date: 2013-03-25
-- Description:	Seleziona i messaggio di stato di un erogante
-- =============================================
CREATE PROCEDURE [dbo].[CoreMessaggiStatiSelectByIDOrdineErogatoTestata]
	@IDOrdineErogatoTestata uniqueidentifier
AS
BEGIN

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
		WHERE IDOrdineErogatoTestata = @IDOrdineErogatoTestata
		ORDER BY DataInserimento DESC
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiStatiSelectByIDOrdineErogatoTestata] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiStatiSelectByIDOrdineErogatoTestata] TO [DataAccessWs]
    AS [dbo];

