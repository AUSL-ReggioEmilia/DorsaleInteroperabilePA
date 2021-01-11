
-- =============================================
-- Author:		Ettore
-- Create date: 2013-06-21
-- MODIFICA ETTORE 2012-09-17: per cercare fra gli alias del paziente
-- MODIFICA ETTORE 2016-09-08: eliminato filtro per SistemaErogante = 'ADT' per gestione nuovo sistema erogante EIM-ADTSTR
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetPazientiRicoveroTipoEpisodio]
(
	@IdPaziente uniqueidentifier
)
RETURNS VARCHAR(16)
AS
BEGIN
	DECLARE @DataAccettazione DATETIME
	DECLARE @DataDimissione DATETIME
	DECLARE @NumeroNosologico AS VARCHAR(64)
	DECLARE @AziendaErogante AS VARCHAR(16)
	DECLARE @TipoEpisodio AS VARCHAR(16)
	DECLARE @RetVar AS VARCHAR(16)

	SET @RetVar = ''
	--
	-- Lista dei fusi + l'attivo
	--
	DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
	INSERT INTO @TablePazienti(Id)
		SELECT Id
		FROM dbo.GetPazientiDaCercareByIdSac(@IdPaziente)	
	--
	-- Trovo l'evento di accettazione con data maggiore
	--
	SELECT TOP 1 
			@DataAccettazione = DataEvento 
			,@AziendaErogante =AziendaErogante
			,@NumeroNosologico = NumeroNosologico
			,@TipoEpisodio = TipoEpisodio -- il tipo di episodio è scritto nell'accettazione
	FROM store.Eventi WITH(NOLOCK)
		--
		-- Filtro per paziente
		--
		INNER JOIN @TablePazienti Pazienti
			ON Eventi.IdPaziente = Pazienti.Id		
	WHERE 
		--SistemaErogante = 'ADT' AND 
		(TipoEventoCodice= 'A')
	ORDER BY DataEvento DESC

	IF (@TipoEpisodio = 'P') AND --pronto soccorso
	   (CONVERT(varchar(10),@DataAccettazione,120) <> CONVERT(varchar(10),GETDATE(),120)) --se la data non è oggi
	BEGIN
		SET @TipoEpisodio = NULL --non devo visualizzare nulla
	END

	IF NOT (@TipoEpisodio IS NULL) --ho trovato l'accettazione
	BEGIN
		--
		-- Cerco la data di dimissione del nosologico
		-- Se c'è l'evento di dimissione c'è anche la data di dimissione
		--
		SELECT TOP 1 
			@DataDimissione = DataEvento
		FROM store.Eventi WITH(NOLOCK)
		WHERE 
			--SistemaErogante = 'ADT' AND 
			(TipoEventoCodice= 'D')
			AND AziendaErogante = @AziendaErogante
			AND NumeroNosologico = @NumeroNosologico
		ORDER BY DataEvento DESC
		--
		-- Restituisco solo se l'episodio è in corso, cioè se non è avvenuta la dimissione
		--
		If ISNULL(@DataDimissione,GETDATE()) >= GETDATE()  --allora il paziente è ancora ricoverato
		BEGIN
			SET @RetVar	= @TipoEpisodio
		END
	END
	-----------------------------------------------------------------------------------------------
	-- Restituisco
	-----------------------------------------------------------------------------------------------
	RETURN @RetVar

END
