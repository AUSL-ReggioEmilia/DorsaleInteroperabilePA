


-- =============================================
-- Author:		Simone Bitti
-- Create date: 2017-10-26
-- Description:	Ottiene la lista dei ruoli in base all'attributo.
-- =============================================
CREATE PROC [organigramma_ws].[RuoliOttieniPerAttributo]
(
	@CodiceAttributo varchar(64)
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON

	SELECT R.[Id]
		  ,R.[Codice]
		  ,R.[Descrizione]
		  ,R.[Attivo]
	FROM [organigramma].[Ruoli] R
		INNER JOIN [organigramma].[RuoliAttributi] RA ON R.ID = RA.IdRuolo 
	WHERE RA.CodiceAttributo = @CodiceAttributo

END