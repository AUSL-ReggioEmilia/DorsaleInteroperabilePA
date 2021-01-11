
CREATE VIEW [dbo].[ListaDeltaInvioPazienti]
AS
SELECT [DataLog]
      ,CONVERT(VARCHAR(10), [IdLha]) AS [IdLha]
      ,[Inviato]
      ,[DataInvio]
      ,[Motivo]
	  ,CASE WHEN TipoOperazione=0 THEN 'Nuovo' 
			WHEN TipoOperazione=1 THEN 'Aggiorna' END AS Operazione
      ,a.Cognome
      ,a.Nome
      ,a.Sesso
      ,a.DataNascita
      ,a.CodiceFiscale
  FROM [dbo].[PazientiDropTable] p WITH(NOLOCK)
	INNER JOIN dbo.AppCn_Anagrafe a WITH(NOLOCK)
		ON p.[IdLha] = a.IdPersona


GO
GRANT SELECT
    ON OBJECT::[dbo].[ListaDeltaInvioPazienti] TO [Execute Viewer]
    AS [dbo];

