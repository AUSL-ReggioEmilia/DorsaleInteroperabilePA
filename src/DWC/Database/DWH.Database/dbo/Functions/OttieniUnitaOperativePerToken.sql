-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-03-29
-- Description:	Ritorna lista dei UO letti dal TOKEN
-- =============================================
CREATE FUNCTION [dbo].[OttieniUnitaOperativePerToken]
(
  @IdToken UNIQUEIDENTIFIER
)
RETURNS 
    @Result TABLE (
        [UnitaOperativaCodice] VARCHAR(64) NOT NULL,
        [UnitaOperativaAzienda] VARCHAR(16) NOT NULL)
AS
BEGIN

	DECLARE @xmlCache xml = NULL
	DECLARE @CodiceRuolo VARCHAR(16) = NULL

	SELECT @xmlCache = [CacheUnitaOperative], @CodiceRuolo = CodiceRuolo
		FROM [dbo].[Tokens]
		WHERE ID = @IdToken


	IF @xmlCache IS NULL	BEGIN
		--Legge dal SAC
		INSERT INTO @Result
		SELECT [UnitaOperativaCodice], [UnitaOperativaAzienda]
			FROM [dbo].[OttieniSacUnitaOperativePerRuolo](@CodiceRuolo)

	END	ELSE BEGIN
		-- Usa i dati letti dalla cache

		INSERT INTO @Result
		SELECT
			Tab.Col.value('@UnitaOperativaCodice','varchar(64)') AS [SistemaErogante],
			Tab.Col.value('@UnitaOperativaAzienda','varchar(16)') AS [AziendaErogante]
		FROM @xmlCache.nodes('/UnitaOperative/UnitaOperativa') Tab(Col)
	END

	RETURN 
END