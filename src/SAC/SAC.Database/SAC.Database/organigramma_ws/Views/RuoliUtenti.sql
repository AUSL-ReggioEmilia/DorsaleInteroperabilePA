




-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2017-01-25
-- Description:	Lista delle relazioni Utenti/Ruoli (ricorsiva sui Guppi Utente)
-- Modify date: 2019-02-08 - ETTORE: Riscritta la vista come la [organigramma_da].[RuoliUtenti] per motivi di performance. 
--									Non sono stati aggiunti i filtri per trovare i soli ruoli attivi e utenti attivi 
--									perchè alcune SP organigramma_ws restituiscono lo stato attivo/disattivo dell'utente e del ruolo.
-- ================================================
CREATE VIEW [organigramma_ws].[RuoliUtenti]
AS
	-- RUOLI PER APPARTENENZA A GRUPPO
	SELECT
		r.[ID] AS IdRuolo,
		r.[Codice] AS RuoloCodice,
		ug.IdUtente AS IdUtente,
		ug.Utente AS Utente
	FROM [organigramma].[Ruoli] r
		INNER JOIN [organigramma].[RuoliOggettiActiveDirectory] ro
			ON r.ID = ro.IdRuolo
		INNER JOIN [organigramma_ws].[GruppiUtenti] ug
			ON ug.IdGruppo =  ro.IdUtente
	
	UNION
	
	-- RUOLI PER UTENTE	
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