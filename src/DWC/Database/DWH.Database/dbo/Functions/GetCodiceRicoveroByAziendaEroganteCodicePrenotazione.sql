


-- =============================================
-- Author:		Ettore
-- Create date: 2013-06-21
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Modify date: 2019-01-10 - ETTORE: Parametro @AziendaErogante NON obbligatorio
-- Description:	restituisce il nosologico associato alla prenotazione
-- =============================================
CREATE FUNCTION [dbo].[GetCodiceRicoveroByAziendaEroganteCodicePrenotazione]
(
	@AziendaErogante VARCHAR(16)
	, @CodicePrenotazione VARCHAR(64)
)
RETURNS VARCHAR(64)
AS
BEGIN
	--
	-- Cerco l'evento di chiusura lista DL e leggo il suo attributo "NumeroNosologico" che contiene
	-- il nosologico associato alla prenotazione
	--
	DECLARE @CodiceRicovero VARCHAR(64) --il nosologico associato alla prenotazione
	DECLARE @IdEventoDL  UNIQUEIDENTIFIER
	--
	-- Se @AziendaErogante è vuoto lo valorizzo con NULL
	--
	IF ISNULL(@AziendaErogante, '') = ''
		SET @AziendaErogante = NULL
	--
	-- Cerco l'evento DL e leggo il suo attributo "NumeroNosologico" che contiene
	-- il nosologico associato alla prenotazione
	--
	SELECT TOP 1
		@IdEventoDL = Id
	FROM 
		store.EventiBase
	WHERE 
		(AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL)
		AND NumeroNosologico = @CodicePrenotazione
		AND TipoEventoCodice = 'DL'
		AND StatoCodice = 0
	ORDER BY DataEvento DESC

	IF NOT @IdEventoDL IS NULL
	BEGIN
		SELECT @CodiceRicovero = CONVERT(VARCHAR(64), dbo.GetEventiAttributo(@IdEventoDL, 'NumeroNosologico')) 
	END
	--
	--
	--
	RETURN @CodiceRicovero

END
