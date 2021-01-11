
CREATE PROC [organigramma_admin].[AziendeLista]

AS
BEGIN
  SET NOCOUNT OFF

SELECT 
     
      Codice,
      Codice as Descrizione
                      
  FROM organigramma.Aziende

END
