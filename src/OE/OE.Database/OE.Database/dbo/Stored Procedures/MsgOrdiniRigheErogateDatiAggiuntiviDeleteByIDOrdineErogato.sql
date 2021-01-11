







-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-02-16
-- Modify date: 2011-04-26
-- Description:	Elimina i dati aggiuntivi
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniRigheErogateDatiAggiuntiviDeleteByIDOrdineErogato]
	@IDOrderEntry uniqueidentifier
		
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE OrdiniRigheErogateDatiAggiuntivi
			WHERE 
					IDRigaErogata IN (SELECT ID FROM OrdiniRigheErogate WHERE IDOrdineErogatoTestata = @IDOrderEntry)
				AND Persistente = 0
				
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
    ON OBJECT::[dbo].[MsgOrdiniRigheErogateDatiAggiuntiviDeleteByIDOrdineErogato] TO [DataAccessMsg]
    AS [dbo];

