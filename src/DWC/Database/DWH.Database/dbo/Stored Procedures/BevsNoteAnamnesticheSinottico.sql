

-- =============================================
-- Author:      SimoneB
-- Create date: 2017-11-28
-- Description: Monitoraggio ultime note anamnestiche raggruppati per sistema erog. (con subtotali)
-- =============================================
CREATE PROCEDURE [dbo].[BevsNoteAnamnesticheSinottico]
(
 @DataDal DATETIME,
 @DataAl DATETIME
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		 GROUPING(AziendaErogante + '-' + SistemaErogante) as IsTotale
		 ,GROUPING(LTRIM(TipoCodice)) as IsSubTotale
		,AziendaErogante + '-' + SistemaErogante AS AziendaSistemaErogante
		,LTRIM(TipoCodice) AS SubProcessoTipo
		,SUM(CASE WHEN StatoCodice = 0 THEN 1 ELSE NULL END) as InCorso
		,SUM(CASE WHEN StatoCodice = 1 THEN 1 ELSE NULL END) as Completata
		,SUM(CASE WHEN StatoCodice = 2 THEN 1 ELSE NULL END) as Variata
		,SUM(CASE WHEN StatoCodice = 3 THEN 1 ELSE NULL END) as Cancellata

	FROM 
		store.NoteAnamnesticheBase WITH (NOLOCK)
			
	WHERE 
		DataModifica BETWEEN @DataDal AND @DataAl
		AND DataPartizione > DATEADD(YEAR, -1, GETDATE()) --LIMITO IL NUMERO DEI DB COINVOLTI
		
	GROUP BY
		ROLLUP((AziendaErogante + '-' + SistemaErogante),LTRIM(TipoCodice))
		
	ORDER BY 
		GROUPING(AziendaErogante + '-' + SistemaErogante), AziendaErogante + '-' + SistemaErogante,GROUPING(LTRIM(TipoCodice)) DESC
		
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNoteAnamnesticheSinottico] TO [ExecuteFrontEnd]
    AS [dbo];

