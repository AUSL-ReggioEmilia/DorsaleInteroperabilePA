

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2007-07-12
-- =============================================
CREATE FUNCTION [dbo].[GetConfigurazioneString]
(
	@Sessione AS VARCHAR(128),
	@Chiave AS VARCHAR(64)
)
RETURNS VARCHAR(1024)
AS
BEGIN

DECLARE @Ret AS VARCHAR(1024)

	SELECT @Ret = ValoreString
	FROM Configurazioni
	WHERE Sessione = @Sessione AND Chiave = @Chiave

	RETURN @Ret
END


