

CREATE PROCEDURE [ws2].[NosologicoByListaAttesa]
(
	@AziendaErogante AS VARCHAR(16)
	, @CodicePrenotazione VARCHAR(64)
) 
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2NosologicoByListaAttesa

		Dato il @CodicePrenotazione restituisce il @NumeroNosologico associato
*/
	SET NOCOUNT ON; 
	DECLARE @NumeroNosologico VARCHAR(64)
	SET @NumeroNosologico = dbo.GetCodiceRicoveroByAziendaEroganteCodicePrenotazione(@AziendaErogante, @CodicePrenotazione)

	SELECT 
		@NumeroNosologico AS NumeroNosologico

END

