

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiDataReferto]( @Id AS uniqueidentifier)  
RETURNS datetime AS  
BEGIN 

DECLARE @Ret AS datetime

	SELECT @Ret=DataReferto
	FROM store.RefertiBase
	WITH(NOLOCK) WHERE Id = @Id
		
	RETURN @Ret
END


