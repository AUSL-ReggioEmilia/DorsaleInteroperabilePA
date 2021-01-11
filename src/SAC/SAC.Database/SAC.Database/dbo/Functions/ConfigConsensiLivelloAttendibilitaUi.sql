CREATE FUNCTION [dbo].[ConfigConsensiLivelloAttendibilitaUi]()
RETURNS TINYINT
AS
BEGIN
	DECLARE @Ret AS TINYINT
	SELECT @Ret=CONVERT(TINYINT, ValoreInt) FROM ConsensiConfig WHERE Nome='LivelloAttendibilitaUi'
	
	RETURN ISNULL(@Ret, 0)
END

