
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-10-09
-- Description:	Codifico caratteri speciali per un filtro
-- =============================================
CREATE FUNCTION [dbo].[EncodingLdapFilter]
(
 @String NVARCHAR(4000)
)
RETURNS NVARCHAR(4000)
AS
BEGIN
	DECLARE @Ret NVARCHAR(4000)

	SET @Ret = REPLACE(@String, '\', '\5c')
	SET @Ret = REPLACE(@Ret, '(', '\28')
	SET @Ret = REPLACE(@Ret, ')', '\29')
	SET @Ret = REPLACE(@Ret, '&', '\26')
	SET @Ret = REPLACE(@Ret, '|', '\7c')
	SET @Ret = REPLACE(@Ret, '=', '\3d')
	SET @Ret = REPLACE(@Ret, '>', '\3e')
	SET @Ret = REPLACE(@Ret, '<', '\3c')
	SET @Ret = REPLACE(@Ret, '~', '\7e')
	SET @Ret = REPLACE(@Ret, '*', '\2a')
	SET @Ret = REPLACE(@Ret, '/', '\2f')
	SET @Ret = REPLACE(@Ret, ' ', '\20')

	RETURN @Ret
END
