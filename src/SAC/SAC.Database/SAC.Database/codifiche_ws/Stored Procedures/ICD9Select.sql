
CREATE PROC [codifiche_ws].[ICD9Select]
(
 @Id uniqueidentifier, --RICERCA PER ID
 @TipoCodice tinyint,  --OPPURE PER TIPOCODICE + CODICE
 @Codice varchar(16)
)
AS
BEGIN
  SET NOCOUNT OFF

	IF @Id IS NOT NULL BEGIN
	
		SELECT 
		  ICD9.Id,
		  ICD9.Codice,
		  ICD9.Descrizione,
		  ICD9.IdTipoCodice,
		  TC.Descrizione as TipoCodiceDescrizione
		FROM  codifiche.ICD9
		INNER JOIN codifiche.ICD9TipoCodice TC ON ICD9.IdTipoCodice=TC.ID  
		WHERE 
		  ICD9.Id = @ID
	
	END
	ELSE IF @Codice IS NOT NULL AND @TipoCodice IS NOT NULL BEGIN
	
		SELECT TOP 1
		  ICD9.Id,
		  ICD9.Codice,
		  ICD9.Descrizione,
		  ICD9.IdTipoCodice,
		  TC.Descrizione as TipoCodiceDescrizione
		FROM  codifiche.ICD9
		INNER JOIN codifiche.ICD9TipoCodice TC ON ICD9.IdTipoCodice=TC.ID  
		WHERE 
		  ICD9.IdTipoCodice = @TipoCodice AND
		  ICD9.Codice = @Codice
		  
	END	
  
END
