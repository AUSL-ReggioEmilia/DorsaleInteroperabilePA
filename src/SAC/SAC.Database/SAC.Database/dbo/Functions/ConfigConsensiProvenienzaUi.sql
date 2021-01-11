CREATE FUNCTION [dbo].[ConfigConsensiProvenienzaUi]()
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(64)
	SELECT @Ret=ValoreString FROM ConsensiConfig WHERE Nome='ProvenienzaUi'
	
	RETURN ISNULL(@Ret, 'VUOTO')
END
