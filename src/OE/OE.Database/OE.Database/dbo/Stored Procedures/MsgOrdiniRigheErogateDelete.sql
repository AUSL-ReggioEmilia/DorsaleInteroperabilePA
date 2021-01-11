
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-04-10
-- Description:	Cancella una riga erogata d'ordine
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateDelete]
	@ID uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		------------------------------
		-- DELETE
		------------------------------	
		DELETE FROM OrdiniRigheErogateDatiAggiuntivi
		WHERE IDRigaErogata = @ID
		
		DELETE OrdiniRigheErogate
		WHERE ID  = @ID
				
		SELECT @@ROWCOUNT AS [ROWCOUNT]
						
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()
		RAISERROR(@ErrorMessage, 16, 1)
		
		SELECT 0 AS [ROWCOUNT]
	END CATCH
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateDelete] TO [DataAccessMsg]
    AS [dbo];

