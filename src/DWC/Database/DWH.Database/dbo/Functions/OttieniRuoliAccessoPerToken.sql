-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-03-29
-- Description:	Ritorna lista degli ACCESSI letti dal TOKEN
-- =============================================
CREATE FUNCTION [dbo].[OttieniRuoliAccessoPerToken]
(
  @IdToken UNIQUEIDENTIFIER
)
RETURNS 
    @Result TABLE (
        [Accesso] VARCHAR(64) NOT NULL)
AS
BEGIN

	DECLARE @xmlCache xml = NULL
	DECLARE @CodiceRuolo VARCHAR(16) = NULL

	SELECT @xmlCache = [CacheRuoliAccesso], @CodiceRuolo = CodiceRuolo
		FROM [dbo].[Tokens]
		WHERE ID = @IdToken

	IF @xmlCache IS NULL	BEGIN
		--Legge dal SAC
		INSERT INTO @Result
		SELECT [Accesso]
			FROM [dbo].[OttieniSacRuoliAccessoPerRuolo](@CodiceRuolo)

	END	ELSE BEGIN
		-- Usa i dati letti dalla cache

		INSERT INTO @Result
		SELECT
			Tab.Col.value('@Accesso','varchar(64)') AS [Accesso]
		FROM @xmlCache.nodes('/RuoliAccesso/RuoloAccesso') Tab(Col)
	END

	RETURN 
END