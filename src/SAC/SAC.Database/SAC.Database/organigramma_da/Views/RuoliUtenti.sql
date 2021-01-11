

-- ================================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Modify date: 2014-09-26 Modifiche ai campi ritornati
-- Description:	Lista degli utenti (recursivo sui gruppi) dei Ruoli
-- ================================================
CREATE VIEW [organigramma_da].[RuoliUtenti]
AS
	-- Ruoli per appartenenza a gruppo
	SELECT
		r.[ID] AS IdRuolo,
		r.[Codice] AS RuoloCodice,
		ug.IdUtente AS IdUtente,
		ug.Utente AS Utente
	FROM [organigramma].[Ruoli] r
		INNER JOIN [organigramma].[RuoliOggettiActiveDirectory] ro
			ON r.ID = ro.IdRuolo
		INNER JOIN [organigramma_da].[GruppiUtenti] ug
			ON ug.IdGruppo =  ro.IdUtente
	WHERE r.[Attivo] = 1

	UNION
	-- Ruoli per utente
	SELECT 
		r.[ID] AS IdRuolo,
		r.[Codice]  AS RuoloCodice,
		o.Id AS IdUtente,
		o.Utente
	FROM [organigramma].[Ruoli] r
		INNER JOIN [organigramma].[RuoliOggettiActiveDirectory] ro
			ON r.ID = ro.IdRuolo
		INNER JOIN [organigramma].[OggettiActiveDirectory] o
			ON o.ID = ro.IdUtente
				AND o.Tipo = 'Utente'
	WHERE r.[Attivo] = 1
		AND o.Attivo = 1
