


-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-16
-- Description:	Ritorna la lista dei sistemi per ruolo
-- =============================================
CREATE PROC [organigramma_da].[UnitaOperativeOttieniPerCodiceRuolo]
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
		EXEC [organigramma].[EventiAccessoNegato] NULL, 0, '[organigramma_da].[UnitaOperativeOttieniPerCodiceRuolo]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [organigramma_da].[UnitaOperativeOttieniPerCodiceRuolo]!', 16, 1)
		RETURN
	END

	SELECT 
		uo.[ID],
		uo.[Codice],
		uo.[CodiceAzienda],
		uo.[Descrizione]
	FROM  [organigramma].[UnitaOperative] uo
		INNER JOIN organigramma.RuoliUnitaOperative ruo
			ON uo.ID = ruo.IdUnitaOperativa
		INNER JOIN organigramma.Ruoli r
			ON r.ID = ruo.IdRuolo
	WHERE r.[Codice] = @Codice
		AND uo.[Attivo] = 1
END


