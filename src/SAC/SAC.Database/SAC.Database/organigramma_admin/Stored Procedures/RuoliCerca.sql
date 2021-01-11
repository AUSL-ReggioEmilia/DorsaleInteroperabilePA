
-- =============================================
-- Author:		Stefano P.
-- Create date: 2014-10-10
-- Description:	Ricerca nei Ruoli e ritorna una lista
-- Modify date: 2015-07-14 Stefano: eliminato campo NumeroAttributi
-- Modify date: 2018-01-19 SimoneB: Aggiunto parametro @Note
-- =============================================
CREATE PROC [organigramma_admin].[RuoliCerca]
(
 @Codice varchar(16) = NULL,
 @Descrizione varchar(128) = NULL,
 @Attivo bit = NULL,
 @CodiceUnitaOperativa varchar(16) = NULL,
 @CodiceSistema varchar(16) = NULL, 
 @Top INT = NULL,
 @Note VARCHAR(1024) = NULL

)
WITH RECOMPILE
AS
BEGIN
 SET NOCOUNT OFF

 SELECT TOP (ISNULL(@Top, 1000)) 
      RU.ID,
      RU.Codice,
      RU.Descrizione,
      RU.Attivo,
      organigramma_admin.ConcatenaRuoliSistemi(RU.ID) SistemiConcat,
      organigramma_admin.ConcatenaRuoliUnitaOperative(RU.ID) UnitaOperativeConcat,
      organigramma_admin.ConcatenaRuoliAttributi(RU.ID) AttributiConcat,
      RU.DataInserimento,
      RU.DataModifica,
      RU.UtenteInserimento,
      RU.UtenteModifica,
	  RU.Note
  FROM  organigramma.Ruoli RU
  WHERE RU.ID IN 
  (	
	  SELECT DISTINCT RU.ID
	  FROM  organigramma.Ruoli RU
	  LEFT JOIN
			organigramma.RuoliUnitaOperative RUO ON RU.ID = RUO.IDRUOLO
	  LEFT JOIN 
			organigramma.UnitaOperative UO ON RUO.IdUnitaOperativa = UO.ID	
		
	  LEFT JOIN
			organigramma.RuoliSistemi RSI ON RU.ID = RSI.IDRUOLO
	  LEFT JOIN 
			organigramma.Sistemi SI ON RSI.IdSistema = SI.ID
				
	  WHERE 
		  (RU.Codice LIKE '%' + @Codice + '%' OR @Codice IS NULL) AND 
		  (RU.Descrizione LIKE '%' + @Descrizione + '%' OR @Descrizione IS NULL) AND 
		  (RU.Attivo = @Attivo OR @Attivo IS NULL)  AND
	      (RU.Note LIKE '%' + @Note + '%' OR @Note IS NULL) AND
		  (UO.Codice LIKE '%' + @CodiceUnitaOperativa + '%' OR @CodiceUnitaOperativa IS NULL) AND 
		  (SI.Codice LIKE '%' + @CodiceSistema + '%' OR @CodiceSistema IS NULL) 
  )

END
