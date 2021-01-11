


CREATE FUNCTION [dbo].[GetRuoloVisualizzazioneRefertiRepartoRichiedente](
	@AziendaErogante varchar(16),
	@SistemaErogante varchar(16),
	@RepartoRichiedenteCodice varchar(16)
) RETURNS varchar(128)
AS
BEGIN
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
		AND	dbo.RepartiRichiedentiUnificati.Codice = @RepartoRichiedenteCodice

	RETURN @RuoloPre + ISNULL(@RuoloReparto, 'Tutti')

END

