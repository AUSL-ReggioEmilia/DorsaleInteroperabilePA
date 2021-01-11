


-- =============================================
-- Author:      Simone B.
-- Create date: 2017-05-05
-- Description: Lista dei Pazienti ricoverati nel'ultima ora.
-- =============================================
CREATE PROCEDURE [dbo].[PazientiUiUltimiArrivi]
(
 @NumeroOre INT --FILTRA SOLO I PAZIENTI MODIFICATI NON PIU' DI TOT ORE FA
)
AS
BEGIN
  	SET NOCOUNT ON;

	SET @NumeroOre = @NumeroOre * -1
	
	SELECT
		Provenienza
		,MAX(DataModifica) AS DataModifica
		,COUNT(*) AS [Count]
	FROM 
		[dbo].[Pazienti] with(nolock)
	WHERE 
		DataModifica > DATEADD(HOUR, @NumeroOre, GETDATE())		

	GROUP BY 
		Provenienza
	ORDER BY
		Provenienza

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiUltimiArrivi] TO [DataAccessUi]
    AS [dbo];

