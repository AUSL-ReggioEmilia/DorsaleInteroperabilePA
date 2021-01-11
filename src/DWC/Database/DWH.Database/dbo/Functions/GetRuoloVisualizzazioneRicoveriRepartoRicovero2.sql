
/***********************************/

CREATE FUNCTION [dbo].[GetRuoloVisualizzazioneRicoveriRepartoRicovero2](
	@AziendaErogante varchar(16),
	@SistemaErogante varchar(16),
	@RepartoRicoveroCodice varchar(16)
) RETURNS varchar(128)
AS
BEGIN
/*
	Questa funzione deve sostituire l'uso della GetRuoloVisualizzazioneRicoveriRepartoRicovero
	che ha i parametri @IdPaziente, @AziendaErogante, @NumeroNosologico
*/
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
