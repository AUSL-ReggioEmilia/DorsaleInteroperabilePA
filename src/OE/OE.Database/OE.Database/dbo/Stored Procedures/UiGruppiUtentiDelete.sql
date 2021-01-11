


CREATE PROCEDURE [dbo].[UiGruppiUtentiDelete]

@ID as uniqueidentifier

AS
BEGIN
SET NOCOUNT ON

delete from UtentiGruppiUtenti where IDGruppoUtenti = @ID

delete from GruppiUtenti where ID = @ID

SET NOCOUNT OFF
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiUtentiDelete] TO [DataAccessUi]
    AS [dbo];

