


-- =============================================
-- Author:		Ettore
-- Create date: 2012-10-31
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	Costruisce la lista di ruoli di visualizzazione associati ad un evento
-- =============================================
CREATE FUNCTION [dbo].[GetRuoliVisualizzazioneEventi]
(
	@IdEvento uniqueidentifier
)
RETURNS VARCHAR(4096)
AS
BEGIN
	DECLARE @RuoliVisualizzazione VARCHAR(4096)
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @RepartoCodice VARCHAR(16)	
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @Ruolo AS VARCHAR(128)
	
	SET @RuoliVisualizzazione = ''
	--
	-- Ricavo alcuni dati del referto da utilizzare per chiamare altre funzioni
	--
	SELECT 
		@AziendaErogante = AziendaErogante
		, @SistemaErogante = SistemaErogante
		, @RepartoCodice = RepartoCodice
		, @IdPaziente = IdPaziente
	FROM 
		store.EventiBase
	WHERE 
		Id = @IdEvento
	
	--
	-- Se l'evento manca restituisco ''
	--
	IF @AziendaErogante IS NULL
		RETURN '' --nessuno ha diritti di visualizzazione
		
	------------------------------------------------------------------------------------------------------------
	-- Aggiungo i due ruoli per SISTEMA EROGANTE e REPARTO RICHIEDENTE
	------------------------------------------------------------------------------------------------------------
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneEventiSistemaErogante(@AziendaErogante, @SistemaErogante), '')
	IF @Ruolo <> '' 
		SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneEventiReparto(@AziendaErogante, @SistemaErogante, @RepartoCodice), '')
	IF @Ruolo <> '' 
		SET @RuoliVisualizzazione = @RuoliVisualizzazione + @Ruolo + ';'
	------------------------------------------------------------------------------------------------------------
	-- OSCURATI: 1) perchè il paziente è cancellato
	------------------------------------------------------------------------------------------------------------
	SET @Ruolo = ISNULL(dbo.GetRuoloVisualizzazioneEventiOscurati(@AziendaErogante) , '')
	IF @Ruolo <> ''
	BEGIN 
		-- Verifico che non ci sia cancellazione totale per paziente
		IF EXISTS (SELECT * FROM PazientiCancellati  
						WHERE PazientiCancellati.IdPazientiBase = @IdPaziente
							AND PazientiCancellati.IdRepartiEroganti IS NULL)
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

