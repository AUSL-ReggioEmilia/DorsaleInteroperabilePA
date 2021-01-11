


CREATE PROCEDURE [dbo].[UiGruppiUtentiInsert]

@Descrizione as varchar(128),
@Note AS VARCHAR(1024) = NULL

AS
BEGIN
SET NOCOUNT ON

declare @newId as uniqueidentifier = NEWID()

INSERT INTO [dbo].[GruppiUtenti]
           ([ID]
           ,[Descrizione]
		   ,[Note])
     VALUES
           (@newId
           ,@Descrizione
		   ,@Note)


select * from [dbo].[GruppiUtenti] where ID = @newId

SET NOCOUNT OFF
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiGruppiUtentiInsert] TO [DataAccessUi]
    AS [dbo];

