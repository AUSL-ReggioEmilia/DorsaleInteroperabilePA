
-- =============================================
-- Author:		/
-- Date:		/
-- Description:	Inserisce un profilo di Prestazioni
-- ModifyData: 2018-01-22 SimoneB: Aggiunto il parametro @Note
-- =============================================

CREATE PROCEDURE [dbo].[UiProfiliPrestazioniUpdate1]

 @ID as uniqueidentifier
,@Codice as varchar(16)
,@Descrizione as varchar(256)
,@UserName as varchar(64)
,@Tipo as int  --1 profilo, 2 template admin, 3 template user 
,@Attivo AS BIT
,@Note AS VARCHAR(1024) = NULL

AS
BEGIN
SET NOCOUNT ON

UPDATE [dbo].[Prestazioni]
   SET [DataModifica] = GETDATE()
      ,UtenteModifica = @UserName
      ,[IDTicketModifica] = '00000000-0000-0000-0000-000000000000'  
      ,[Codice] = @Codice
      ,[Descrizione] = @Descrizione
      ,Tipo = @Tipo
      ,Attivo = @Attivo
	  ,Note = @Note

 WHERE [ID] = @ID
	   
select * from Prestazioni WHERE [ID] = @ID

SET NOCOUNT OFF
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiProfiliPrestazioniUpdate1] TO [DataAccessUi]
    AS [dbo];

