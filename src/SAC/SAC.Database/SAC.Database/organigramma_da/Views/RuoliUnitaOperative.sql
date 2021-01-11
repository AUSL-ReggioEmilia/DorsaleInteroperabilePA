

-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-12
-- Modify date: 2014-09-26 Modifiche ai campi ritornati
-- Modify date: ETTORE: 2017-03-30: Restituito campo Descrizione
-- Description:	Lista delle UO dei Ruoli
-- ================================================
CREATE VIEW [organigramma_da].[RuoliUnitaOperative]
AS
	SELECT ruo.[IdRuolo]
		,r.Codice AS RuoloCodice
		,ruo.[IdUnitaOperativa]
		,uo.Codice AS UnitaOperativaCodice
		,uo.CodiceAzienda AS UnitaOperativaAzienda
		--ETTORE: 2017-03-30: Restituito i campo Descrizione
		,uo.Descrizione
	FROM [organigramma].[RuoliUnitaOperative] ruo
		INNER JOIN [organigramma].[UnitaOperative] uo ON uo.Id = ruo.[IdUnitaOperativa]
		INNER JOIN [organigramma].[Ruoli] r ON r.Id = ruo.[IdRuolo]
	WHERE r.[Attivo] = 1
		AND uo.Attivo = 1
