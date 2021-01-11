

CREATE FUNCTION [dbo].[GetRuoloVisualizzazioneRicoveriSistemaErogante2]
(
	@AziendaErogante varchar(16),
	@SistemaErogante varchar(16)
) RETURNS varchar(128)
AS
BEGIN
/*
	Questa funzione deve sostituire l'uso della GetRuoloVisualizzazioneRicoveriSistemaErogante
	che ha i parametri @IdPaziente, @AziendaErogante, @NumeroNosologico
*/
	DECLARE @RuoloPre varchar(256)
	SET @RuoloPre = dbo.GetConfigurazioneString(@AziendaErogante, 'RuoloVisualizzazioneSistemaErogante')
	
	RETURN @RuoloPre + @SistemaErogante

END
