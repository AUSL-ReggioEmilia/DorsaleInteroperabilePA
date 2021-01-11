
-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-07-16
-- Modify date: ETTORE: 2017-03-30: Restituito i campi Note e Descrizione
-- Description:	Lista dei RuoliAccessi per ruolo
-- ================================================
CREATE VIEW [organigramma_da].[RuoliAccesso]
AS
	SELECT DISTINCT
		r.[ID] AS IdRuolo,
		r.Codice AS RuoloCodice,
		ra.CodiceAccesso AS Accesso,
		--ETTORE: 2017-03-30: Restituito i campi Note e Descrizione
		ra.Note,
		ra.Descrizione
	FROM [organigramma].[Ruoli] r
		INNER JOIN [organigramma].[RuoliOggettiActiveDirectory] ro
			ON r.ID = ro.IdRuolo
		CROSS APPLY [organigramma].[OttieneAccessiPerIdRuolo](r.Id) ra
	WHERE r.[Attivo] = 1

