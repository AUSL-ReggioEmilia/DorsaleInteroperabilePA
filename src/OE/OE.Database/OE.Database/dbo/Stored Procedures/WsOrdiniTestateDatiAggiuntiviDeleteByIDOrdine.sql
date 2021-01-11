





-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-07-20
-- Modify date: 2011-07-20
-- Description:	Elimina un dato aggiuntivo
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateDatiAggiuntiviDeleteByIDOrdine]
	@IDOrdineTestata uniqueidentifier
		
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE FROM OrdiniTestateDatiAggiuntivi
			WHERE IDOrdineTestata = @IDOrdineTestata AND Persistente = 0
			
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
    ON OBJECT::[dbo].[WsOrdiniTestateDatiAggiuntiviDeleteByIDOrdine] TO [DataAccessWs]
    AS [dbo];

