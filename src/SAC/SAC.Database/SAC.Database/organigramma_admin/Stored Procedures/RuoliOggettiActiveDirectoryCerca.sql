CREATE PROC [organigramma_admin].[RuoliOggettiActiveDirectoryCerca]
(
 @IdRuolo uniqueidentifier = NULL, --se si passa NULL filtra su tutti gli OggettiActiveDirectory
 @Tipo varchar(32) = NULL,
 @Utente varchar(128) = NULL,
 @Descrizione varchar(256) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  IF @IdRuolo IS NULL BEGIN
	 /* 
	 **   cerco fra tutti gli OggettiActiveDirectory presenti su DB
	 */
	 SELECT TOP (ISNULL(@Top, 1000)) 
		  OAD.ID as ID,      --passo l'Id tanto per non lasciare null
		  OAD.ID as IDRuolo, --idem         
		  OAD.ID AS IDOggettiActiveDirectory,
		  OAD.Utente,
		  OAD.Tipo,
		  OAD.Descrizione		
	  FROM  Organigramma.OggettiActiveDirectory OAD 
	  WHERE 
		(
		  (OAD.Tipo = @Tipo OR @Tipo IS NULL) AND
		  (OAD.Utente LIKE '%' + @Utente + '%' OR @Utente IS NULL) AND
		  (OAD.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL)
		)    
  	  ORDER BY 
		  OAD.Tipo, OAD.Utente 

  END
  ELSE BEGIN
	 /* 
	 **   cerco fra i RuoliOggettiActiveDirectory associati al ruolo
	 */
	  SELECT TOP (ISNULL(@Top, 1000)) 
		  RUO.ID,
		  RUO.IdRuolo,
		  OAD.ID AS IDOggettiActiveDirectory,
		  OAD.Utente,
		  OAD.Tipo,
		  OAD.Descrizione
	  FROM  organigramma.RuoliOggettiActiveDirectory RUO
	  INNER JOIN 
		organigramma.OggettiActiveDirectory OAD ON RUO.IDUtente = OAD.ID
	  WHERE 
		RUO.IdRuolo = @IdRuolo AND
		(
		  (OAD.Tipo = @Tipo OR @Tipo IS NULL) AND
		  (OAD.Utente LIKE '%' + @Utente + '%' OR @Utente IS NULL) AND
		  (OAD.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL)
		)
	  ORDER BY 
		  OAD.Tipo, OAD.Utente 

	END

END