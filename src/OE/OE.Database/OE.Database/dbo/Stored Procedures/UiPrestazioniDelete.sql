


CREATE PROCEDURE [dbo].[UiPrestazioniDelete]

 @ID as uniqueidentifier
,@UserName as varchar(64)

AS
BEGIN
SET NOCOUNT ON


UPDATE [dbo].[Prestazioni]
   SET [DataModifica] = GETDATE()
      ,UtenteModifica = @UserName
      ,[IDTicketModifica] = '00000000-0000-0000-0000-000000000000'     
      , Attivo = 0
 WHERE [ID] = @ID
	   
select * from Prestazioni WHERE [ID] = @ID

SET NOCOUNT OFF
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniDelete] TO [DataAccessUi]
    AS [dbo];

