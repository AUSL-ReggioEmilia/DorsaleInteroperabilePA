



CREATE VIEW [dbo].[FullSyncLhaPazientiEsenzioni]
AS
/*
	2018-05-28 - MODIFICA ETTORE: Gestione delle sole esenzioni con Provenienza=LHA
*/
SELECT 	P.IdProvenienza AS IdLHA
	, PE.*
FROM dbo.PazientiEsenzioni AS PE WITH (nolock) 
	INNER JOIN dbo.Pazienti AS P WITH (nolock) 
		ON PE.IdPaziente = P.Id
WHERE P.Provenienza = 'LHA'
	AND P.Disattivato = 0 
	--2018-05-28 - MODIFICA ETTORE: Solo le esenzioni con Provenienza=LHA
	AND PE.Provenienza = 'LHA' 




GO
GRANT SELECT
    ON OBJECT::[dbo].[FullSyncLhaPazientiEsenzioni] TO [DataAccessSISS]
    AS [dbo];

