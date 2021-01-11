
CREATE FUNCTION [dbo].[GetRuoloVisualizzazioneEventiReparto]
(
	@AziendaErogante varchar(16),
	@SistemaErogante varchar(16),
	@RepartoRicoveroCodice varchar(16)
) 
RETURNS varchar(128)
AS
BEGIN
	--
	-- Per ora restituisco i Viewers letti dalla configurazione
	--
	DECLARE @RuoloPre varchar(256)
	DECLARE @RuoloReparto varchar(256)

	SET @RuoloPre = dbo.GetConfigurazioneString(@AziendaErogante, 'RuoloVisualizzazioneRepartoRichiedente')
	SET @RuoloReparto = NULL

	SELECT @RuoloReparto = NULLIF(LTRIM(dbo.RepartiRichiedentiUnificati.RuoloVisualizzazione), '')
	FROM 
		dbo.RepartiRichiedentiUnificati
	WHERE 
		dbo.RepartiRichiedentiUnificati.AziendaErogante = @AziendaErogante
		AND dbo.RepartiRichiedentiUnificati.SistemaErogante = @SistemaErogante
		AND	dbo.RepartiRichiedentiUnificati.Codice = @RepartoRicoveroCodice

	RETURN @RuoloPre + ISNULL(@RuoloReparto, 'Tutti')

END

