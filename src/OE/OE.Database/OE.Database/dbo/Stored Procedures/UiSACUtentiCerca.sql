
CREATE PROCEDURE [dbo].[UiSACUtentiCerca]
(
 @Utente varchar(128) = NULL,
 @Descrizione varchar(256) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT TOP (ISNULL(@Top, 1000)) 
      [Id],
      [Utente],      
      [Descrizione],
      [Cognome],
      [Nome],
      [CodiceFiscale],
      [Matricola],
      [Email],    
      [Attivo]     
  FROM  [SacOrganigramma].[Utenti] 
  WHERE 
      (Utente LIKE '%' + @Utente + '%' OR @Utente IS NULL) AND 
      (Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) 
      
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSACUtentiCerca] TO [DataAccessUi]
    AS [dbo];

