


-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiAttributo] (@IdRefertiBase AS uniqueidentifier, @Nome AS VARCHAR(64))  
RETURNS SQL_VARIANT AS  
BEGIN 

DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore
	FROM store.RefertiAttributi WITH(NOLOCK)
	WHERE IdRefertiBase = @IdRefertiBase AND Nome = @Nome
	
	RETURN @Ret

END

