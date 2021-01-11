
CREATE FUNCTION [dbo].[GetRuoloVisualizzazioneRefertiOscurati]
(
	@AziendaErogante varchar(16)
) RETURNS varchar(128)
AS
BEGIN
	DECLARE @Ruolo varchar(128)

	SET @Ruolo = dbo.GetConfigurazioneString(@AziendaErogante, 'RuoloVisualizzazioneOscurati')

	RETURN @Ruolo
END

