


CREATE VIEW [dbo].[FullSyncLhaPazientiConsensi]
AS
SELECT 	P.IdProvenienza AS IdLHA
	, C.*
FROM dbo.Consensi AS C WITH (nolock) 
	INNER JOIN dbo.Pazienti AS P WITH (nolock) 
		ON C.IdPaziente = P.Id
WHERE P.Provenienza = 'LHA'
	AND C.Provenienza = 'LHA'
	AND P.Disattivato = 0 




GO
GRANT SELECT
    ON OBJECT::[dbo].[FullSyncLhaPazientiConsensi] TO [DataAccessSISS]
    AS [dbo];

