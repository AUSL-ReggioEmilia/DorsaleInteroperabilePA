
CREATE FUNCTION [dbo].[GetPazienteRootByPazienteId]
(
	@IdPaziente UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER
	SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
	IF @IdPazienteAttivo IS NULL SET @IdPazienteAttivo = @IdPaziente 
	--
	-- A questo punto @IdPazienteAttivo contiene o l'@IdPaziente passato oppure il padre della fusione
	--
	RETURN @IdPazienteAttivo
END


