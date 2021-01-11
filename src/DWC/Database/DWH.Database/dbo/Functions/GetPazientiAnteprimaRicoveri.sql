

CREATE FUNCTION [dbo].[GetPazientiAnteprimaRicoveri]
(
	@IdPaziente uniqueidentifier
)
RETURNS VARCHAR(2048)
AS
BEGIN
/*
	CREATE DA ETTORE: 2015-02-06
		Funzione utilizzata dal task schedulato di popolazione ricoveri
	MODIFICA A ETTORE: 2015-06-17
		Utilizzo della vista frontend.Ricoveri al posto della dbo.Ricoveri
*/

	DECLARE @Anteprima VARCHAR(2048)
	SET @Anteprima = ''
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)
	--
	--
	--
	DECLARE @DataAccettazione DATETIME
	DECLARE @DataDimissione DATETIME
	DECLARE @AziendaErogante  AS VARCHAR(16)
	DECLARE @NumeroNosologico AS VARCHAR(64)
	DECLARE @RepartoDescr AS VARCHAR(128)
	--
	-- Memorizzo i dati dell'ultimo ricovero (quello con data accettazione maggiore)
	--
	SELECT TOP 1 
		@AziendaErogante  = AziendaErogante , @NumeroNosologico = NumeroNosologico
		, @DataAccettazione = DataAccettazione , @DataDimissione = DataDimissione
		, @RepartoDescr = RepartoDescr --reparto prima della dimissione
	FROM frontend.Ricoveri AS Ricoveri --WITH(NOLOCK) 
			INNER JOIN @TablePazienti Pazienti 
				ON Ricoveri.IdPaziente = Pazienti.Id
	ORDER BY Ricoveri.DataAccettazione DESC
	--
	-- Se ho trovato il nosologico dell'accettazione
	--	
	IF NOT (@NumeroNosologico IS NULL)
	BEGIN
		SET @Anteprima = @Anteprima + 'Ultimo accesso: ' + ISNULL(CONVERT(VARCHAR(10), @DataAccettazione, 103), '...') 
		IF NOT @DataDimissione IS NULL
			SET @Anteprima = @Anteprima + ' - ' + CONVERT(VARCHAR(10), @DataDimissione, 103)

		IF NOT @RepartoDescr IS NULL
			SET @Anteprima = @Anteprima + ' <br/>' + @RepartoDescr
		--
		-- Aggiungo l'Azienda Erogante
		--
		IF NOT @AziendaErogante IS NULL
			SET @Anteprima = @Anteprima + ' (' + @AziendaErogante + ')'
	END
	ELSE
	BEGIN
		SET @Anteprima = @Anteprima + 'Nessun accesso.' 
	END
	--
	-- Restituisco
	--
	RETURN ISNULL(@Anteprima, '')

END

