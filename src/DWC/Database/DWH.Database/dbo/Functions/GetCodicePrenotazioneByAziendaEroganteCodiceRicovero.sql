



-- =============================================
-- Author:		Ettore
-- Create date: 2013-06-21
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2019-01-10 - ETTORE: Parametro @AziendaErogante NON obbligatorio
-- Description:	restituisce il codice di prenotazione associato ad un nosologico
-- =============================================
CREATE FUNCTION dbo.GetCodicePrenotazioneByAziendaEroganteCodiceRicovero
(
	@AziendaErogante VARCHAR(16)
	, @CodiceRicovero VARCHAR(64)
)
RETURNS VARCHAR(64)
AS
BEGIN
	--
	-- Cerco l'evento LA creato quando la prenotazione/lista attesa si traduce in ricovero
	-- e leggo il suo attributo "CodiceListaAttesa" che contiene il codice della prenotazione associata al ricovero
	--
	DECLARE @CodicePrenotazioneAssociata VARCHAR(64)
	DECLARE @IdEventoLA  UNIQUEIDENTIFIER
	--
	-- Se @AziendaErogante è vuoto lo valorizzo con NULL
	--
	IF ISNULL(@AziendaErogante, '') = ''
		SET @AziendaErogante = NULL
	--
	-- Cerco l'evento LA e leggo il suo attributo "CodiceListaAttesa" che contiene
	-- il nosologico associato all'azienda
	--
	SELECT TOP 1
		@IdEventoLA = Id
	FROM 
		store.EventiBase
	WHERE 
		(AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
		AND NumeroNosologico = @CodiceRicovero
		AND TipoEventoCodice = 'LA'
		AND StatoCodice = 0
	ORDER BY DataEvento DESC

	IF NOT @IdEventoLA IS NULL
	BEGIN
		SELECT @CodicePrenotazioneAssociata = CONVERT(VARCHAR(64), dbo.GetEventiAttributo(@IdEventoLA, 'CodiceListaAttesa')) 
	END
	--
	--
	--
	RETURN @CodicePrenotazioneAssociata

END
