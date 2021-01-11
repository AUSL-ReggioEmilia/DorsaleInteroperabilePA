-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-04
-- Description:	Ritorna la lista dei sistemi per il ruolo
-- =============================================
CREATE PROC [organigramma_ws].[SistemiOttieniPerCodiceRuolo]
(
 @Codice varchar(16)
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		s.[ID],
		s.[Codice],
		s.[CodiceAzienda],
		s.[Descrizione],
		s.[Erogante],
		s.[Richiedente],
		s.[Attivo]
	FROM  [organigramma].[Sistemi] s
	INNER JOIN organigramma.RuoliSistemi rs
		ON s.ID = rs.IdSistema
	INNER JOIN organigramma.Ruoli r
		ON r.ID = rs.IdRuolo
	WHERE r.[Codice] = @Codice
		AND s.[Attivo] = 1
END