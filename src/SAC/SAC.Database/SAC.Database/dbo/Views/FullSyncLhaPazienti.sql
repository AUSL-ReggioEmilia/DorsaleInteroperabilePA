

CREATE VIEW [dbo].[FullSyncLhaPazienti]
AS
SELECT 	P.IdProvenienza AS IdLHA
		, P.*
FROM dbo.Pazienti AS P WITH (nolock) 
WHERE P.Provenienza = 'LHA'



GO
GRANT SELECT
    ON OBJECT::[dbo].[FullSyncLhaPazienti] TO [DataAccessSISS]
    AS [dbo];

