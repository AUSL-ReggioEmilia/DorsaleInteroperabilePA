
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-19 Sandro - Rimosso campo IdUnitaOperativa
-- Description:	Seleziona un ticket by ID
-- =============================================
CREATE PROCEDURE [dbo].[CoreTicketsSelectByID2]
	@ID uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
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
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreTicketsSelectByID2] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CoreTicketsSelectByID2] TO [DataAccessWs]
    AS [dbo];

