



-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-07-16
-- Description:	Lista delle Unita operative
-- ================================================
CREATE VIEW [organigramma_da].[UnitaOperative]
AS
	SELECT 
		 UO.ID AS ID	
		,UO.Codice AS Codice
		,UO.CodiceAzienda AS Azienda
		,UO.Descrizione AS Descrizione
		,UO.Attivo AS Attivo
	FROM [organigramma].[UnitaOperative] UO

