




-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-05-12
-- Modify date: 2011-05-12
-- Description:	Elimina le righe richieste e relativi dati aggiuntivi
-- =============================================
CREATE PROCEDURE [dbo].[MsgRollbackOrdiniDeleteAll]
	  @IDOrdineTestata uniqueidentifier
	, @Data datetime
	
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- DELETE
		------------------------------		
		DELETE FROM OrdiniRigheRichiesteDatiAggiuntivi WHERE IDRigaRichiesta IN (
							SELECT ID FROM OrdiniRigheRichieste WHERE IDOrdineTestata = @IDOrdineTestata)
		DELETE FROM OrdiniRigheRichieste WHERE IDOrdineTestata = @IDOrdineTestata
		DELETE FROM OrdiniTestateDatiAggiuntivi WHERE IDOrdineTestata = @IDOrdineTestata
		DELETE FROM OrdiniVersioni WHERE IDOrdineTestata = @IDOrdineTestata AND Data = @Data
		
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
    ON OBJECT::[dbo].[MsgRollbackOrdiniDeleteAll] TO [DataAccessMsg]
    AS [dbo];

