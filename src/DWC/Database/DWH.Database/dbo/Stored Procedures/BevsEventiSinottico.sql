
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-10-15
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Description: Monitoraggio ultimi eventi raggruppati per sistema erog. e reparto di ricovero (con subtotali)
-- =============================================
CREATE PROCEDURE [dbo].[BevsEventiSinottico]
(
 @DataDal DATETIME,
 @DataAl DATETIME
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		 GROUPING(AziendaErogante + '-' + SistemaErogante) as IsTotale
		,GROUPING(LTRIM(RepartoDescr)) as IsSubTotale
		,AziendaErogante + '-' + SistemaErogante AS AziendaSistemaErogante
		,LTRIM(RepartoDescr) AS Reparto
		,SUM(CASE WHEN TipoEventoCodice = 'A' THEN 1 ELSE NULL END) as TIPO_A
		,SUM(CASE WHEN TipoEventoCodice = 'T' THEN 1 ELSE NULL END) as TIPO_T
		,SUM(CASE WHEN TipoEventoCodice = 'D' THEN 1 ELSE NULL END) as TIPO_D
		,SUM(CASE WHEN TipoEventoCodice = 'R' THEN 1 ELSE NULL END) as TIPO_R
		,SUM(CASE WHEN TipoEventoCodice = 'IL' THEN 1 ELSE NULL END) as TIPO_IL
		,SUM(CASE WHEN TipoEventoCodice = 'ML' THEN 1 ELSE NULL END) as TIPO_ML
		,SUM(CASE WHEN TipoEventoCodice = 'DL' THEN 1 ELSE NULL END) as TIPO_DL

	FROM 
		store.EventiBase  WITH (NOLOCK)
			
	WHERE 
		TipoEventoCodice IN ('A', 'T', 'D' ,'R', 'IL', 'ML' , 'DL') 
		AND DataModifica BETWEEN @DataDal AND @DataAl
		AND DataPartizione > DATEADD(YEAR, -1, GETDATE()) --LIMITO IL NUMERO DEI DB COINVOLTI
		
	GROUP BY
		ROLLUP( (AziendaErogante + '-' + SistemaErogante), LTRIM(RepartoDescr) )
		
	ORDER BY 
		GROUPING(AziendaErogante + '-' + SistemaErogante), AziendaErogante + '-' + SistemaErogante, GROUPING(LTRIM(RepartoDescr)) DESC
		
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsEventiSinottico] TO [ExecuteFrontEnd]
    AS [dbo];

