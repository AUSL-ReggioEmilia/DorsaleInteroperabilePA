


-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetPrestazioniAttributoInteger]
 (@IdPrestazioniBase AS uniqueidentifier,  @DataPartizione as smalldatetime, @Nome AS VARCHAR(64))  
RETURNS INTEGER AS  
BEGIN 

DECLARE @Ret AS INTEGER 
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM store.PrestazioniAttributi WITH(NOLOCK)
	WHERE 
		IdPrestazioniBase = @IdPrestazioniBase 
		AND DataPartizione = @DataPartizione
		AND Nome = @Nome

	IF ISNUMERIC(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS INTEGER)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END
