








-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2011-03-11
-- Modify date: 2011-03-11
-- Description:	Stato con i soli dati xml
-- =============================================
CREATE PROCEDURE [dbo].[UiMessaggiStatiSelect]
	@id uniqueidentifier = NULL
	
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT
			 Messaggio,
			 Stato
			 
		FROM 
			MessaggiStati
			
		WHERE
			ID = @id
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END




































GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiMessaggiStatiSelect] TO [DataAccessUi]
    AS [dbo];

