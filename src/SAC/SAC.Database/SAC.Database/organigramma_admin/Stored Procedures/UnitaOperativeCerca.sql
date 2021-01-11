
-- =============================================
-- Author:		/
-- Create date: /
-- Description:	cerca tra le unità operative
-- ModifyDate: 2018-02-01 SimoneB: Aggiunto il filtro @CodiceRegime
-- =============================================
CREATE PROC [organigramma_admin].[UnitaOperativeCerca]
(
 @Codice varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @CodiceAzienda VARCHAR(16),
 @Top INT = NULL,
 @CodiceRegime VARCHAR(16) = NULL
)
WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT OFF

  --NB: Eseguo il distinct degli Id perchè ad una unità operativa possono essere associati più regimi di ricovero.
  -- in questo modo restituisco solo una Unità operativa
  SELECT DISTINCT TOP 1000 UO.[ID] ,
      UO.[Codice],
      UO.[Descrizione],
      UO.[CodiceAzienda],
      UO.[Attivo],
      UO.[DataInserimento],
      UO.[DataModifica],
      UO.[UtenteInserimento],
      UO.[UtenteModifica],
	  --Ottengo la lista dei regimi:
	  --FOR XML PATH-> Trasforma la selenct in un xml composto da tag <row>
	  --PATH('') -> Sostituisce i tag <row> in stringhe vuote ''
	  STUFF((SELECT DISTINCT '; ' + R2.Descrizione + ' (' + R2.Codice + ')'
			FROM [organigramma].[UnitaOperativeRegimi] UOR2
				LEFT JOIN [organigramma].Regimi R2 ON UOR2.CodiceRegime = R2.Codice
			WHERE UOR2.IdUnitaOperativa = UO.ID
			FOR XML PATH('')), 1, 2, '') AS Regimi

	FROM  [organigramma].[UnitaOperative] UO
		LEFT JOIN [organigramma].[UnitaOperativeRegimi] UOR ON UO.ID = UOR.IdUnitaOperativa
	WHERE 
      (UO.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND 
      (UO.Descrizione LIKE'%' +  @Descrizione + '%' OR @Descrizione IS NULL) AND 
      (CodiceAzienda = @CodiceAzienda OR @CodiceAzienda IS NULL)
	  AND (@CodiceRegime IS NULL OR UOR.CodiceRegime = @CodiceRegime)

END
