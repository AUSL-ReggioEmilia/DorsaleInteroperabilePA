

CREATE PROCEDURE [dbo].[UiTrackingSelect]

	@IDMessaggio uniqueidentifier
		
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SELECT Messaggio 

		FROM MessaggiRichieste 
			
		WHERE ID = @IDMessaggio
		
		union ALL
		
		SELECT Messaggio 

		FROM MessaggiStati
			
		WHERE ID = @IDMessaggio
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiTrackingSelect] TO [DataAccessUi]
    AS [dbo];

