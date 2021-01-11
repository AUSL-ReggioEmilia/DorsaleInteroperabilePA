
CREATE PROCEDURE [dbo].[UiSACGruppiCerca]
(
 @Gruppo varchar(128) = NULL,
 @Descrizione varchar(256) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT TOP (ISNULL(@Top, 1000)) 
      Id,
      Gruppo,
      Descrizione,     
      Attivo     
  FROM  SacOrganigramma.Gruppi 
  WHERE 
      (Gruppo LIKE '%' + @Gruppo + '%' OR @Gruppo IS NULL) AND 
      (Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) 
      
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSACGruppiCerca] TO [DataAccessUi]
    AS [dbo];

