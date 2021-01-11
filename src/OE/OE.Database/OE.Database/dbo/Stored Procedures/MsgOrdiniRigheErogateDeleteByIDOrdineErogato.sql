








-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-04-28
-- Modify date: 2011-04-28
-- Description:	Elimina le righe erogate
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateDeleteByIDOrdineErogato]
	@IDOrdineErogatoTestata uniqueidentifier
		
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE OrdiniRigheErogate WHERE IDOrdineErogatoTestata = @IDOrdineErogatoTestata
				
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
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateDeleteByIDOrdineErogato] TO [DataAccessMsg]
    AS [dbo];

