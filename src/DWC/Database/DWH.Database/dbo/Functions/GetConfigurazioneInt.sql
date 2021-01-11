
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2007-07-12
-- =============================================
CREATE FUNCTION [dbo].[GetConfigurazioneInt]
(
	@Sessione AS VARCHAR(128),
	@Chiave AS VARCHAR(64)
)
RETURNS INT
AS
BEGIN

DECLARE @Ret AS INT

	SELECT @Ret = ValoreInt
	FROM Configurazioni
	WHERE Sessione = @Sessione AND Chiave = @Chiave

	RETURN @Ret
END


