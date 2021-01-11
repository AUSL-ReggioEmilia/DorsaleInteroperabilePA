

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-05-29
-- Modified:	2014-10-10 Stefano P.: inserito un limite al numero di concatenamenti
-- Description:	Lista concatenata delle Unità Operative per ruolo
-- =============================================
CREATE FUNCTION [organigramma_admin].[ConcatenaRuoliUnitaOperative] 
(
	@IdRuolo UNIQUEIDENTIFIER
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @RetValue VARCHAR(8000) = ''
	DECLARE @MaxItems INT = 10

    SELECT TOP (@MaxItems + 1)  
  
	  @RetValue = @RetValue + 
	  CASE 
	    WHEN ROW_NUMBER()OVER(ORDER BY [UnitaOperative].[CodiceAzienda],[UnitaOperative].[Codice]) <= @MaxItems 
	   	  THEN [UnitaOperative].[Codice] + '@' + [UnitaOperative].[CodiceAzienda] + '; '
		ELSE '  (continua); '
	   End

    FROM [organigramma].[RuoliUnitaOperative] WITH(NOLOCK) INNER JOIN [organigramma].[UnitaOperative] WITH(NOLOCK)
			ON [RuoliUnitaOperative].[IdUnitaOperativa] = [UnitaOperative].[ID]
	WHERE [RuoliUnitaOperative].[IdRuolo] = @IdRuolo

	-- Rimuove il ; finale o se stringa vuota setta NULL
	IF LEN(@RetValue) > 2
	BEGIN
		SET @RetValue = SUBSTRING(@RetValue, 0,  LEN(@RetValue))
	END
	ELSE
	BEGIN
		SET @RetValue = NULL
	END

	RETURN @RetValue

END


