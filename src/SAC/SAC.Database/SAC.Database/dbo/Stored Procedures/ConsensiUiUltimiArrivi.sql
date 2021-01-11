



-- =============================================
-- Author:      Simone B.
-- Create date: 2017-05-09
-- Description: Lista dei Consensi espressi nel'ultima ora.
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiUiUltimiArrivi]
(
 @NumeroOre INT --FILTRA SOLO I CONSENSI INSERITI NON PIU' DI TOT ORE FA
)
AS
BEGIN
  	SET NOCOUNT ON;

	SET @NumeroOre = @NumeroOre * -1
	
	SELECT
		Provenienza
		,MAX(DataInserimento) AS DataModifica
		,COUNT(*) AS [Count]
	FROM 
		[dbo].[Consensi] with(nolock)
	WHERE 
		DataInserimento > DATEADD(HOUR, @NumeroOre, GETDATE())		

	GROUP BY 
		Provenienza
	ORDER BY
		Provenienza

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiUiUltimiArrivi] TO [DataAccessUi]
    AS [dbo];

