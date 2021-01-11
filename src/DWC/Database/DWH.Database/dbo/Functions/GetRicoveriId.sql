
-- =============================================
-- Author:		ETTORE
-- Create date: ???
-- Modify date: 2018-06-20 - ETTORE: Uso delle viste dello schema "store" al posto delle viste dello schema "dbo"
-- Description:	
-- =============================================
CREATE FUNCTION [dbo].[GetRicoveriId] (@IdEsterno AS varchar(64))  
RETURNS uniqueidentifier AS  
BEGIN 

DECLARE @Ret AS uniqueidentifier

	SELECT @Ret = ID FROM store.RicoveriBase WHERE IdEsterno = RTRIM(@IdEsterno)
	RETURN @Ret

END

