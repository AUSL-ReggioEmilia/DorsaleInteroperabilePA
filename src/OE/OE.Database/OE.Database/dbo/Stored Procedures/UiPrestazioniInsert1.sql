

-- =============================================
-- Author:		--
-- Create date: --
-- Description: inserisce una prestazione
-- Modify Date: SimoneBitti - 23-07-2018: Aggiunto filtro @RichiedibileSoloDaProfilo.
-- =============================================
CREATE PROCEDURE [dbo].[UiPrestazioniInsert1]
 
 @Codice as varchar(16)
,@Descrizione as varchar(256)
,@IDSistemaErogante as uniqueidentifier
,@UserName as varchar(64)
,@Attivo as bit
,@CodiceSinonimo as varchar(16)
,@RichiedibileSoloDaProfilo AS BIT

AS
BEGIN
SET NOCOUNT ON

declare @newId as uniqueidentifier = NEWID()

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
           ,CodiceSinonimo
		   ,RichiedibileSoloDaProfilo)
     VALUES
           (@newId
           ,GETDATE()
           ,GETDATE()
           ,'00000000-0000-0000-0000-000000000000' 
           ,'00000000-0000-0000-0000-000000000000' 
           ,@Codice
           ,@Descrizione
           ,0
           ,4
           ,@IDSistemaErogante
           ,@Attivo
           ,@UserName
           ,@UserName
           ,@CodiceSinonimo
		   ,@RichiedibileSoloDaProfilo)

select * from Prestazioni WHERE [ID] = @newId


SET NOCOUNT OFF
END








GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniInsert1] TO [DataAccessUi]
    AS [dbo];

