
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-05-29
-- Modified:	2014-10-10 Stefano P.: inserito un limite al numero di concatenamenti
-- Description:	Lista concatenata dei sistemi per ruolo
-- =============================================
CREATE FUNCTION [organigramma_admin].[ConcatenaRuoliSistemi] 
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
	    WHEN ROW_NUMBER()OVER(ORDER BY [Sistemi].[CodiceAzienda],[Sistemi].[Codice]) <= @MaxItems 
	   	  THEN [Sistemi].[Codice] + '@' + [Sistemi].[CodiceAzienda] + '; '
		ELSE ' (continua); '
	   End
	   
    FROM [organigramma].[RuoliSistemi] WITH(NOLOCK) 
    INNER JOIN [organigramma].[Sistemi] WITH(NOLOCK)
		ON [RuoliSistemi].[IdSistema] = [Sistemi].[ID]
	
	WHERE [RuoliSistemi].[IdRuolo] = @IdRuolo

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

