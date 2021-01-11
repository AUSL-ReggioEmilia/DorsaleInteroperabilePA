



-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-25
-- Description:	Cancella logicamente un template utente
-- =============================================
CREATE PROCEDURE [dbo].[WsProfiloUtenteDelete]
	  @IdProfilo uniqueidentifier
	, @UtenteModifica varchar(64)

AS
BEGIN
	--SET NOCOUNT ON;

	DECLARE @DataModifica datetime
	SET @DataModifica = GETDATE()
	
	BEGIN TRY
		
		UPDATE Prestazioni
			SET
				  DataModifica = @DataModifica
				, Attivo = 0
				, UtenteModifica = @UtenteModifica
							
			WHERE ID = @IdProfilo
			
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
    ON OBJECT::[dbo].[WsProfiloUtenteDelete] TO [DataAccessWs]
    AS [dbo];

