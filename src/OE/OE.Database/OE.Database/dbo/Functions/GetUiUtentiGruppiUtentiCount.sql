CREATE FUNCTION [dbo].[GetUiUtentiGruppiUtentiCount]
(
	@IDGruppoUtenti UNIQUEIDENTIFIER
)
RETURNS INT
AS
BEGIN
	
	DECLARE @Ret INT = 0
	
	SELECT @Ret = COUNT(ID)
	FROM [dbo].[UtentiGruppiUtenti]
	WHERE [IDGruppoUtenti] = @IDGruppoUtenti

	RETURN @Ret
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetUiUtentiGruppiUtentiCount] TO [DataAccessUi]
    AS [dbo];

