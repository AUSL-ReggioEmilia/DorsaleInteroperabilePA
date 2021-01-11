


-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-07-20
-- Modify date: 2010-07-20
-- Description:	Aggiorna la riga richesta d'ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniRigheRichiesteDeleteByIDOrderEntry]
	@IDOrderEntry uniqueidentifier
		
AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		------------------------------
		-- UPDATE
		------------------------------		
		DELETE FROM OrdiniRigheRichieste
			WHERE IDOrdineTestata = @IDOrderEntry
			
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
    ON OBJECT::[dbo].[WsOrdiniRigheRichiesteDeleteByIDOrderEntry] TO [DataAccessWs]
    AS [dbo];

