
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-08-30
-- Modifify date: 2016-05-12: sandro -  Usa nuova vista [sac].[PazientiFusioni]
--
-- Description:	Lista dei pazienti fusi
-- =============================================
CREATE FUNCTION [dbo].[GetPazientiDaCercareByIdSac] 
(	
	@IdPaziente AS UNIQUEIDENTIFIER
)
RETURNS TABLE 
AS
RETURN 
(
	--
	-- Lista dei sinonimi
	--
	SELECT *
	FROM (
		SELECT IdPazienteFuso AS Id
			FROM [sac].[PazientiFusioni]
			WHERE IdPazienti = @IdPaziente
		UNION
		SELECT @IdPaziente AS Id
		) Pazienti
)

