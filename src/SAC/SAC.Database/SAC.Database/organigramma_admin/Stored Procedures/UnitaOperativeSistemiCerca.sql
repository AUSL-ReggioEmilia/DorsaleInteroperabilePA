

CREATE PROC [organigramma_admin].[UnitaOperativeSistemiCerca]
(
 @Codice varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @CodiceAzienda VARCHAR(16),
 @UnitaOperativeSistemiCodice VARCHAR(16),
 @Top INT = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  SELECT DISTINCT TOP (ISNULL(@Top, 1000)) 
      U.ID,
      U.Codice,
      U.Descrizione,
      U.CodiceAzienda,
      organigramma_admin.ConcatenaTranscodificaSistemi( U.ID ) AS SistemiConcat,
      U.DataInserimento,
      U.DataModifica,
      U.UtenteInserimento,
      U.UtenteModifica
 
  FROM  
	organigramma.UnitaOperative U
  LEFT JOIN
	organigramma.UnitaOperativeSistemi UOS
	  ON UOS.IdUnitaOperativa = U.ID

  WHERE 
	U.Attivo=1 AND
	(U.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND 
	(U.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) AND 
	(U.CodiceAzienda = @CodiceAzienda OR @CodiceAzienda IS NULL) AND
	(UOS.Codice  LIKE '%' +  @UnitaOperativeSistemiCodice + '%' OR @UnitaOperativeSistemiCodice IS NULL)  
    --PRENDO SOLO UNITA' OPERATIVE CHE HANNO ALMENO UNA TRANSCODIFICA
	AND EXISTS (SELECT ID FROM organigramma.UnitaOperativeSistemi UOS
				WHERE UOS.IdUnitaOperativa = U.ID)
				
					
END
