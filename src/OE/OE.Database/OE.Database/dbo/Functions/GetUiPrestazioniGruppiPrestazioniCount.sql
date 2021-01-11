CREATE FUNCTION [dbo].[GetUiPrestazioniGruppiPrestazioniCount]
(
	@IDGruppoPrestazioni UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
	
	DECLARE @Ret INT = 0
	
	SELECT @Ret = COUNT(ID)
	FROM [dbo].PrestazioniGruppiPrestazioni
	WHERE IDGruppoPrestazioni = @IDGruppoPrestazioni

	RETURN @Ret
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetUiPrestazioniGruppiPrestazioniCount] TO [DataAccessUi]
    AS [dbo];

