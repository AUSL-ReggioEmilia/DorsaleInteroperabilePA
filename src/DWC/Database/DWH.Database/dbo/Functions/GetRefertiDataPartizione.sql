


-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiDataPartizione]( @Id AS uniqueidentifier)  
RETURNS smalldatetime AS  
BEGIN 

DECLARE @Ret AS smalldatetime

	SELECT @Ret=DataPartizione
	FROM store.RefertiBase
	WITH(NOLOCK) WHERE Id = @Id
		
	RETURN @Ret
END



