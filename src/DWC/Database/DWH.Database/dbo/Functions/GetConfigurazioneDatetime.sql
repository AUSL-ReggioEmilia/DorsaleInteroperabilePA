
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2007-07-12
-- =============================================
CREATE FUNCTION [dbo].[GetConfigurazioneDatetime]
(
	@Sessione AS VARCHAR(128),
	@Chiave AS VARCHAR(64)
)
RETURNS DATETIME
AS
BEGIN

DECLARE @Ret AS DATETIME

	SELECT @Ret = ValoreDatetime
	FROM Configurazioni
	WHERE Sessione = @Sessione AND Chiave = @Chiave

	RETURN @Ret
END


