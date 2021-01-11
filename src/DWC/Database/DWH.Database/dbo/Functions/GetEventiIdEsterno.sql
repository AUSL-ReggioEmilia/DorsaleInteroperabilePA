
-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetEventiIdEsterno] (@Id uniqueidentifier)  
RETURNS varchar(64) AS  
BEGIN 

DECLARE @Ret varchar(64)

	SELECT @Ret = IdEsterno
	FROM store.EventiBase WITH(NOLOCK)
	WHERE Id = @Id
	
	RETURN @Ret

END


