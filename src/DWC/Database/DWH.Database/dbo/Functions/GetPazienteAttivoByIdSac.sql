
-- =============================================
-- Author:		Garulli Ettore
-- Create date: 2012-09-06
-- Modifify date: 2016-05-10: aggiunto TOP 1
-- Modifify date: 2016-05-12: sandro -  Usa nuova vista [sac].[PazientiFusioni]
--
-- Description:	Restituisce il paziente attivo 
--				associato ad un IdPaziente qualsiasi
-- =============================================
CREATE FUNCTION [dbo].[GetPazienteAttivoByIdSac]
(
	@IdPaziente UNIQUEIDENTIFIER
)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER
	
	SELECT TOP 1 @IdPazienteAttivo = IdPazienti
	FROM [sac].[PazientiFusioni]
			WHERE IdPazienteFuso = @IdPaziente
			
	IF @IdPazienteAttivo IS NULL
		SET @IdPazienteAttivo = @IdPaziente

	RETURN @IdPazienteAttivo
END
