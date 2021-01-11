-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-10
-- Description: Aggiorna una riga di dbo.Utenti
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[BevsUtentiModifica]
(
 @Id UNIQUEIDENTIFIER,
 @IdRuolo UNIQUEIDENTIFIER
)
AS
BEGIN

    UPDATE dbo.Utenti
     SET   
      IdRuolo = @IdRuolo
     OUTPUT 
       INSERTED.[Id]
      ,INSERTED.[DomainName]
      ,INSERTED.[AccountName]
      ,INSERTED.[Nome]
      ,INSERTED.[Email]
      ,INSERTED.[UtenteTecnico]
      ,INSERTED.[Utente]
      ,INSERTED.[Descrizione]
      ,INSERTED.[AccessoWs]
      ,INSERTED.[IdRuolo]
    WHERE Id = @Id
   
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsUtentiModifica] TO [ExecuteFrontEnd]
    AS [dbo];

