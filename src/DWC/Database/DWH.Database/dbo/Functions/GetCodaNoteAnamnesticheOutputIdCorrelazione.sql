




-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2017-11-21
-- =============================================
CREATE FUNCTION [dbo].[GetCodaNoteAnamnesticheOutputIdCorrelazione]
(
	@AziendaErogante AS VARCHAR(16),
	@SistemaErogante AS VARCHAR(16),
	@IdEsterno AS VARCHAR(64)
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
		SET @Ret = @IdEsterno 
	ELSE
	IF @TipoCorrelazione = 'AziendaSistema'
		SET @Ret = @AziendaErogante + @SistemaErogante
	ELSE
		SET @Ret = @IdEsterno 
	----SET @Ret = 'NotaAnamnestica'
	RETURN @Ret
END