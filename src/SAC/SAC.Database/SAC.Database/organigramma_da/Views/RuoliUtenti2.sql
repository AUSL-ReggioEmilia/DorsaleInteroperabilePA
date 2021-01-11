

-- ================================================
-- Author:		Alessandro Nostini
--
-- Copiata da ver 1.
-- Create date: 2020-01-31 Modifiche ai campi ritornati, [TipoAbilitazione], [IdGruppoAbilitante], [GruppoAbilitante]
--							Le righe non sono più distinte per Utente/Ruolo
--
-- Description:	Lista degli utenti (recursivo sui gruppi) dei Ruoli
-- ================================================
CREATE VIEW [organigramma_da].[RuoliUtenti2]
AS
	-- Ruoli per appartenenza a gruppo
	SELECT
		r.[ID] AS IdRuolo,
		r.[Codice] AS RuoloCodice,
		ug.IdUtente AS IdUtente,
		ug.Utente AS Utente,

		-- 2020-01-31
		CONVERT(VARCHAR(32), 'Gruppo') AS [TipoAbilitazione],
		ug.[IdGruppo] AS [IdGruppoAbilitante],
		ug.[Gruppo] AS [GruppoAbilitante]

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
		o.Utente,

		-- 2020-01-31
		CONVERT(VARCHAR(32), 'Utente') AS [TipoAbilitazione],
		CONVERT(UNIQUEIDENTIFIER, NULL) AS [IdGruppoAbilitante],
		CONVERT(VARCHAR(128), NULL) AS [GruppoAbilitante]

	FROM [organigramma].[Ruoli] r
		INNER JOIN [organigramma].[RuoliOggettiActiveDirectory] ro
			ON r.ID = ro.IdRuolo
		INNER JOIN [organigramma].[OggettiActiveDirectory] o
			ON o.ID = ro.IdUtente
				AND o.Tipo = 'Utente'
	WHERE r.[Attivo] = 1
		AND o.Attivo = 1