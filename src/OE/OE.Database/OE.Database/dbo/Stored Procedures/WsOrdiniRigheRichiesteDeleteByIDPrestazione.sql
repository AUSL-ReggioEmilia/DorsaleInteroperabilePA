
-- =============================================
-- Author:		Alessandro	Nostini
-- Create date: 2013-08-21
-- Modify date: 2013-08-21
-- Description:	Cancello una riga richiesta
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteDeleteByIDPrestazione]
	 @IDOrdineTestata uniqueidentifier
	,@IDPrestazione uniqueidentifier 

AS
BEGIN
	SET NOCOUNT ON
	
	BEGIN TRY

		------------------------------
		-- DELETE Dati aggiuntivi
		------------------------------	
		
		DELETE OrdiniRigheRichiesteDatiAggiuntivi
		WHERE IDRigaRichiesta IN (SELECT ID FROM OrdiniRigheRichieste
									WHERE IDOrdineTestata = @IDOrdineTestata
										AND IDPrestazione = @IDPrestazione)

		------------------------------
		-- DELETE
		------------------------------	
			
		DELETE FROM OrdiniRigheRichieste
		WHERE   IDOrdineTestata = @IDOrdineTestata
			AND IDPrestazione = @IDPrestazione
			
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
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteDeleteByIDPrestazione] TO [DataAccessWs]
    AS [dbo];

