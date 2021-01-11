
-- =============================================
-- Author:		Stefano P.
-- Create date: 2014-10-10
-- Description:	Lista concatenata degli Attributi di ruolo
-- Modify date: 2015-04-29 Stefano: corretto bug concatenazione descrizione null
-- =============================================
CREATE FUNCTION [organigramma_admin].[ConcatenaRuoliAttributi] 
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
	    WHEN ROW_NUMBER()OVER(ORDER BY Descrizione) <= @MaxItems 
	   	  THEN COALESCE(Descrizione, CodiceAttributo) + '; '
		ELSE '  (continua); '
	   End

    FROM organigramma_admin.UnionAttributi WITH(NOLOCK) 
  
	WHERE IdRuolo = @IdRuolo

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


