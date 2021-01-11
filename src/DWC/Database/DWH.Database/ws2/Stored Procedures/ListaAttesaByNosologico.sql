
CREATE PROCEDURE [ws2].[ListaAttesaByNosologico]
(
	@AziendaErogante AS VARCHAR(16)
	, @NumeroNosologico VARCHAR(64)
) 
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.Ws2ListaAttesaByNosologico

		Dato il NumeroNosologico restituisce il @CodicePrenotazione associato
*/
	SET NOCOUNT ON; 
	DECLARE @CodicePrenotazione VARCHAR(64)
	SET @CodicePrenotazione = dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero(@AziendaErogante, @NumeroNosologico )

	SELECT 
		@CodicePrenotazione AS CodicePrenotazione

END

