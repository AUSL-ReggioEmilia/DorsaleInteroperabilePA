CREATE FUNCTION [dbo].[GetNomeServizioById](
	@Id AS tinyint
	)
RETURNS varchar(64)
AS
BEGIN
	DECLARE @Ret AS varchar(64)

	SELECT @Ret = Nome
	FROM dbo.Servizi
	WHERE (Id = @Id)

	RETURN @Ret
END

