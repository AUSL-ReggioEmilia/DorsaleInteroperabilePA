
CREATE VIEW [dbo].[PazientiDecessi_with]
AS
/*
	MODIFICA ETTORE 2016-03-11: Usato UNION ALL (cosi non viene eseguito il codice che fa
												 il distinct: miglioramento del 50%)
	MODIFICA SANDRO 2016-11-29: Redisignata con il WITH
*/
	WITH Deceduti AS (
	SELECT
		  P.Id AS IdPaziente
		, P.Provenienza 
		, P.IdProvenienza 
		, P.DataTerminazioneAss AS DataDecesso
		, P.DataModifica
		, P.Disattivato
	FROM 
		dbo.Pazienti AS P WITH(NOLOCK) 
	WHERE P.Disattivato <> 1
		AND P.CodiceTerminazione = '4'  
		AND NOT P.DataTerminazioneAss IS NULL 
		AND P.DataTerminazioneAss > '1753-01-01 00:00:00.000')
	--
	-- Attivi deceduti
	--
	SELECT
		  P.IdPaziente 
		, P.Provenienza 
		, P.IdProvenienza 
		, CAST(NULL AS UNIQUEIDENTIFIER) IdPazienteFuso
		, P.DataDecesso
		, P.DataModifica
		, P.Disattivato
	FROM Deceduti AS P 
	WHERE P.Disattivato = 0

	UNION ALL
	--
	-- Fusi deceduti
	--
	SELECT
		  PF.IdPaziente 
		, P.Provenienza 
		, P.IdProvenienza 
		, P.IdPaziente AS IdPazienteFuso
		, P.DataDecesso
		, P.DataModifica
		, P.Disattivato
	FROM 
		Deceduti AS P 
		INNER JOIN PazientiFusioni AS PF WITH(NOLOCK) 
			ON P.IdPaziente = PF.IdPazienteFuso
			AND PF.Abilitato = 1

	WHERE P.Disattivato = 2