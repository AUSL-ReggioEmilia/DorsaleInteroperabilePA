
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-29 Sandro - Rimosso campo IdUnitaOperativa
-- Modify date: 2018-02-06 Sandro - Rimosso campo CacheGruppiUtente
--									Nuova tabella [dbo].[UtentiGruppiDominio]
-- Description:	Inserisce un nuovo ticket
-- =============================================
CREATE PROCEDURE [dbo].[CoreTicketsInsert2]
	  @IDUtente uniqueidentifier
	, @UserName varchar(64)
	, @TTL int
	, @IDTicket uniqueidentifier OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ID uniqueidentifier
	SET @ID = NEWID()
	
	DECLARE @DataCreazione datetime
	SET @DataCreazione = GETUTCDATE()

	BEGIN TRY
		------------------------------
		-- INSERT
		------------------------------		
		INSERT INTO Tickets
		(	  ID
			, DataCreazione
			, DataLettura
			, IDUtente
			, UserName
			, TTL
		)
		VALUES
		(
			  @ID
			, @DataCreazione
			, @DataCreazione
			, @IDUtente
			, @UserName
			, @TTL
		)
		
		------------------------------
		-- SET Output
		------------------------------
		SET @IDTicket = @ID

		------------------------------
		-- Aggiorna la cache dei gruppi di AD, sempre
		------------------------------
		EXEC [dbo].[CoreRicalcolaUtentiGruppiDominio] @UserName, 0

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
    ON OBJECT::[dbo].[CoreTicketsInsert2] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreTicketsInsert2] TO [DataAccessWs]
    AS [dbo];

