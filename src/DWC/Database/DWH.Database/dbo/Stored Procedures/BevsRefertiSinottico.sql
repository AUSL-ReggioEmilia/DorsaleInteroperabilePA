
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-10-14
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Description: Monitoraggio ultimi referti raggruppati per sistema erog. e reparto rich. (con subtotali)
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertiSinottico]
(
	@DataDal DATETIME,
	@DataAl DATETIME
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		 GROUPING(AziendaErogante + '-' + SistemaErogante) as IsTotale
		,GROUPING(LTRIM(RepartoRichiedenteDescr)) as IsSubTotale
		,AziendaErogante + '-' + SistemaErogante AS AziendaSistemaErogante
		,LTRIM(RepartoRichiedenteDescr) AS RepartoRichiedente
		,SUM(CASE WHEN StatoRichiestaCodice = 0 THEN 1 ELSE NULL END) as InCorso
		,SUM(CASE WHEN StatoRichiestaCodice = 1 THEN 1 ELSE NULL END) as Completata
		,SUM(CASE WHEN StatoRichiestaCodice = 2 THEN 1 ELSE NULL END) as Variata
		,SUM(CASE WHEN StatoRichiestaCodice = 3 THEN 1 ELSE NULL END) as Cancellata

	FROM 
		store.RefertiBase WITH (NOLOCK)
			
	WHERE 
		DataModifica BETWEEN @DataDal AND @DataAl
		AND DataPartizione > DATEADD(YEAR, -1, GETDATE()) --LIMITO IL NUMERO DEI DB COINVOLTI
		
	GROUP BY
		ROLLUP( (AziendaErogante + '-' + SistemaErogante), LTRIM(RepartoRichiedenteDescr) )
		
	ORDER BY 
		GROUPING(AziendaErogante + '-' + SistemaErogante), AziendaErogante + '-' + SistemaErogante, 
		GROUPING(LTRIM(RepartoRichiedenteDescr)) DESC
		
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiSinottico] TO [ExecuteFrontEnd]
    AS [dbo];

