

CREATE PROC organigramma_admin.UnitaOperativeSistemiOttieniPerIdUnitaOperativa
(
 @IdUnitaOperativa uniqueidentifier
)
AS
BEGIN
  SET NOCOUNT OFF

  SELECT 
      UOS.ID,     
      UOS.IdUnitaOperativa,
      S.Id as IdSistema,
      S.Codice AS Sistema_Codice,     
      S.Descrizione AS Sistema_Descrizione,
      S.CodiceAzienda AS Sistema_CodiceAzienda,           
      UOS.Codice,
      UOS.CodiceAzienda,
      UOS.Descrizione,
      UOS.DataInserimento,
      UOS.DataModifica,
      UOS.UtenteInserimento,
      UOS.UtenteModifica      
  
  FROM 
	organigramma.Sistemi S  

  INNER JOIN --SEMPLICE CONTROLLO PER ESCLUDERE UNITA' OPERATIVE INESISTENTI
	organigramma.UnitaOperative U
		ON U.Id = @IdUnitaOperativa
  
  LEFT JOIN
	organigramma.UnitaOperativeSistemi UOS
		ON UOS.IdSistema = S.Id
		AND UOS.IdUnitaOperativa = U.Id
  	
  ORDER BY --MOSTRO PER PRIMI I RECORD CHE HANNO UNA TRANSCODIFICA, POI GLI ALTRI
	CASE ISNULL(UOS.Codice, '1')
		WHEN '1' THEN 1
		ELSE 0
	END,
	S.Codice
	
	
	
END
