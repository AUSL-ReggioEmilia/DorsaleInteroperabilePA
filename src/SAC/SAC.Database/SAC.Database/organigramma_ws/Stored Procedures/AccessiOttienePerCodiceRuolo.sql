
-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2016-11-08
-- Description:	Ritorna la lista degli Accessi (attributi calcolati) per il Ruolo
-- =============================================
CREATE PROC [organigramma_ws].[AccessiOttienePerCodiceRuolo]
(
 @CodiceRuolo varchar(128)
)
AS
BEGIN
	SET NOCOUNT ON
		
	SELECT [Accesso]
	FROM  [organigramma_ws].[RuoliAccesso]
	WHERE RuoloCodice = @CodiceRuolo
	
END