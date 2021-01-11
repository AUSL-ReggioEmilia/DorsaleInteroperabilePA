-- =============================================
-- Author:		Alessandro Nostini
-- Create date: <Create Date,,>
-- Modify date: 2018-08-21 sandro - Invalida la cache dell'utente
--
-- Description:	Modifica la membership di un gruppo
-- =============================================

CREATE PROCEDURE [dbo].[UiUtentiGruppiUtentiDelete]
(
@IDUtente as uniqueidentifier,
@IDGruppo as uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	DELETE FROM [dbo].[UtentiGruppiUtenti]
	WHERE IDUtente = @IDUtente
		  AND IDGruppoUtenti = @IDGruppo
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

END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUtentiGruppiUtentiDelete] TO [DataAccessUi]
    AS [dbo];

