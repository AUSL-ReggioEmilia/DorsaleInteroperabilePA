







-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-11-23
-- Description:	Seleziona una lista di regimi
-- =============================================
CREATE PROCEDURE [dbo].[WsRegimiList]

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT Codice, Descrizione FROM Regimi
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[WsRegimiList] TO [DataAccessWs]
    AS [dbo];

