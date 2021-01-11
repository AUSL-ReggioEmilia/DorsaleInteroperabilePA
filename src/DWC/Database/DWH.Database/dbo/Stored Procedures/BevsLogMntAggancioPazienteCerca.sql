



-- =============================================
-- Author:		ETTORE
-- Create date: 2018-01-12
-- Description:	Restituisce la lista degli agganci pazioente fatti dalle manteinance
-- =============================================
CREATE PROCEDURE [dbo].[BevsLogMntAggancioPazienteCerca]
(
	@MaxRow INTEGER = 1000
	, @Oggetto AS VARCHAR(64)
	, @DataDal DATETIME
	, @DataAl DATETIME = NULL
)
AS
BEGIN
	IF @DataAl IS NULL
		SET @DataAl = CAST(CONVERT(VARCHAR(10), GETDATE(), 120) AS DATETIME)
	SET @DataAl = DATEADD(day, 1, @DataAl)

	IF @Oggetto = '' 
		SET @Oggetto = NULL

	SELECT TOP (@MaxRow) 
		Id
		, Oggetto
		, DataInserimento
		, IdPaziente
		, AziendaErogante
		, SistemaErogante
		, IdOggetto
		, IdEsternoOggetto
	  FROM dbo.LogMntAggancioPaziente
	  WHERE 
		(Oggetto = @Oggetto OR @Oggetto IS NULL)
		AND DataInserimento between  @DataDal AND @DataAl
	  ORDER BY DataInserimento DESC

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsLogMntAggancioPazienteCerca] TO [ExecuteFrontEnd]
    AS [dbo];

