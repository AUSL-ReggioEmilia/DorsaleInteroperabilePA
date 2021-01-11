

-- =============================================
-- Author:		Stefano P.
-- Create date: 2015-01-16
-- Description:	concatena le righe di tipo 'Interazioni' della Monografia
-- =============================================
CREATE FUNCTION [codifiche_ws].[FarmaGetInterazioniByCodiceMonografia] 
(
	@CodiceMonografia INT
   ,@MaxItems INT = 10  --numero massimo di righe da concatenare
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @RetValue VARCHAR(8000) = ''

	SELECT TOP (@MaxItems + 1) 
		@RetValue = @RetValue + 	    
		CASE WHEN ROW_NUMBER()OVER(ORDER BY NumeroProgressivoLinea) <= @MaxItems 
		  THEN TestoDellaLinea 
		  ELSE '...'
		END	    
	
	FROM	
		codifiche.FarmaMonografieFoglietti
	WHERE 	
		CodiceMonografia = @CodiceMonografia
		AND CodiceSezione = 'Q'
	ORDER BY 
		NumeroProgressivoLinea

	-- se stringa vuota setta NULL
	IF LEN(@RetValue) = 0 SET @RetValue = NULL
	
	RETURN @RetValue

END



