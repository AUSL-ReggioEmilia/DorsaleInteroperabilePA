

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetPrestazioniAttributo] (@IdPrestazioniBase AS uniqueidentifier, @DataPartizione as smalldatetime, @Nome AS VARCHAR(64))  
RETURNS SQL_VARIANT AS  
BEGIN 

DECLARE @Ret AS SQL_VARIANT

	SELECT @Ret = Valore
	FROM store.PrestazioniAttributi WITH(NOLOCK)
	WHERE 
		IdPrestazioniBase = @IdPrestazioniBase 
		AND DataPartizione = @DataPartizione
		AND Nome = @Nome
	
	RETURN @Ret

END


