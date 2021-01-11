-- =============================================
-- Author:		ETTORE
-- Create date: 2016-05-16
-- Description:	Restituisce l'anteprima ricoveri e IdUltimoRicovero come campi separati
-- =============================================
CREATE FUNCTION [dbo].[GetPazientiAnteprimaRicoveri2]
(
	@IdPaziente uniqueidentifier
)
RETURNS @RetTable TABLE 
	(IdUltimoRicovero UNIQUEIDENTIFIER
	, AnteprimaRicoveri VARCHAR(2048))	
AS
BEGIN
/*
	Funzione utilizzata dal task schedulato di popolazione ricoveri
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
	DECLARE @IdUltimoRicovero UNIQUEIDENTIFIER
	DECLARE @DataAccettazione DATETIME
	DECLARE @DataDimissione DATETIME
	DECLARE @AziendaErogante  AS VARCHAR(16)
	DECLARE @NumeroNosologico AS VARCHAR(64)
	DECLARE @RepartoDescr AS VARCHAR(128)
	--
	-- Memorizzo i dati dell'ultimo ricovero (quello con data accettazione maggiore)
	--
	SELECT TOP 1 
		@IdUltimoRicovero = R.Id
		, @AziendaErogante  = R.AziendaErogante , @NumeroNosologico = R.NumeroNosologico
		, @DataAccettazione = R.DataAccettazione , @DataDimissione = R.DataDimissione
		, @RepartoDescr = R.RepartoDescr --reparto prima della dimissione
	FROM frontend.Ricoveri AS R --WITH(NOLOCK) 
			INNER JOIN @TablePazienti Pazienti 
				ON R.IdPaziente = Pazienti.Id
	ORDER BY R.DataAccettazione DESC
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
	INSERT INTO @RetTable(IdUltimoRicovero, AnteprimaRicoveri)
	VALUES (@IdUltimoRicovero, ISNULL(@Anteprima, ''))
	--
	-- Restituisco
	--	
	RETURN 
END