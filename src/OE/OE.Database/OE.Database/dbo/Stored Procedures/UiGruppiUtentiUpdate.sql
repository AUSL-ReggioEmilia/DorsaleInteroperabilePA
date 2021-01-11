


CREATE PROCEDURE [dbo].[UiGruppiUtentiUpdate]

@ID as uniqueidentifier,
@Descrizione as varchar(128),
@Note AS VARCHAR(1024) = NULL

AS
BEGIN
SET NOCOUNT ON

UPDATE [dbo].[GruppiUtenti]
   SET [Descrizione] = @Descrizione
		,[Note] = @Note
 WHERE [ID] = @ID

select * from [dbo].[GruppiUtenti] where ID = @ID

SET NOCOUNT OFF
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiUtentiUpdate] TO [DataAccessUi]
    AS [dbo];

