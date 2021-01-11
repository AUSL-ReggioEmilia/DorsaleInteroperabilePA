

-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Modify date: 2014-09-26 Modifiche ai campi ritornati
-- Modify date: ETTORE: 2017-03-30: Restituito campo Descrizione
-- Description:	Lista dei sistemi dei Ruoli
-- ================================================
CREATE VIEW [organigramma_da].[RuoliSistemi]
AS
	SELECT rs.[IdRuolo]
		,r.Codice AS RuoloCodice
		,rs.[IdSistema]
		,s.Codice AS SistemaCodice
		,s.CodiceAzienda AS SistemaAzienda
		--ETTORE: 2017-03-30: Restituito i campo Descrizione
		,s.Descrizione
	FROM [organigramma].[RuoliSistemi] rs
		INNER JOIN [organigramma].[Sistemi] s ON s.Id = rs.[IdSistema]
		INNER JOIN [organigramma].[Ruoli] r ON r.Id = rs.[IdRuolo]
	WHERE r.[Attivo] = 1
		AND s.Attivo = 1
