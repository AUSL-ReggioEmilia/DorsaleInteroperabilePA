

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetPrestazioniIdEsterno] (@Id uniqueidentifier)  
RETURNS varchar(64) AS  
BEGIN 

DECLARE @Ret varchar(64)

	SELECT @Ret = IdEsterno
	FROM store.PrestazioniBase WITH(NOLOCK)
	WHERE Id = @Id
	
	RETURN @Ret

END

