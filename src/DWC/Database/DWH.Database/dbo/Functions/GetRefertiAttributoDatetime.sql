

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiAttributoDatetime]
 (@IdRefertiBase AS uniqueidentifier, @Nome AS VARCHAR(64))  
RETURNS DATETIME AS  
BEGIN 

DECLARE @Ret AS DATETIME
DECLARE @Valore AS SQL_VARIANT

	SELECT @Valore = Valore
	FROM store.RefertiAttributi WITH(NOLOCK)
	WHERE IdRefertiBase = @IdRefertiBase AND Nome = @Nome
	
	IF ISDATE(CONVERT(VARCHAR(40), @Valore)) = 1
		SET @Ret = CAST( @Valore AS DATETIME)
	ELSE
		SET @Ret = NULL
		
	RETURN @Ret
END
