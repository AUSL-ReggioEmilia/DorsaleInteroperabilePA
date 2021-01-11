

-- =============================================
-- Author:		Stefano Piletti
-- Create date: 2014-07-25
-- Description:	Lista concatenata dei sistemi con transcodifica per una data unità operativa
-- =============================================
CREATE FUNCTION [organigramma_admin].[ConcatenaTranscodificaSistemi] 
(
	@IdUnitaOperativa UNIQUEIDENTIFIER
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @RetValue VARCHAR(8000) = ''
	
    SELECT 
		@RetValue = @RetValue + Sistemi.Codice + '@' + Sistemi.CodiceAzienda + '=' + UnitaOperativeSistemi.Codice + '; '    
    FROM 
		[organigramma].UnitaOperativeSistemi WITH(NOLOCK) 
    INNER JOIN 
		[organigramma].[Sistemi] WITH(NOLOCK)
		  ON UnitaOperativeSistemi.[IdSistema] = [Sistemi].[ID]
	WHERE UnitaOperativeSistemi.IdUnitaOperativa = @IdUnitaOperativa
	ORDER BY Sistemi.Codice, Sistemi.CodiceAzienda

	-- Rimuove il ', ' finale se vuoto setta NULL
	IF LEN(@RetValue) > 0
	BEGIN		
		SET @RetValue = SUBSTRING(@RetValue, 0,  LEN(@RetValue))		
	END
	ELSE
	BEGIN
		SET @RetValue = NULL
	END

	RETURN @RetValue

END


