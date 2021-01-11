

-- =============================================
-- Author:		Ettore
-- Create date: 2015-11-27
-- Description:	Restituisce il token associato all'id
-- =============================================
CREATE PROCEDURE [ws3].[TokenById]
(
	@IdToken UNIQUEIDENTIFIER
)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY
		--
		-- Restituisco il record associato all'Id del token
		--
		SELECT 
			Id
			, CodiceRuolo
			, UtenteProcesso
			, UtenteDelegato
		FROM 
			dbo.Tokens
		WHERE 
			Id = @IdToken
		
    END TRY
    BEGIN CATCH
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()
		DECLARE @report NVARCHAR(4000);
		SELECT @report = @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)		
    END CATCH
END