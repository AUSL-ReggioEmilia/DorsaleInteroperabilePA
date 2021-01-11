

-- =============================================
-- Author:		/
-- Date:		/
-- Description:	Inserisce un profilo di Prestazioni
-- ModifyData: 2018-01-22 SimoneB: Aggiunto il parametro @Note
-- =============================================

CREATE PROCEDURE [dbo].[UiProfiliPrestazioniInsert1]
@Codice as varchar(16),
@Descrizione as varchar(128),
@UserName as varchar(64),
@Tipo as int, --1 profilo, 2 template admin, 3 template user 
@Attivo AS BIT,
@Note AS VARCHAR(1024) = NULL

AS
BEGIN
SET NOCOUNT ON

declare @newId as uniqueidentifier = NEWID()
--declare @Codice as varchar(16) 

--IF @Tipo = 3
--	set @Codice = dbo.[GetProgressivoPrestazioni](0)
--else
--	set @Codice = dbo.[GetProgressivoPrestazioni](1)

INSERT INTO [dbo].[Prestazioni]
           ([ID]
           ,[DataInserimento]
           ,[DataModifica]
           ,[IDTicketInserimento]
           ,[IDTicketModifica]
           ,[Codice]
           ,[Descrizione]
           ,[Tipo]
           ,[Provenienza]
           ,[IDSistemaErogante]
           ,Attivo
           ,UtenteInserimento 
           ,UtenteModifica
		   ,[Note])
     VALUES
           (@newId
           ,GETDATE()
           ,GETDATE()
           ,'00000000-0000-0000-0000-000000000000' 
           ,'00000000-0000-0000-0000-000000000000' 
           ,@Codice
           ,@Descrizione
           ,@Tipo
           ,4
           ,'00000000-0000-0000-0000-000000000000' 
           ,@Attivo
           ,@UserName
           ,@UserName
		   ,@Note)

select * from Prestazioni WHERE [ID] = @newId

SET NOCOUNT OFF
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiProfiliPrestazioniInsert1] TO [DataAccessUi]
    AS [dbo];

