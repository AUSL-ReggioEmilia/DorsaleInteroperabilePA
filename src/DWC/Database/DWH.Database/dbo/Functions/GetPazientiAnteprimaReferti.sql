
CREATE FUNCTION [dbo].[GetPazientiAnteprimaReferti]
(
	@IdPaziente uniqueidentifier
)
RETURNS VARCHAR(2048)
AS
BEGIN
/*
	CREATE DA ETTORE: 2015-02-06
		Funzione utilizzata dal task schedulato di popolazione anteprima
	MODIFICA A ETTORE: 2015-06-17
		Utilizzo della vista frontend.Referti al posto della dbo.referti
	MODIFICA ETTORE: 2017-06-29
		Si usa la descrizione del sistema erogante al posto del codice: ora la descrizione del sistema varia con Azienda-CodiceSistema
	MODIFICA ETTORE: 2017-11-27
		Si usa la descrizione definita nella tabella TipiReferto
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
	DECLARE @DataUltimoReferto DATETIME
	DECLARE @DescrizioneUltimoReferto VARCHAR(128) --la descrizione del sistema erogante
	DECLARE @NumReferti INT
	DECLARE @TmpReferti AS TABLE (NumeroReferti INT, AziendaErogante VARCHAR(16), SistemaErogante VARCHAR(16), DataReferto  DATETIME)
	DECLARE @AziendaEroganteUltimoReferto AS VARCHAR(16)
	DECLARE @SistemaEroganteUltimoReferto AS VARCHAR(16)
	DECLARE @SpecialitaEroganteUltimoReferto AS VARCHAR(64)
	--
	-- Cerco i dati dei referti che mi servono da visualizzare nell'anteprima
	-- MODIFICA ETTORE: 2017-06-29: memorizzo anche l'azienda erogante
	--
	INSERT INTO @TmpReferti	(NumeroReferti, AziendaErogante, SistemaErogante, DataReferto)
	SELECT COUNT(*), AziendaErogante, SistemaErogante, DataReferto 
	FROM frontend.Referti AS Referti --WITH(NOLOCK) 
		INNER JOIN @TablePazienti Pazienti 
			ON Referti.IdPaziente = Pazienti.Id
	GROUP BY AziendaErogante, SistemaErogante, DataReferto
	--
	-- Calcolo il numero di referti
	--
	SELECT @NumReferti = SUM(NumeroReferti) FROM @TmpReferti
	--
	-- Determino @DataUltimoReferto e @AziendaEroganteUltimoReferto , @SistemaEroganteUltimoReferto 
	--
	IF @NumReferti > 0 
	BEGIN
		SELECT TOP 1
			@AziendaEroganteUltimoReferto = TAB.AziendaErogante,
			@SistemaEroganteUltimoReferto = TAB.SistemaErogante,
			@DataUltimoReferto = MAX(TAB.DataReferto) 
		FROM 
			@TmpReferti	AS TAB
		GROUP BY TAB.AziendaErogante, TAB.SistemaErogante
		ORDER BY MAX(TAB.DataReferto) DESC 

		--MODIFICA ETTORE: 2017-11-27: Trovo la specialità erogante dell'ultimo referto
		SELECT TOP 1
			@SpecialitaEroganteUltimoReferto = R.SpecialitaErogante
		FROM 
			--Cerco nella store.referti
			store.Referti AS R
			INNER JOIN @TablePazienti AS Pazienti
				ON R.IdPaziente = Pazienti.Id
		WHERE R.AziendaErogante = @AziendaEroganteUltimoReferto
			AND R.SistemaErogante = @SistemaEroganteUltimoReferto
			AND  R.DataReferto = @DataUltimoReferto

		-- MODIFICA ETTORE: 2017-11-27: Ricavo la descrizione dell'ultimo referto per AziendaErogante, SistemaErogante e SpecialitaErogante dalla tabella TipiReferto
		SELECT @DescrizioneUltimoReferto = Descrizione FROM dbo.LookUpTipoReferto2(@AziendaEroganteUltimoReferto, @SistemaEroganteUltimoReferto, @SpecialitaEroganteUltimoReferto)

		-- Se non trova la descrizione del sistema usa il codice del sistema: non dovrebbe mai accadere
		SET @DescrizioneUltimoReferto = ISNULL(@DescrizioneUltimoReferto, @SistemaEroganteUltimoReferto)
	END
	
	IF @NumReferti IS NULL SET @NumReferti = 0
	SET @Anteprima = 'Numero referti: ' + CAST(@NumReferti AS VARCHAR(10))
	IF NOT @DescrizioneUltimoReferto IS NULL 
		SET @Anteprima = @Anteprima + '<br/>Ultimo referto: ' + @DescrizioneUltimoReferto + ' (' + CONVERT(VARCHAR(10), @DataUltimoReferto, 103) + ')'

	--
	-- Restituisco
	--
	RETURN ISNULL(@Anteprima, '')

END

