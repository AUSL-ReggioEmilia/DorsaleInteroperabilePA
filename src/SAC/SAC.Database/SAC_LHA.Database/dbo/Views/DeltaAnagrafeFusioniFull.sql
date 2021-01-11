
CREATE VIEW [dbo].[DeltaAnagrafeFusioniFull]
AS

SELECT 
	  F.IdVincente AS IDLha
	, F.IdVincente
	, F.CodiceFiscaleVincente
	, F.IdVittima
	, F.CodiceFiscaleVittima
	,'Fusione' as Motivo
	
FROM 
	AppCn_Fusioni F with(nolock) 
	LEFT JOIN dbo.SacFullSyncLhaPazientiFusi AS P with(nolock) 
		ON F.IdVittima = P.IdLhaFuso
	
WHERE (P.IdLhaFuso IS NULL
	OR (F.IdVincente <> P.IdLhaPadre
		AND dbo.GetPadreFusioneLHA(F.IdVittima) <> P.IdLhaPadre)
	)
	--
	-- Non già nella DropTable da inviare
	--
	AND NOT EXISTS (SELECT *
					FROM dbo.PazientiDropTable dt WITH (nolock) 
					WHERE dt.IdLha = F.IdVincente AND dt.Inviato = 0)

