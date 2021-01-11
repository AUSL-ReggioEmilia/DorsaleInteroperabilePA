-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-16
-- Description: Inserimento Utente
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[BevsUtentiInserisce]
(
 @Id UNIQUEIDENTIFIER,
 @Utente VARCHAR(128), 
 @Descrizione VARCHAR(256),
 @IdRuolo UNIQUEIDENTIFIER = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  IF EXISTS 
  (
	SELECT 1 
	FROM  dbo.Utenti 
	WHERE  Id = @Id
  )
  BEGIN

	UPDATE dbo.Utenti
	SET Utente	= @Utente		 
	   ,Descrizione	= @Descrizione
	   ,AccessoWs = 1
	   ,IdRuolo = COALESCE(@IdRuolo, IdRuolo)
	WHERE Id = @Id
  
  END
  ELSE BEGIN

	INSERT INTO dbo.Utenti
		(Id
		,Utente
		,Descrizione
		,DomainName
		,AccountName
		,AccessoWs
		,IdRuolo
	   )
	VALUES
		(@Id
		,@Utente		
		,@Descrizione
		,''
		,''
		,1
		,@IdRuolo
		)
	
  END
  
END
  



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsUtentiInserisce] TO [ExecuteFrontEnd]
    AS [dbo];

