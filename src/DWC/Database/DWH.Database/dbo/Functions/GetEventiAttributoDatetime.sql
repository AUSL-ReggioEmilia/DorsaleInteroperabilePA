
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	Restituisce il valore di un attributo di tipo DATETIME 
-- =============================================
CREATE FUNCTION [dbo].[GetEventiAttributoDatetime]
 (@IdEventiBase AS uniqueidentifier, @Nome AS VARCHAR(64))  
RETURNS DATETIME AS  
BEGIN 

DECLARE @Ret AS DATETIME
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM store.EventiAttributi WITH(NOLOCK)
	WHERE IdEventiBase = @IdEventiBase AND Nome = @Nome
	
	IF ISDATE(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS DATETIME)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END
