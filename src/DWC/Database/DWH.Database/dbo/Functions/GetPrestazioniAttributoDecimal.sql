-- =============================================
-- Author:		SANDRO
-- Create date: ???
-- Modify date: 2015-09-16 SANDRO - Aggiunto controllo @Valore = '.'
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Modify date: 2019-05-08 SANDRO - Controllo Overlflow su DECIMAL(12,3)
--
-- Description:	Ritorna l'attributo tipizzato DECIMAL
-- =============================================
CREATE FUNCTION [dbo].[GetPrestazioniAttributoDecimal]
 (@IdPrestazioniBase AS uniqueidentifier,  @DataPartizione as smalldatetime, @Nome AS VARCHAR(64))  
RETURNS DECIMAL(12,3) AS  
BEGIN 
DECLARE @Ret AS DECIMAL(12,3) 
DECLARE @Valore AS VARCHAR(40)

	SELECT @Valore = CONVERT(VARCHAR(40), Valore)
	FROM store.PrestazioniAttributi WITH(NOLOCK)
	WHERE 
		IdPrestazioniBase = @IdPrestazioniBase 
		AND DataPartizione = @DataPartizione
		AND Nome = @Nome

	-- Controllo simboli non permessi
	IF @Valore = '-' OR @Valore = '+' OR @Valore = '€' OR @Valore = '$' OR @Valore = '.'
		SET @Valore = NULL

	-- Separatore decimali '.' se foramto ita
	SET @Valore = REPLACE(@Valore, ',', '.')
	
	-- 2019-05-06 Controllo overflow
	IF CHARINDEX('.', @Valore) > 10 OR (CHARINDEX('.', @Valore) = 0 AND LEN(@Valore) > 9)
		SET @Valore = NULL

	-- Se numero converto
	IF ISNUMERIC(@Valore) = 1
		SET @Ret = CAST(@Valore AS DECIMAL(12,3))
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END
