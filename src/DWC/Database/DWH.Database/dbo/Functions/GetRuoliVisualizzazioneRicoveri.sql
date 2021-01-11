



-- =============================================
-- Author:		Ettore
-- Create date: 2012-10-31
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	Costruisce la lista di ruoli di visualizzazione associati ad un evento
-- =============================================
CREATE FUNCTION [dbo].[GetRuoliVisualizzazioneRicoveri]
(
	@IdRicovero uniqueidentifier
)
RETURNS VARCHAR(4096)
AS
BEGIN
	DECLARE @RuoliVisualizzazione VARCHAR(4096)
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @RepartoAccettazioneCodice VARCHAR(16)	
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @Cancellato BIT
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
		, @RepartoAccettazioneCodice = RepartoAccettazioneCodice --si deve usare il reparto di accettazione
		, @IdPaziente = IdPaziente
		, @Cancellato = Cancellato
	FROM 
		store.RicoveriBase
	WHERE 
		Id = @IdRicovero
	
	--
	-- Se l'evento manca restituisco ''
	--
	IF @AziendaErogante IS NULL
		RETURN '' --nessuno ha diritti di visualizzazione
		
	------------------------------------------------------------------------------------------------------------
	-- Aggiungo i due ruoli per SISTEMA EROGANTE e REPARTO RICHIEDENTE
	------------------------------------------------------------------------------------------------------------
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneRicoveriSistemaErogante2(@AziendaErogante, @SistemaErogante), '')
	IF @Ruolo <> '' 
		SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneRicoveriRepartoRicovero2(@AziendaErogante, @SistemaErogante, @RepartoAccettazioneCodice), '')
	IF @Ruolo <> '' 
		SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
	------------------------------------------------------------------------------------------------------------
	-- OSCURATI: 
	--			1) Perchè il ricovero è cancellato (RicoveriBase.Cancellato=1: attualmente non è implementato nulla che ponga a 1 tale campo)
	--			2) Perchè il paziente è cancellato
	------------------------------------------------------------------------------------------------------------
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneRicoveriOscurati(@AziendaErogante) , '')
	IF @Ruolo <> ''
	BEGIN 
		IF (@Oscurato = 0) AND (@Cancellato = 1)
		BEGIN
			SET @Oscurato = 1
		END 
		IF (@Oscurato = 0) 
		BEGIN 
			-- Verifico che non ci sia cancellazione totale per paziente
			IF EXISTS (SELECT * FROM PazientiCancellati  
							WHERE PazientiCancellati.IdPazientiBase = @IdPaziente
								AND PazientiCancellati.IdRepartiEroganti IS NULL)
			BEGIN
				SET @Oscurato = 1
			END
		END
		IF (@Oscurato = 1) 
		BEGIN 
			SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
		END
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


