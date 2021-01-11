
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-29 Sandro - Rimosso campo IdUnitaOperativa
-- Modify date: 2018-02-06 Sandro - Rimosso campo CacheGruppiUtente
--									Nuova tabella [dbo].[UtentiGruppiDominio]
-- Description:	Seleziona un ticket by IDUtente e UserName se valido
-- =============================================
CREATE PROCEDURE [dbo].[CoreTicketsSelectIfValid]
	  @IDUtente uniqueidentifier
	, @UserName varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Id uniqueidentifier = NULL

	BEGIN TRY
		------------------------------
		-- Aggiorna la cache dei gruppi di AD, se vecchi si 60 minuti
		------------------------------
		EXEC [dbo].[CoreRicalcolaUtentiGruppiDominio] @UserName, 60

		------------------------------
		-- Cerca se valido
		------------------------------
		SELECT TOP 1 @Id = ID
		FROM Tickets
		WHERE	IDUtente = @IDUtente		
			AND UserName = @UserName
			AND DATEDIFF(second, GETUTCDATE(), DATEADD(minute, TTL, DataLettura)) > 0 
		ORDER BY DataLettura DESC

		IF NOT @Id IS NULL
		BEGIN
			------------------------------
			-- UPDATE
			------------------------------		
			UPDATE Tickets
				SET  DataLettura = GETUTCDATE()
			WHERE Id = @Id
			
			------------------------------
			-- SELECT
			------------------------------
			SELECT ID
				, DataCreazione
				, DataLettura
				, IDUtente
				, UserName
				, TTL
			FROM Tickets
			WHERE ID = @ID
		END
		ELSE
		BEGIN
			------------------------------
			-- SELECT Vuoto
			------------------------------
			SELECT ID
				, DataCreazione
				, DataLettura
				, IDUtente
				, UserName
				, TTL
			FROM Tickets
			WHERE 1=2
		END

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreTicketsSelectIfValid] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreTicketsSelectIfValid] TO [DataAccessWs]
    AS [dbo];

