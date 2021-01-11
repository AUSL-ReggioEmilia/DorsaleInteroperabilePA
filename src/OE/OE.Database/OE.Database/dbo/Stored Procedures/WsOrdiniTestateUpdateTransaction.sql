





-- =============================================
-- Author:		Francesco Pichierri
-- Modify date: 2012-03-06
-- Description:	Aggiorna i dati di transazione di una testata ordine
-- =============================================
CREATE PROCEDURE [dbo].[WsOrdiniTestateUpdateTransaction]
	  @ID uniqueidentifier
	, @StatoValidazione varchar(16)
	, @Validazione xml
	, @StatoTransazione varchar(16)
	
AS
BEGIN
	--SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- UPDATE
		------------------------------		
		UPDATE OrdiniTestate
			SET
				  StatoValidazione = @StatoValidazione
				, Validazione = @Validazione
				, StatoTransazione = @StatoTransazione
				, DataTransazione = GETDATE()
				
			WHERE 
				ID = @ID
					
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
    ON OBJECT::[dbo].[WsOrdiniTestateUpdateTransaction] TO [DataAccessWs]
    AS [dbo];

