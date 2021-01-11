

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	Restituisce il valore SQL_VARIANT di un attributo
-- =============================================
CREATE FUNCTION [dbo].[GetEventiAttributo] (@IdEventiBase AS uniqueidentifier, @Nome AS VARCHAR(64))  
RETURNS SQL_VARIANT AS  
BEGIN 

DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore 
	FROM store.EventiAttributi WITH(NOLOCK) 
	WHERE 
		IdEventiBase = @IdEventiBase 
		AND Nome = @Nome
		
	RETURN @Ret
END


