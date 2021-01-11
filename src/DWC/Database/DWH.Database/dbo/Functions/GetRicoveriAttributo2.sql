


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveriAttributo2] 
(
	@IdRicoveriBase AS uniqueidentifier
	, @DataPartizione as smalldatetime
	, @Nome AS VARCHAR(32)
)  
RETURNS SQL_VARIANT AS  
BEGIN 
/*
	CREATA DA ETTORE 2015-05-04: per utilizzare la data di partizione 
*/
DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore 
	FROM store.RicoveriAttributi WITH(NOLOCK) 
	WHERE IdRicoveriBase = @IdRicoveriBase
		AND DataPartizione = @DataPartizione 
		AND Nome = @Nome

	RETURN @Ret
END
