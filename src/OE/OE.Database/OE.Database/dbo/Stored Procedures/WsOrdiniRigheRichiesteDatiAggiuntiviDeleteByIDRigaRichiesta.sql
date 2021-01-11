

-- =============================================
-- Author:		Alesandro Nostini
-- Create date: 2013-09-26
-- Modify date: 2013-09-26
-- Description:	Elimina i dati aggiuntivi di una riga
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteDatiAggiuntiviDeleteByIDRigaRichiesta]
	@IDRigaRichiesta uniqueidentifier
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE OrdiniRigheRichiesteDatiAggiuntivi
			WHERE IDRigaRichiesta = @IDRigaRichiesta
			
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
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteDatiAggiuntiviDeleteByIDRigaRichiesta] TO [DataAccessWs]
    AS [dbo];

