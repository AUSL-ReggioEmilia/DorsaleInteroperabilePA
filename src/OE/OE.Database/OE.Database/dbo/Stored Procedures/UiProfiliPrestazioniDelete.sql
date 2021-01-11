



create PROCEDURE [dbo].[UiProfiliPrestazioniDelete]

 @Id as uniqueidentifier
,@UserName as varchar(64)

AS
BEGIN
SET NOCOUNT ON


UPDATE [dbo].[Prestazioni]
   SET [DataModifica] = GETDATE()
      ,UtenteModifica = @UserName
      ,[IDTicketModifica] = '00000000-0000-0000-0000-000000000000'     
      ,Attivo = 0
 WHERE [ID] = @Id
	   
select * from Prestazioni WHERE [ID] = @Id

SET NOCOUNT OFF
END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiProfiliPrestazioniDelete] TO [DataAccessUi]
    AS [dbo];

