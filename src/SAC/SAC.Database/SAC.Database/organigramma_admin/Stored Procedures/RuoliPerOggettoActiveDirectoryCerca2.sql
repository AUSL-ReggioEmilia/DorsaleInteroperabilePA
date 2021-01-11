


-- =============================================
-- Author:		Kyrylo A.
-- Create date: 2020-10-26
--
-- Description:	Ottiene tutti i ruoli associati all'oggettoActiveDirectory passato.
-- =============================================
CREATE PROCEDURE [organigramma_admin].[RuoliPerOggettoActiveDirectoryCerca2]
(
 @OggettiActiveDirectoryID uniqueidentifier = NULL, --se si passa NULL filtra su tutti i ruoli
 @Codice varchar(128) = NULL,
 @Descrizione varchar(128) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  IF @OggettiActiveDirectoryID IS NULL BEGIN
	 /* 
	 **   cerco fra tutti i ruoli presenti su DB
	 */
	 SELECT TOP (ISNULL(@Top, 500)) 
		  R.ID as ID,      --passo l'Id tanto per non lasciare null
		  R.ID as IdRuolo, --idem         
		  R.Codice,
		  R.Descrizione,
		  
		  CONVERT(VARCHAR(32), NULL) AS TipoAbilitazione,
		  CONVERT(VARCHAR(128), NULL) AS GruppoAbilitante

	  FROM  
		Organigramma.Ruoli R 
	  WHERE 
		(		  
		  (R.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND
		  (R.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL)
		)    
  	  ORDER BY 
		  R.Codice 

  END
  ELSE BEGIN
	 /* 
	 **   cerco fra i RuoliOggettiActiveDirectory associati all'oggetto AD
	 */

	 -- Ruoli per appartenenza a gruppo
	  SELECT TOP (ISNULL(@Top, 500)) 
		  RO.ID,
		  RO.IdRuolo,
		  R.Codice,
		  R.Descrizione,
		  
		  CONVERT(VARCHAR(32), 'Gruppo') AS TipoAbilitazione,
		  UG.Gruppo AS GruppoAbilitante

	  FROM organigramma.Ruoli R
		INNER JOIN organigramma.RuoliOggettiActiveDirectory RO
			ON R.ID = RO.IdRuolo
		INNER JOIN organigramma_da.GruppiUtenti UG
			ON UG.IdGruppo =  RO.IdUtente
	  WHERE 
		  UG.IdUtente = @OggettiActiveDirectoryID AND
		  (		  
		    (R.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND
		    (R.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL)
		  )    
	  
	  UNION

	  -- Ruoli per utente
	  SELECT 
		  RO.ID,
		  RO.IdRuolo,
		  R.Codice,
		  R.Descrizione,

		  CONVERT(VARCHAR(32), 'Utente') AS TipoAbilitazione,
		  CONVERT(VARCHAR(128), NULL) AS GruppoAbilitante

	  FROM organigramma.Ruoli R
		  INNER JOIN organigramma.RuoliOggettiActiveDirectory RO
		  	  ON R.ID = RO.IdRuolo
		  INNER JOIN organigramma.OggettiActiveDirectory O
			  ON O.ID = RO.IdUtente

	  WHERE 
		  O.ID = @OggettiActiveDirectoryID AND
		  (		  
		    (R.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND
		    (R.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL)
		  )    
  	    ORDER BY 
		    R.Codice 

	END

END