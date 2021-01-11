-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-12-07
-- Description:	Restituisce il Ruolo con il codice passato
-- =============================================
CREATE PROCEDURE [organigramma_ws].[RuoliOttieniPerCodiceRuolo]
(
 @CodiceRuolo varchar(16)
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
		[organigramma].[Ruoli] R
	WHERE 
		R.Codice = @CodiceRuolo

END