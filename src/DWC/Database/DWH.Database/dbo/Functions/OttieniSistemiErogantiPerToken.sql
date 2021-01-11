-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-03-29
-- Description:	Ritorna lista dei SE letti dal TOKEN
-- =============================================
CREATE FUNCTION [dbo].[OttieniSistemiErogantiPerToken]
(
  @IdToken UNIQUEIDENTIFIER
)
RETURNS 
    @Result TABLE (
        [SistemaErogante] VARCHAR(64) NOT NULL,
        [AziendaErogante] VARCHAR(16) NOT NULL)
AS
BEGIN

	DECLARE @xmlCache xml = NULL
	DECLARE @CodiceRuolo VARCHAR(16) = NULL

	SELECT @xmlCache = [CacheSistemiEroganti], @CodiceRuolo = CodiceRuolo
		FROM [dbo].[Tokens]
		WHERE ID = @IdToken


	IF @xmlCache IS NULL	BEGIN
		--Legge dal SAC
		INSERT INTO @Result
		SELECT [SistemaErogante], [AziendaErogante]
			FROM [dbo].[OttieniSacSistemiErogantiPerRuolo](@CodiceRuolo)

	END	ELSE BEGIN
		-- Usa i dati letti dalla cache

		INSERT INTO @Result
		SELECT
			Tab.Col.value('@SistemaErogante','varchar(64)') AS [SistemaErogante],
			Tab.Col.value('@AziendaErogante','varchar(16)') AS [AziendaErogante]
		FROM @xmlCache.nodes('/SistemiEroganti/SistemaErogante') Tab(Col)
	END

	RETURN 
END