






-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-16
-- Modify date: 2011-02-16
-- Description:	Elimina i dati aggiuntivi
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheRichiesteDatiAggiuntiviDeleteByIDOrdine]
	@IDOrderEntry uniqueidentifier
		
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE OrdiniRigheRichiesteDatiAggiuntivi
			WHERE IDRigaRichiesta IN (SELECT ID FROM OrdiniRigheRichieste WHERE IDOrdineTestata = @IDOrderEntry)
			
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
    ON OBJECT::[dbo].[MsgOrdiniRigheRichiesteDatiAggiuntiviDeleteByIDOrdine] TO [DataAccessMsg]
    AS [dbo];

