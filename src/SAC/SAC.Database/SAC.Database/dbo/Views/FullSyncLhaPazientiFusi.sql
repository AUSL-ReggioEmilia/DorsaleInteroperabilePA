


CREATE VIEW [dbo].[FullSyncLhaPazientiFusi]
AS

SELECT 	PF.IdProvenienza AS IdLhaFuso
 		, PP.IdProvenienza AS IdLhaPadre
		, PF.Id AS IdSacFuso
		, PP.Id AS IdSacPadre

		, PF.Cognome AS CognomeFuso
		, PP.Cognome AS CognomePadre

		, PF.Nome AS NomeFuso
		, PP.Nome AS NomePadre

		, PF.CodiceFiscale AS CodiceFiscaleFuso
		, PP.CodiceFiscale AS CodiceFiscalePadre

		, PP.Disattivato AS StatoDisattivatoPadre
		
FROM dbo.Pazienti AS PF WITH (nolock) 
	INNER JOIN ( SELECT *
				 FROM dbo.PazientiFusioni WITH (nolock)
				 WHERE Abilitato = 1
			   ) AS F 
	
		ON PF.Id = F.IdPazienteFuso
			
	LEFT JOIN ( SELECT *
				 FROM dbo.Pazienti WITH (nolock)
				 WHERE Provenienza = 'LHA'
			   ) AS PP
				 
		ON PP.Id = F.IdPaziente

WHERE PF.Provenienza = 'LHA'
	AND PF.Disattivato = 2



GO
GRANT SELECT
    ON OBJECT::[dbo].[FullSyncLhaPazientiFusi] TO [DataAccessSISS]
    AS [dbo];

