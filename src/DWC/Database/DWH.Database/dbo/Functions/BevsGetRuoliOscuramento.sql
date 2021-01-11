
-- =============================================
-- Author:		Stefano P.
-- Create date: 2015-06-08
-- Description:	Lista concatenata dei ruoli di bypass dell'oscuramento passato
-- Modify date: 
-- =============================================
CREATE FUNCTION dbo.[BevsGetRuoliOscuramento] 
(
	@IdOscuramento UNIQUEIDENTIFIER
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
	   	  THEN COALESCE(R.Descrizione, R.Codice) + '; '
		ELSE '  (continua); '
	   End

    FROM dbo.OscuramentoRuoli O
    INNER JOIN dbo.SAC_Ruoli R WITH(NOLOCK) ON O.IdRuolo = R.Id
  
	WHERE O.IdOscuramento = @IdOscuramento

	-- Rimuove il ; finale
	IF LEN(@RetValue) > 2
	BEGIN
		SET @RetValue = SUBSTRING(@RetValue, 0,  LEN(@RetValue))
	END

	RETURN @RetValue

END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsGetRuoliOscuramento] TO [ExecuteFrontEnd]
    AS [dbo];

