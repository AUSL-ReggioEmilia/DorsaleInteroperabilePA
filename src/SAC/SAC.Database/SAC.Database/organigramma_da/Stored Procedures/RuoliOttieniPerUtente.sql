


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna la lista dei ruoli per utente
-- =============================================
CREATE PROC [organigramma_da].[RuoliOttieniPerUtente]
(
 @Utente varchar(128)
)
AS
BEGIN
	SET NOCOUNT OFF
  	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[RuoliOttieniPerUtente]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[RuoliOttieniPerUtente]!', 16, 1)
		RETURN
	END
	-- Ruoli per appartenenza a gruppo
	SELECT 
		r.[ID],
		r.[Codice],
		r.[Descrizione]
	FROM [organigramma].[Ruoli] r
		INNER JOIN [organigramma].[RuoliOggettiActiveDirectory] ro
			ON r.ID = ro.IdRuolo
		INNER JOIN [organigramma].[OttieneGruppiPerUtente](@Utente) g
			ON g.IdFiglio =  ro.IdUtente
	WHERE r.[Attivo] = 1

	UNION
	-- Ruoli per utente
	SELECT 
		r.[ID],
		r.[Codice],
		r.[Descrizione]
	FROM [organigramma].[Ruoli] r
		INNER JOIN [organigramma].[RuoliOggettiActiveDirectory] ro
			ON r.ID = ro.IdRuolo
		INNER JOIN [organigramma].[OggettiActiveDirectory] o
			ON o.ID = ro.IdUtente
				AND o.Tipo = 'Utente'
				AND o.[Utente] = @Utente
	WHERE r.[Attivo] = 1

	ORDER BY Codice
	
END


