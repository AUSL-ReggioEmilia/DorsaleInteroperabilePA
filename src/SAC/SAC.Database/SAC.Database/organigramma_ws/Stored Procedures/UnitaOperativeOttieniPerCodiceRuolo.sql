
-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-04
-- Description:	Ritorna la lista delle Unità Operative per il ruolo
-- =============================================
CREATE PROC [organigramma_ws].[UnitaOperativeOttieniPerCodiceRuolo]
(
 @Codice varchar(16)
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		uo.[ID],
		uo.[Codice],
		uo.[CodiceAzienda],
		uo.[Descrizione],
		uo.[Attivo]
	FROM  [organigramma].[UnitaOperative] uo
	INNER JOIN organigramma.RuoliUnitaOperative ruo
		ON uo.ID = ruo.IdUnitaOperativa
	INNER JOIN organigramma.Ruoli r
		ON r.ID = ruo.IdRuolo
	WHERE r.[Codice] = @Codice
		AND uo.[Attivo] = 1
END