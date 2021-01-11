


CREATE PROCEDURE [dbo].[UiPrestazioniInsertOrUpdate]

 @Codice as varchar(16)
,@Descrizione as varchar(256)
,@IDSistemaErogante as uniqueidentifier
,@UserName as varchar(64)
,@Attivo as bit
,@CodiceSinonimo as varchar(16)


AS
BEGIN
SET NOCOUNT ON

IF NOT EXISTS(SELECT * FROM Prestazioni WHERE Codice = @Codice AND IDSistemaErogante = @IDSistemaErogante)
    
    BEGIN
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
           ,CodiceSinonimo)
		 VALUES
           (NEWID()
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
           ,@CodiceSinonimo)
    END
    
ELSE
    
    BEGIN
      UPDATE [dbo].[Prestazioni]
	  SET [DataModifica] = GETDATE()
		  ,UtenteModifica = @UserName
		  ,[IDTicketModifica] = '00000000-0000-0000-0000-000000000000'  
		  ,[Codice] = @Codice
		  ,[Descrizione] = @Descrizione  
		  ,[IDSistemaErogante] = @IDSistemaErogante
		  , Attivo = @Attivo
		  , CodiceSinonimo = @CodiceSinonimo
	 WHERE Codice = @Codice AND IDSistemaErogante = @IDSistemaErogante 
    END
    
SET NOCOUNT OFF
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiPrestazioniInsertOrUpdate] TO [DataAccessUi]
    AS [dbo];

