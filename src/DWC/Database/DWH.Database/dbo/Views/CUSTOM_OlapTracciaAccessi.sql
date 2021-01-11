

CREATE VIEW [dbo].[CUSTOM_OlapTracciaAccessi]
AS
	-- Leggo dallo TracciaAccessi
	SELECT 
		ID,
		YEAR(TracciaAccessi.Data) AS DataAnno,
		MONTH(TracciaAccessi.Data) AS DataMese,
		DAY(TracciaAccessi.Data) AS DataGiorno,
		DATEPART(HOUR, TracciaAccessi.Data) AS DataOra,
		TracciaAccessi.Data,
		CASE 	
			WHEN TracciaAccessi.UtenteRichiedente LIKE 'OSPEDALE%' THEN 'ASMN'
			WHEN TracciaAccessi.UtenteRichiedente LIKE 'MASTER_USL%' THEN 'AUSL'
			ELSE 'Sconosciuto'
		END AS AziendaRichiedente,
		CASE 	
			WHEN TracciaAccessi.IdReferti IS NULL THEN 'Paziente'
			WHEN TracciaAccessi.IdPazienti = '00000000-0000-0000-0000-000000000000' THEN 'Referto'
			ELSE 'Altro'
		END AS TipoAccesso,
		TracciaAccessi.NomeRichiedente  AS Operatore
	FROM    
		TracciaAccessi 
	WHERE 
		TracciaAccessi.Data BETWEEN '2000-01-01' AND CONVERT(DATETIME, CONVERT(VARCHAR(40), GETDATE(), 112),  112)
		AND NOT UtenteRichiedente = ('OSPEDALE\svc_dwc_scom')
	UNION 
		-- Leggo dallo TracciaAccessi_Storico
	SELECT 
		ID,
		YEAR(TracciaAccessi.Data) AS DataAnno,
		MONTH(TracciaAccessi.Data) AS DataMese,
		DAY(TracciaAccessi.Data) AS DataGiorno,
		DATEPART(HOUR, TracciaAccessi.Data) AS DataOra,
		TracciaAccessi.Data,
		CASE 	
			WHEN TracciaAccessi.UtenteRichiedente LIKE 'OSPEDALE%' THEN 'ASMN'
			WHEN TracciaAccessi.UtenteRichiedente LIKE 'MASTER_USL%' THEN 'AUSL'
			ELSE 'Sconosciuto'
		END AS AziendaRichiedente,
		CASE 	
			WHEN TracciaAccessi.IdReferti IS NULL THEN 'Paziente'
			WHEN TracciaAccessi.IdPazienti = '00000000-0000-0000-0000-000000000000' THEN 'Referto'
			ELSE 'Altro'
		END AS TipoAccesso,
		TracciaAccessi.NomeRichiedente  AS Operatore
	FROM    
		TracciaAccessi_Storico AS TracciaAccessi 
	WHERE 
		TracciaAccessi.Data BETWEEN '2000-01-01' AND CONVERT(DATETIME, CONVERT(VARCHAR(40), GETDATE(), 112),  112)
		AND NOT UtenteRichiedente = ('OSPEDALE\svc_dwc_scom')


GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_OlapTracciaAccessi] TO [ReadOlap]
    AS [dbo];

