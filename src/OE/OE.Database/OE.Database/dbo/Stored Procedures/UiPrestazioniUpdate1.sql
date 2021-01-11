


-- =============================================
-- Author:		--
-- Create date: --
-- Description: Modifica una prestazione
-- Modify Date: SimoneBitti - 23-07-2018: Aggiunto filtro @RichiedibileSoloDaProfilo.
-- =============================================
CREATE PROCEDURE [dbo].[UiPrestazioniUpdate1]

 @ID as uniqueidentifier
,@Codice as varchar(16)
,@Descrizione as varchar(256)
,@IDSistemaErogante as uniqueidentifier
,@UserName as varchar(64)
,@Attivo as bit
,@CodiceSinonimo as varchar(16)
,@RichiedibileSoloDaProfilo AS BIT

AS
BEGIN
SET NOCOUNT ON


UPDATE [dbo].[Prestazioni]
   SET [DataModifica] = GETDATE()
      ,UtenteModifica = @UserName
      ,[IDTicketModifica] = '00000000-0000-0000-0000-000000000000'  
      ,[Codice] = @Codice
      ,[Descrizione] = @Descrizione  
      ,[IDSistemaErogante] = @IDSistemaErogante
      , Attivo = @Attivo
      , CodiceSinonimo = @CodiceSinonimo
	  ,RichiedibileSoloDaProfilo = @RichiedibileSoloDaProfilo
 WHERE [ID] = @ID
	   
select * from Prestazioni WHERE [ID] = @ID

SET NOCOUNT OFF
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniUpdate1] TO [DataAccessUi]
    AS [dbo];

