
CREATE VIEW [dbo].[ListaDeltaInvioConsensi]
AS
SELECT [DataInserimento] AS DataLog
      ,[PazienteProvenienzaId] AS IdLha
      ,CONVERT(BIT, CASE WHEN [DataElaborazione] IS NULL THEN 0 ELSE 1 END) AS Inviato
      ,[DataElaborazione] AS DataInvio
      ,'Consenso' AS Motivo
	  ,CASE WHEN [Operazione]=0 THEN 'Nuovo' 
			WHEN [Operazione]=1 THEN 'Aggiorna' END AS [Operazione]
      ,[Tipo]
      ,[DataStato]
      ,[Stato]
      ,a.Cognome
      ,a.Nome
      ,a.Sesso
      ,a.DataNascita
      ,a.CodiceFiscale

  FROM [dbo].[ConsensiDropTable] c WITH(NOLOCK)
  	INNER JOIN dbo.AppCn_Anagrafe a WITH(NOLOCK)
		ON c.[PazienteProvenienzaId] = a.IdPersona
  WHERE [PazienteProvenienza] = 'LHA'


GO
GRANT SELECT
    ON OBJECT::[dbo].[ListaDeltaInvioConsensi] TO [Execute Viewer]
    AS [dbo];

