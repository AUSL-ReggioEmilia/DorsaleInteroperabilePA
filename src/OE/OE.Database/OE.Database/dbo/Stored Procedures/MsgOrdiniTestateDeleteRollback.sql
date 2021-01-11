-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2015-01-30 SANDRO: Evita il problema del deadlock in lettura ordine
--									Saranno rimossi in modalità batch
-- Description:	Rimuove i dati per il roolback
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniTestateDeleteRollback]
@ID UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- UPDATE
		------------------------------		
		--UPDATE OrdiniTestate
		--	SET DatiRollback = NULL
		--	WHERE ID = @ID
		--		AND NOT DatiRollback IS NULL
								
		--SELECT @@ROWCOUNT AS [ROWCOUNT]
		SELECT 1 AS [ROWCOUNT]
			
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
    ON OBJECT::[dbo].[MsgOrdiniTestateDeleteRollback] TO [DataAccessMsg]
    AS [dbo];

