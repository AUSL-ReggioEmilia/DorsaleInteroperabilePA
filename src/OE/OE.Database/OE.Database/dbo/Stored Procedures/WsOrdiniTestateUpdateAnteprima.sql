
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-09-24
-- Description:	Aggiorna i dati dell'anteprima della testata ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateUpdateAnteprima]
	  @ID uniqueidentifier
	, @AnteprimaPrestazioni varchar(max)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- UPDATE anteprima
		------------------------------		
		UPDATE OrdiniTestate
		SET AnteprimaPrestazioni = @AnteprimaPrestazioni
		WHERE ID = @ID
					
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
    ON OBJECT::[dbo].[WsOrdiniTestateUpdateAnteprima] TO [DataAccessWs]
    AS [dbo];

