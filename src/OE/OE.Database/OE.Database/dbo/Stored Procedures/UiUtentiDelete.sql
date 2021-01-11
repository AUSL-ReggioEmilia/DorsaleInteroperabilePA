
-- =============================================
-- Author:		Bellini
-- Create date: 2014-09-26
-- Modify date: 2018-10-16 - refactoty
-- Description:	Controlla se l'utente ha accesso al OE , utente o gruppo
-- =============================================
CREATE PROCEDURE [dbo].[UiUtentiDelete]
(
@ID as uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	UPDATE [dbo].Utenti
	   SET Attivo = 0
	 WHERE [ID] = @ID
	   
	SELECT *
	FROM Utenti
	WHERE [ID] = @ID

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiUtentiDelete] TO [DataAccessUi]
    AS [dbo];

