-- =============================================
-- Author:		Ettore
-- Create date: 2016-07-18
-- Description:	Rimpiazza caratteri indesiderati in @String con @StringReplace 
-- =============================================
CREATE FUNCTION [dbo].[ReplaceInvalidChar]
(
	@String AS VARCHAR(MAX)
	, @StringReplace VARCHAR(10) = NULL
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	IF @StringReplace IS NULL SET @StringReplace = ''
	SET @String = REPLACE(@String , CHAR(10), @StringReplace)
	SET @String = REPLACE(@String , CHAR(13), @StringReplace)
	--
	--
	-- 
	RETURN @String 

END