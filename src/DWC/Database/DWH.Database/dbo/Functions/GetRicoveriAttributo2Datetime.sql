


-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste delllo schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveriAttributo2Datetime]
(
	@IdRicoveriBase AS uniqueidentifier
	, @DataPartizione as smalldatetime
	, @Nome AS VARCHAR(64)
)  
RETURNS DATETIME AS  
BEGIN 
/*
	CREATA DA ETTORE 2015-05-04: per utilizzare la data di partizione 
*/
DECLARE @Ret AS DATETIME
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM store.RicoveriAttributi WITH(NOLOCK)
	WHERE IdRicoveriBase = @IdRicoveriBase
		AND DataPartizione = @DataPartizione 
		AND Nome = @Nome
	
	IF ISDATE(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS DATETIME)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END

