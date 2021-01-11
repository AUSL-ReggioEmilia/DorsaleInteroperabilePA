
CREATE VIEW [dbo].[StatisticheDeltaInvioPazienti]
AS
SELECT COUNT(*) AS Numero
	,CONVERT(DATE, [DataInvio]) AS DataInvio
	,Motivo
	,CASE WHEN TipoOperazione=0 THEN 'Nuovo' WHEN TipoOperazione=1 THEN 'Aggiorna' END AS Tipo
  FROM [dbo].[PazientiDropTable] WITH(NOLOCK)
  GROUP BY CONVERT(DATE, [DataInvio])
	,Motivo
	,CASE WHEN TipoOperazione=0 THEN 'Nuovo' WHEN TipoOperazione=1 THEN 'Aggiorna' END


GO
GRANT SELECT
    ON OBJECT::[dbo].[StatisticheDeltaInvioPazienti] TO [Execute Viewer]
    AS [dbo];

