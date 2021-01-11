

CREATE PROCEDURE [ws3].[ListaAttesaByNosologico]
(
	@AziendaErogante AS VARCHAR(16)
	, @NumeroNosologico VARCHAR(64)
) 
AS
BEGIN
/*
	CREATA DA ETTORE 2016-03-17:
		Dato il NumeroNosologico restituisce il @CodicePrenotazione associato
*/
	SET NOCOUNT ON; 
	DECLARE @CodicePrenotazione VARCHAR(64)
	SET @CodicePrenotazione = dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero(@AziendaErogante, @NumeroNosologico )
	SELECT @CodicePrenotazione AS CodicePrenotazione
END