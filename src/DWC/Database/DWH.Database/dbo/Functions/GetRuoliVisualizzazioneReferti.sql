


-- =============================================
-- Author:		Ettore
-- Create date: 2012-10-22
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	Costruisce la lista di ruoli di visualizzazione associati ad un referto
-- Modify date: 2019-01-31 ETTORE - Eliminazione uso della tabella "dbo.RepartiEroganti"
-- =============================================
CREATE FUNCTION [dbo].[GetRuoliVisualizzazioneReferti]
(
	@IdReferto uniqueidentifier
)
RETURNS VARCHAR(4096)
AS
BEGIN
	DECLARE @RuoliVisualizzazione VARCHAR(4096)
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @RepartoRichiedenteCodice VARCHAR(16)	
	DECLARE @DataPartizione SMALLDATETIME
	DECLARE @Cancellato BIT
	DECLARE @StatoRichiestaCodice TINYINT
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @RepartoErogante VARCHAR(64)
	DECLARE @Ruolo AS VARCHAR(128)
	
	DECLARE @Oscurato AS BIT
	SET @Oscurato = 0
	
	SET @RuoliVisualizzazione = ''
	--
	-- Ricavo alcuni dati del referto da utilizzare per chiamare altre funzioni
	--
	SELECT 
		@AziendaErogante = AziendaErogante
		, @SistemaErogante = SistemaErogante
		, @RepartoRichiedenteCodice = RepartoRichiedenteCodice
		, @DataPartizione = DataPartizione 
		, @Cancellato = Cancellato
		, @StatoRichiestaCodice = StatoRichiestaCodice
		, @IdPaziente = IdPaziente
		, @RepartoErogante = RepartoErogante
	FROM 
		store.RefertiBase
	WHERE 
		Id = @IdReferto
	
	--
	-- Se il referto manca restituisco ''
	--
	IF @AziendaErogante IS NULL
		RETURN '' --nessuno ha diritti di visualizzazione
		
	------------------------------------------------------------------------------------------------------------
	-- Aggiungo i due ruoli per SISTEMA EROGANTE e REPARTO RICHIEDENTE
	------------------------------------------------------------------------------------------------------------
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneRefertiSistemaErogante(@AziendaErogante, @SistemaErogante), '')
	IF @Ruolo <> '' 
		SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneRefertiRepartoRichiedente(@AziendaErogante, @SistemaErogante, @RepartoRichiedenteCodice), '')
	IF @Ruolo <> '' 
		SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
	------------------------------------------------------------------------------------------------------------
	-- OSCURATI: 
	--				1) Cancellati da interfaccia web 
	--				2) per RepartoErogante 
	--				3) perchè il paziente è cancellato
	------------------------------------------------------------------------------------------------------------
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneRefertiOscurati(@AziendaErogante) , '')
	IF @Ruolo <> ''
	BEGIN 
		-- 1) Verifico che il referto non sia cancellato da interfaccia web	
		IF (@Oscurato = 0) AND (@Cancellato = 1)
		BEGIN
			SET @Oscurato = 1
		END
		IF (@Oscurato = 0)
		BEGIN 
			-- 2) Verifico che non ci sia cancellazione totale per tutti i referti del paziente				
			IF EXISTS (SELECT * FROM PazientiCancellati  
							WHERE PazientiCancellati.IdPazientiBase = @IdPaziente
								AND PazientiCancellati.IdRepartiEroganti IS NULL)
			BEGIN
				SET @Oscurato = 1
			END
		END		
		IF @Oscurato = 1
		BEGIN
			SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
		END
	END

	------------------------------------------------------------------------------------------------------------
	-- CONFIDENZIALI
	------------------------------------------------------------------------------------------------------------
	IF dbo.GetRefertiIsConfidenziale(@IdReferto, @DataPartizione) = 1
	BEGIN
		SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneRefertiConfidenziali(@AziendaErogante) , '')
		IF @Ruolo <> ''
			SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
	END
	------------------------------------------------------------------------------------------------------------
	-- ANNULLATI (da chi eroga il referto)
	------------------------------------------------------------------------------------------------------------
	IF @StatoRichiestaCodice = 3
	BEGIN
		SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneRefertiAnnullati(@AziendaErogante) , '')
		IF @Ruolo <> ''
			SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
	END

	------------------------------------------------------------------------------------------------------------
	-- FONDAMENTALE: Elimino sempre ultimo carattere ';'
	------------------------------------------------------------------------------------------------------------
	IF RIGHT(@RuoliVisualizzazione, 1) = ';'
		SET @RuoliVisualizzazione = LEFT(@RuoliVisualizzazione, LEN(@RuoliVisualizzazione) - 1)
	--
	-- Restituisco la lista di ruoli
	--
	RETURN @RuoliVisualizzazione

END
