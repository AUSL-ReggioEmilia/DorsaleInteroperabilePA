


-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2012-06-28
-- =============================================
CREATE FUNCTION [dbo].[GetCodaEventiOutputIdCorrelazione]
(
	@AziendaErogante AS VARCHAR(16),
	@SistemaErogante AS VARCHAR(16),
	@NumeroNosologico AS VARCHAR(64)
)
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(64)
	DECLARE @TipoCorrelazione AS VARCHAR(50) 
	SELECT @TipoCorrelazione = ISNULL([dbo].[GetConfigurazioneString] ('CodeOutput', 'TipoCorrelazione'), 'Identificativo')
	--
	-- Calcolo la key di correlazione
	--
	IF @TipoCorrelazione = 'Identificativo'
		SET @Ret = @AziendaErogante + @NumeroNosologico
	ELSE
	IF @TipoCorrelazione = 'AziendaSistema'
		SET @Ret = @AziendaErogante + @SistemaErogante
	ELSE
		SET @Ret = @AziendaErogante + @NumeroNosologico

	RETURN @Ret
END



