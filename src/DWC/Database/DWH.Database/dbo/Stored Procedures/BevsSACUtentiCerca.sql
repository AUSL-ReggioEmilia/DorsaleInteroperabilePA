
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-22
-- Description: Ricerca multiparametro su dbo.SAC_Utenti
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[BevsSACUtentiCerca]
(
 @Utente varchar(128) = NULL, 
 @Descrizione varchar(256) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SET @Utente = LTRIM(RTRIM(@Utente))
  
  SELECT TOP (ISNULL(@Top, 1000)) 
      Id,
      Utente,
      Descrizione,
      Cognome,
      Nome,
      CodiceFiscale,
      Matricola,
      Email,    
      Attivo  
  FROM  
	  dbo.SAC_Utenti
  WHERE     
      (Utente LIKE '%' + @Utente + '%' OR @Utente IS NULL) 
      AND 
      (Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) 
  
  ORDER BY Utente
        
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSACUtentiCerca] TO [ExecuteFrontEnd]
    AS [dbo];

