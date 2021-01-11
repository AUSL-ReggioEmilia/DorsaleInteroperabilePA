CREATE FUNCTION [dbo].[GetRuoloVisualizzazioneRefertiConfidenziali]
(
	@AziendaErogante varchar(16)
) RETURNS varchar(128)
AS
BEGIN
	DECLARE @Ruolo varchar(128)

	SET @Ruolo = dbo.GetConfigurazioneString(@AziendaErogante, 'RuoloVisualizzazioneConfidenziali')

	RETURN @Ruolo
END
