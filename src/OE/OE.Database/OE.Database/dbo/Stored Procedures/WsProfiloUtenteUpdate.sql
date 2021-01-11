



-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-05-25
-- Description:	Aggiorna un template utente
-- =============================================
CREATE PROCEDURE [dbo].[WsProfiloUtenteUpdate]
	  @Codice varchar(16)
	, @Descrizione varchar(256)
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
				, Descrizione = @Descrizione
				, UtenteModifica = @UtenteModifica
							
			WHERE Codice = @Codice AND IDSistemaErogante = '00000000-0000-0000-0000-000000000000'
		
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
    ON OBJECT::[dbo].[WsProfiloUtenteUpdate] TO [DataAccessWs]
    AS [dbo];

