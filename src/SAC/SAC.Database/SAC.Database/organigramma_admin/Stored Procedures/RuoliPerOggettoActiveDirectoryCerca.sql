CREATE PROC [organigramma_admin].[RuoliPerOggettoActiveDirectoryCerca]
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
		  R.Descrizione		
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
	  SELECT TOP (ISNULL(@Top, 500)) 
		  RUO.ID,
		  RUO.IdRuolo,
		  R.Codice,
		  R.Descrizione		
	  FROM  
		organigramma.OggettiActiveDirectory O
	  INNER JOIN		
		organigramma.RuoliOggettiActiveDirectory RUO ON O.Id = RUO.IdUtente
	  INNER JOIN 
		Organigramma.Ruoli R ON RUO.IdRuolo = R.ID
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