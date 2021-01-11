

-- =============================================
-- Author:		Alessandro Nosstini
-- Modify date: 2013-03-25
-- Description:	Seleziona i messaggio di una richiesta
-- =============================================
CREATE PROCEDURE [dbo].[CoreMessaggiRichiesteSelectByIDOrdineTestata]
	@IDOrdineTestata uniqueidentifier
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
			  , IDOrdineTestata
			  , IDSistemaRichiedente
			  , IDRichiestaRichiedente
			  , Messaggio
			  , Stato
			  , Fault
			  , StatoOrderEntry
			  , DettaglioErrore
		FROM MessaggiRichieste
		WHERE IDOrdineTestata = @IDOrdineTestata
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
    ON OBJECT::[dbo].[CoreMessaggiRichiesteSelectByIDOrdineTestata] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreMessaggiRichiesteSelectByIDOrdineTestata] TO [DataAccessWs]
    AS [dbo];

