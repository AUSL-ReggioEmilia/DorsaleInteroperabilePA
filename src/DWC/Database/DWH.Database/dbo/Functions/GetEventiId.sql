

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	Restituisce l'Id dell'evento dato il suo IdEsterno
-- =============================================
CREATE FUNCTION [dbo].[GetEventiId] (@IdEsterno AS varchar(64))  
RETURNS uniqueidentifier AS  
BEGIN 

DECLARE @Ret AS uniqueidentifier
	
	SELECT @Ret = Id
	FROM store.EventiBase WITH(NOLOCK) 
	WHERE IdEsterno = RTRIM(@IdEsterno)
	
	RETURN @Ret

END

