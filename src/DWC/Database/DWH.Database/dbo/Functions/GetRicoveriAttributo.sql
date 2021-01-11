

-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveriAttributo] (@IdRicoveriBase AS uniqueidentifier, @Nome AS VARCHAR(32))  
RETURNS SQL_VARIANT AS  
BEGIN 

DECLARE @Ret AS SQL_VARIANT

	SELECT 
		@Ret = Valore 
	FROM 
		store.RicoveriAttributi WITH(NOLOCK) 
	WHERE 
		IdRicoveriBase = @IdRicoveriBase 
		AND Nome = @Nome
	RETURN @Ret

END

