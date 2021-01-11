

-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-10
-- Description: Ricerca multi parametro su [dbo].[Utenti] (usata anche per recuperare il singolo record)
-- Modify date: 
-- =============================================
CREATE PROCEDURE [dbo].[BevsUtentiCerca]
(
  @Id UNIQUEIDENTIFIER = NULL,
  @Utente VARCHAR(128) = NULL
 ,@Descrizione VARCHAR(128) = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF
  
  SELECT TOP 200
	  U.Id
	, R.Id as IdRuolo
	, U.Utente
	, U.Descrizione	
	, COALESCE(R.Codice + ' - ' + R.Descrizione, R.Descrizione, R.Codice) AS Ruolo
		  
  FROM 
	dbo.Utenti U
   
  LEFT JOIN --mi serve per limitare la vista a i soli ruoli configurati da role manager
	dbo.SAC_RuoliUtenti as UR on U.Id = UR.IDUtente AND U.IdRuolo = UR.IDRuolo
 
  LEFT JOIN 
	dbo.SAC_Ruoli R ON UR.IdRuolo = R.ID	
 
  WHERE 
   ( U.Id = @Id )
   OR
   (
     @Id IS NULL
     AND  U.AccessoWs = 1
     AND (U.Utente LIKE '%' + @Utente + '%' OR @Utente IS NULL)
     AND (U.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL)
   )   

  ORDER BY 
	U.Utente
	
	
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsUtentiCerca] TO [ExecuteFrontEnd]
    AS [dbo];

