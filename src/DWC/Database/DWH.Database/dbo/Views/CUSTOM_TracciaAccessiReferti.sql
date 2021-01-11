



-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2010-05-17
-- Modify date: 2016-05-11 sandro - Usa nuova vista sac.Pazienti
-- Modify date: 2016-05-11 ETTORE - Usato vista store.Referti al posto di dbo.Referti
-- Description:	Problemi se query distribuite
-- =============================================
CREATE VIEW [dbo].[CUSTOM_TracciaAccessiReferti]
AS
	-- Leggo dalla tabella TracciaAccessi
	SELECT  
		TracciaAccessi.Id,
		TracciaAccessi.Data AS AccessoData,
		TracciaAccessi.UtenteRichiedente AS OperatoreUtente,
		TracciaAccessi.NomeRichiedente AS OperatoreNome,
		Paziente.Nome AS PazienteNome,
		Paziente.Cognome AS PazienteCognome,
		Paziente.CodiceFiscale AS PazienteCodiceFiscale,
		Paziente.DataNascita AS PazienteDataNascita,
		Paziente.LuogoNascitaDescrizione AS PazienteLuogoNascita,

		CASE TracciaAccessi.Operazione 
			WHEN '/Dwhclinico/Referti/ApreReferto.aspx' THEN 'Apre referto'
			WHEN 'Referti.Link' THEN 'Lista Referti'
			ELSE TracciaAccessi.Operazione END
		AS Operazione ,
		
		store.Referti.SistemaErogante,
		store.Referti.RepartoErogante,
		store.Referti.RepartoRichiedenteCodice,
		store.Referti.RepartoRichiedenteDescr,
		store.Referti.DataReferto,
		store.Referti.NumeroReferto

	FROM         
		TracciaAccessi WITH(NOLOCK) 
		LEFT OUTER JOIN store.Referti WITH(NOLOCK) 
			ON TracciaAccessi.IdReferti = store.Referti.Id

		CROSS APPLY [sac].[OttienePazientePerIdSac]( COALESCE(store.Referti.IdPaziente, TracciaAccessi.IdPazienti)) Paziente

	WHERE 
		(
			TracciaAccessi.Operazione = 'Apre referto' OR
			TracciaAccessi.Operazione = 'Lista referti' OR
			TracciaAccessi.Operazione = '/Dwhclinico/Referti/ApreReferto.aspx' OR
			TracciaAccessi.Operazione = 'Referti.Link'
		)
	UNION
	-- Leggo dalla tabella TracciaAccessi_Storico	
	SELECT  
		TracciaAccessi.Id,
		TracciaAccessi.Data AS AccessoData,
		TracciaAccessi.UtenteRichiedente AS OperatoreUtente,
		TracciaAccessi.NomeRichiedente AS OperatoreNome,

		Paziente.Nome AS PazienteNome,
		Paziente.Cognome AS PazienteCognome,
		Paziente.CodiceFiscale AS PazienteCodiceFiscale,
		Paziente.DataNascita AS PazienteDataNascita,
		Paziente.LuogoNascitaDescrizione AS PazienteLuogoNascita,

		CASE TracciaAccessi.Operazione 
			WHEN '/Dwhclinico/Referti/ApreReferto.aspx' THEN 'Apre referto'
			WHEN 'Referti.Link' THEN 'Lista Referti'
			ELSE TracciaAccessi.Operazione END
		AS Operazione ,
		
		store.Referti.SistemaErogante,
		store.Referti.RepartoErogante,
		store.Referti.RepartoRichiedenteCodice,
		store.Referti.RepartoRichiedenteDescr,
		store.Referti.DataReferto,
		store.Referti.NumeroReferto

	FROM         
		TracciaAccessi_Storico AS TracciaAccessi WITH(NOLOCK) 
		LEFT OUTER JOIN store.Referti WITH(NOLOCK) 
			ON TracciaAccessi.IdReferti = store.Referti.Id

		CROSS APPLY [sac].[OttienePazientePerIdSac]( COALESCE(store.Referti.IdPaziente, TracciaAccessi.IdPazienti)) Paziente

	WHERE 
		(
			TracciaAccessi.Operazione = 'Apre referto' OR
			TracciaAccessi.Operazione = 'Lista referti' OR
			TracciaAccessi.Operazione = '/Dwhclinico/Referti/ApreReferto.aspx' OR
			TracciaAccessi.Operazione = 'Referti.Link'
		)


GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_TracciaAccessiReferti] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_TracciaAccessiReferti] TO [ReadOlap]
    AS [dbo];

