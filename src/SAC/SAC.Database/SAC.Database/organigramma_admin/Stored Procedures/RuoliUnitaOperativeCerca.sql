-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Restituisce in base ai parametri o la lista di tutte le UnitaOperative o la lista delle UnitaOperative associate ad un ruolo
-- Modify Date: 2017-03-23 ETTORE: restituito flag Attivo e nuovo parametro @Attivo con DEFAULT NULL
-- Modify Date:	2018-02-16 SIMONE B: Inserito parametro CodiceRegime
-- =============================================
CREATE PROC [organigramma_admin].[RuoliUnitaOperativeCerca]
(
 @IdRuolo uniqueidentifier = NULL, --se si passa NULL filtra su tutte le unità operative
 @Codice varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @CodiceAzienda varchar(16) = NULL,
 @Top INT = NULL,
 @Attivo BIT = NULL --nuovo parametro
 ,@CodiceRegime VARCHAR(16) = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

    IF @IdRuolo IS NULL BEGIN
	 /* 
	 **   cerco fra tutte le unità operative presenti su DB
	 */
	 SELECT DISTINCT TOP (ISNULL(@Top, 1000)) 
		  UO.ID as ID,      --passo l'Id dell'Unità Operativa tanto per non lasciare null
		  UO.ID as IDRuolo, --idem         
		  UO.ID AS IdUnitaOperativa, 
		  UO.Codice,
		  UO.Descrizione,
		  UO.CodiceAzienda,
		  UO.CodiceAzienda + ' - ' +  UO.Codice + ' - ' +  ISNULL(UO.Descrizione,'') as NomeConcatenato,
		  UO.Attivo  --nuovo campo

		  --Ottengo la lista dei regimi:
		  --FOR XML PATH-> Trasforma la selenct in un xml composto da tag <row>
		  --PATH('') -> Sostituisce i tag <row> in stringhe vuote ''
		 ,STUFF((SELECT DISTINCT '; ' + R2.Descrizione + ' (' + R2.Codice + ')'
			FROM [organigramma].[UnitaOperativeRegimi] UOR2
				INNER JOIN [organigramma].Regimi R2 ON UOR2.CodiceRegime = R2.Codice
			WHERE UOR2.IdUnitaOperativa = UO.ID
			FOR XML PATH('')), 1, 2, '') AS Regimi

	  FROM  Organigramma.UnitaOperative UO 
		LEFT JOIN [organigramma].[UnitaOperativeRegimi] UOR ON UO.ID = UOR.IdUnitaOperativa
	  WHERE 
		(
		  (UO.CodiceAzienda = @CodiceAzienda OR @CodiceAzienda IS NULL) AND 
		  (UO.Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
		  (UO.Codice LIKE @Codice + '%' OR @Codice IS NULL) AND
		  (UO.Attivo = @Attivo OR @Attivo IS NULL)  --nuovo filtro
		  AND (@CodiceRegime IS NULL OR UOR.CodiceRegime = @CodiceRegime)
		)    
  	  ORDER BY 
		  UO.CodiceAzienda, UO.Codice 

  END
  ELSE BEGIN
	 /* 
	 **   cerco fra le unità operative associate al ruolo
	 */
	  SELECT DISTINCT TOP (ISNULL(@Top, 1000)) 
		  RUO.ID,
		  RUO.IdRuolo,
		  RUO.IdUnitaOperativa,
		  UO.Codice,
		  UO.Descrizione,
		  UO.CodiceAzienda,
		  UO.CodiceAzienda + ' - ' +  UO.Codice + ' - ' +  ISNULL(UO.Descrizione,'') as NomeConcatenato,
		  UO.Attivo  --nuovo campo

		  --Ottengo la lista dei regimi:
		  -- FOR XML PATH-> Trasforma la selenct in un xml composto da tag <row>
		  -- PATH('') -> Sostituisce i tag <row> in stringhe vuote ''
		  ,STUFF((SELECT DISTINCT '; ' + R2.Descrizione + ' (' + R2.Codice + ')'
			FROM [organigramma].[UnitaOperativeRegimi] UOR2
				INNER JOIN [organigramma].Regimi R2 ON UOR2.CodiceRegime = R2.Codice
			WHERE UOR2.IdUnitaOperativa = UO.ID
			FOR XML PATH('')), 1, 2, '') AS Regimi

	  FROM  organigramma.RuoliUnitaOperative RUO
	  INNER JOIN 
		organigramma.UnitaOperative UO ON RUO.IdUnitaOperativa=UO.ID
	  LEFT JOIN 
		[organigramma].[UnitaOperativeRegimi] UOR ON UO.ID = UOR.IdUnitaOperativa
	  WHERE 
		RUO.IdRuolo = @IdRuolo AND
		(
		  (UO.CodiceAzienda = @CodiceAzienda OR @CodiceAzienda IS NULL) AND 
		  (UO.Descrizione LIKE @Descrizione + '%' OR @Descrizione IS NULL) AND 
		  (UO.Codice LIKE @Codice + '%' OR @Codice IS NULL) AND 
		  (UO.Attivo = @Attivo OR @Attivo IS NULL)  --nuovo filtro
		  AND (@CodiceRegime IS NULL OR UOR.CodiceRegime = @CodiceRegime)
		)
	  ORDER BY 
		  UO.CodiceAzienda, UO.Codice 

	END

END