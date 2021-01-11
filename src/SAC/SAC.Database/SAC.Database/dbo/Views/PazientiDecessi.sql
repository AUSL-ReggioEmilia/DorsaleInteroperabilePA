
CREATE VIEW [dbo].[PazientiDecessi]
AS
/*
	MODIFICA ETTORE 2016-03-11: Usato UNION ALL (cosi non viene eseguito il codice che fa il distinct: miglioramento del 50%)
*/
	SELECT
		P.Id AS IdPaziente
		, P.Provenienza 
		, P.IdProvenienza 
		, CAST(NULL AS UNIQUEIDENTIFIER) AS IdPazienteFuso		
		, P.DataTerminazioneAss AS DataDecesso
		, P.DataModifica
	FROM 
		dbo.Pazienti AS P WITH(NOLOCK) 
	WHERE Disattivato = 0 --Indice???
		AND P.CodiceTerminazione = '4'  
		AND NOT P.DataTerminazioneAss IS NULL 
		AND P.DataTerminazioneAss > '1753-01-01 00:00:00.000'
	UNION ALL
	SELECT
		PF.IdPaziente 
		, P.Provenienza 
		, P.IdProvenienza 
		, P.Id AS IdPazienteFuso
		, P.DataTerminazioneAss AS DataDecesso
		, P.DataModifica
	FROM 
		dbo.Pazienti AS P WITH(NOLOCK) 
		INNER JOIN PazientiFusioni AS PF WITH(NOLOCK) 
			ON P.Id = PF.IdPazienteFuso
	WHERE 
		PF.Abilitato = 1 
		AND P.CodiceTerminazione = '4' 
		AND NOT P.DataTerminazioneAss IS NULL 
		AND P.DataTerminazioneAss > '1753-01-01 00:00:00.000'

