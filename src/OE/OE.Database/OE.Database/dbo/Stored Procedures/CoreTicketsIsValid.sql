
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-19 Sandro - Controlla se il tempo è scaduto
-- Modify date: 2018-02-06 Sandro - Rimosso campo CacheGruppiUtente
--									Nuova tabella [dbo].[UtentiGruppiDominio]
-- Description:	Seleziona un ticket by ID
-- =============================================
CREATE PROCEDURE [dbo].[CoreTicketsIsValid]
	 @ID uniqueidentifier,
	 @IsValid bit OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DataLettura DATETIME2
	DECLARE @TTL INT
	DECLARE @UserName VARCHAR(64)

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------	
		SELECT @DataLettura = DataLettura
			, @TTL = TTL
			, @UserName = UserName
		FROM Tickets
		WHERE ID = @ID

		IF DATEDIFF(second, GETUTCDATE(), DATEADD(minute, @TTL, @DataLettura)) > 0 
			SET @IsValid = 1
		ELSE
			SET @IsValid = 0

		------------------------------
		-- Aggiorna la cache dei gruppi di AD, se vecchi si 60 minuti
		------------------------------
		EXEC [dbo].[CoreRicalcolaUtentiGruppiDominio] @UserName, 60

		RETURN 0
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)

		RETURN 1
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreTicketsIsValid] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreTicketsIsValid] TO [DataAccessWs]
    AS [dbo];

