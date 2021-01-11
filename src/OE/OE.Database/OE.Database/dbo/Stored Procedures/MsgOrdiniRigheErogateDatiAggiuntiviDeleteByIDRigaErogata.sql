






-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-10
-- Modify date: 2011-02-10
-- Description:	Elimina un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateDatiAggiuntiviDeleteByIDRigaErogata]
	@IDRigaErogata uniqueidentifier
		
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE FROM OrdiniRigheErogateDatiAggiuntivi
			WHERE IDRigaErogata = @IDRigaErogata AND Persistente = 0
			
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
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateDatiAggiuntiviDeleteByIDRigaErogata] TO [DataAccessMsg]
    AS [dbo];

