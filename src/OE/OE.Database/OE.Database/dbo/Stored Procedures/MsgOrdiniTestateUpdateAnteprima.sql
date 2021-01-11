

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2014-09-25
-- Description:	Aggiorna l'anteprima in testata d'ordine by ID
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniTestateUpdateAnteprima]
	  @ID uniqueidentifier
	, @AnteprimaPrestazioni varchar(max)
AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

		------------------------------
		-- UPDATE
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
    ON OBJECT::[dbo].[MsgOrdiniTestateUpdateAnteprima] TO [DataAccessMsg]
    AS [dbo];

