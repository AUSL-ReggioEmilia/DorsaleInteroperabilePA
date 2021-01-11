

-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-10-14
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Description: Monitoraggio degli eventi modificati nelle ultime x ore
-- =============================================
CREATE PROCEDURE [dbo].[BevsEventiUltimiArrivi]
(
 @NumeroOre INT --FILTRA SOLO GLI EVENTI MODIFICATI NON PIU' DI TOT ORE FA
)
AS
BEGIN
  SET NOCOUNT OFF

	SET @NumeroOre = @NumeroOre * -1
	
	SELECT 
		  AziendaErogante
		, SistemaErogante
		, MAX(DataModifica) AS DataModifica
		, COUNT(*) AS [Count]
	FROM 
		[store].[EventiBase]
	WHERE 
		DataModifica > DATEADD(HOUR, @NumeroOre, GETDATE())		
		AND DataPartizione > DATEADD(YEAR, -1, GETDATE()) --LIMITO IL NUMERO DEI DB COINVOLTI

	GROUP BY 
		AziendaErogante, SistemaErogante
	ORDER BY 
		AziendaErogante, SistemaErogante

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsEventiUltimiArrivi] TO [ExecuteFrontEnd]
    AS [dbo];

