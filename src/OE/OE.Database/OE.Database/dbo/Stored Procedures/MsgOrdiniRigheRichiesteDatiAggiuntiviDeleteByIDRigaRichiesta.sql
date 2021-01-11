





-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-03
-- Modify date: 2011-02-03
-- Description:	Elimina un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheRichiesteDatiAggiuntiviDeleteByIDRigaRichiesta]
	@IDRigaRichiesta uniqueidentifier
		
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE FROM OrdiniRigheRichiesteDatiAggiuntivi
			WHERE IDRigaRichiesta = @IDRigaRichiesta --AND Persistente = 0
			
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
    ON OBJECT::[dbo].[MsgOrdiniRigheRichiesteDatiAggiuntiviDeleteByIDRigaRichiesta] TO [DataAccessMsg]
    AS [dbo];

