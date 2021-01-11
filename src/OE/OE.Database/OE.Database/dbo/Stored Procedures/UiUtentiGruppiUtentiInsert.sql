
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: <Create Date,,>
-- Modify date: 2018-08-21 sandro - Invalida la cache dell'utente
--
-- Description:	Modifica la membership di un gruppo
-- =============================================
CREATE PROCEDURE [dbo].[UiUtentiGruppiUtentiInsert]
(
@IDUtente as uniqueidentifier,
@IDGruppo as uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @newId as uniqueidentifier = NEWID()

	INSERT INTO [dbo].[UtentiGruppiUtenti]
			   ([ID]
			   ,[IDUtente]
			   ,[IDGruppoUtenti])
		 VALUES
			   (@newId
			   ,@IDUtente
			   ,@IDGruppo)
	--
	-- Invalida la cache dell'utente
	--
	UPDATE [dbo].[UtentiGruppiDominio]
	SET [CacheGruppiUtente] = NULL
	FROM [dbo].[UtentiGruppiDominio] ugd
		INNER JOIN [dbo].[Utenti] u
			ON ugd.UserName = u.[Utente]
	WHERE NOT ugd.[CacheGruppiUtente] IS NULL
		AND u.[ID] = @IDUtente
	--
	-- Ritorna il record inserito
	--
	SELECT *
	FROM [UtentiGruppiUtenti]
	WHERE ID = @newId

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUtentiGruppiUtentiInsert] TO [DataAccessUi]
    AS [dbo];

