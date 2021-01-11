

-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-01
-- Modify date: 2015-04-23 Stefano: corretto filtro DataModifica NON è in UTC
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Description: Lista dei referti modificati nelle ultime x ore
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertiUltimiArrivi]
(
 @NumeroOre INT --FILTRA SOLO I REFERTI MODIFICATI NON PIU' DI TOT ORE FA
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
		[store].[RefertiBase]
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
    ON OBJECT::[dbo].[BevsRefertiUltimiArrivi] TO [ExecuteFrontEnd]
    AS [dbo];

