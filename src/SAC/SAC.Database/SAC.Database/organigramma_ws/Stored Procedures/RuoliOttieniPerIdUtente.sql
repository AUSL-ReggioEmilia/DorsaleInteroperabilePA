
-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-04
-- Description:	Ritorna la lista dei ruoli per IDUtente
-- =============================================
CREATE PROC [organigramma_ws].[RuoliOttieniPerIdUtente]
(
 @IdUtente uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT 
		R.Id,
		R.Codice,
		R.Descrizione,
		R.Attivo
	FROM 
		[organigramma_ws].[RuoliUtenti] AS RU
	INNER JOIN
		organigramma.Ruoli as R ON RU.IdRuolo = R.Id
	WHERE 
		RU.IdUtente = @IdUtente
		AND R.Attivo = 1
		AND EXISTS (SELECT 1 FROM organigramma_ws.Utenti
					WHERE Id = @IdUtente
					AND Attivo = 1)

	ORDER BY 
		RuoloCodice
END