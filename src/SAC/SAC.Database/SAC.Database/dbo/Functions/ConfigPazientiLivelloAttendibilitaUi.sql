CREATE FUNCTION [dbo].[ConfigPazientiLivelloAttendibilitaUi]()
RETURNS TINYINT
AS
BEGIN
	DECLARE @Ret AS TINYINT
	SELECT @Ret=CONVERT(TINYINT, ValoreInt) FROM PazientiConfig WHERE Nome='LivelloAttendibilitaUi'
	
	RETURN ISNULL(@Ret, 0)
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConfigPazientiLivelloAttendibilitaUi] TO [DataAccessUi]
    AS [dbo];

