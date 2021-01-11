
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-02-13
-- Modify date: 2014-02-13
-- Description:	Elimina tutti i dati persistenti
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniErogatiTestateDatiPersistentiDeleteByIDOrdineErogato]
	@IDOrdineErogatoTestata uniqueidentifier
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE FROM OrdiniErogatiTestateDatiAggiuntivi
			WHERE IDOrdineErogatoTestata = @IDOrdineErogatoTestata
				AND Persistente = 1
			
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
    ON OBJECT::[dbo].[MsgOrdiniErogatiTestateDatiPersistentiDeleteByIDOrdineErogato] TO [DataAccessMsg]
    AS [dbo];

