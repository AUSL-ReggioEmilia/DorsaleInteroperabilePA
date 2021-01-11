
CREATE PROC [codifiche_admin].[ICD9Cerca]
(
 @TipoCodice tinyint,
 @Codice varchar(16) = NULL,
 @Descrizione varchar(256) = NULL,
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT TOP (ISNULL(@Top, 200)) 
      ICD9.Id,
      ICD9.Codice,
      ICD9.Descrizione,
      ICD9.IdTipoCodice,
      TC.Descrizione as TipoCodiceDescrizione
  FROM  codifiche.ICD9
  INNER JOIN codifiche.ICD9TipoCodice TC ON ICD9.IdTipoCodice=TC.ID  
  WHERE 
	  (ICD9.IdTipoCodice = @TipoCodice OR @TipoCodice IS NULL) AND
      (ICD9.Codice LIKE @Codice + '%' OR @Codice IS NULL) AND 
      (ICD9.Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL)

END
