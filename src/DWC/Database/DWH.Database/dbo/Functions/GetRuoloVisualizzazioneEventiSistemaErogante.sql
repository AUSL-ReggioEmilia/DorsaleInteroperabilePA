
CREATE FUNCTION [dbo].[GetRuoloVisualizzazioneEventiSistemaErogante](
	@AziendaErogante varchar(16),
	@SistemaErogante varchar(16)
) RETURNS varchar(128)
AS
BEGIN
	
	DECLARE @RuoloPre varchar(256)
	SET @RuoloPre = dbo.GetConfigurazioneString(@AziendaErogante, 'RuoloVisualizzazioneSistemaErogante')
	RETURN @RuoloPre + @SistemaErogante

END


