CREATE FUNCTION [dbo].[ConfigPazientiProvenienzaUi]()
RETURNS VARCHAR(64)
AS
BEGIN
	DECLARE @Ret AS VARCHAR(64)
	SELECT @Ret=ValoreString FROM PazientiConfig WHERE Nome='ProvenienzaUi'
	
	RETURN ISNULL(@Ret, 'VUOTO')
END
