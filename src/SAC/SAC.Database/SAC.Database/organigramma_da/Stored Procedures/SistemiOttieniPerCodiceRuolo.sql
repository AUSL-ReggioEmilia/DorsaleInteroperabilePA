


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna la lista dei sistemi per ruolo
-- =============================================
CREATE PROC [organigramma_da].[SistemiOttieniPerCodiceRuolo]
(
 @Codice varchar(16)
)
AS
BEGIN
	SET NOCOUNT OFF
  	---------------------------------------------------
	-- Controllo accesso (utente corrente)
	---------------------------------------------------
	IF [organigramma].[LeggePermessiLettura](NULL) = 0
	BEGIN
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[SistemiOttieniPerCodiceRuolo]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[SistemiOttieniPerCodiceRuolo]!', 16, 1)
		RETURN
	END

	SELECT 
		s.[ID],
		s.[Codice],
		s.[CodiceAzienda],
		s.[Descrizione],
		s.[Erogante],
		s.[Richiedente]
	FROM  [organigramma].[Sistemi] s
		INNER JOIN organigramma.RuoliSistemi rs
			ON s.ID = rs.IdSistema
		INNER JOIN organigramma.Ruoli r
			ON r.ID = rs.IdRuolo
	WHERE r.[Codice] = @Codice
		AND s.[Attivo] = 1
END


