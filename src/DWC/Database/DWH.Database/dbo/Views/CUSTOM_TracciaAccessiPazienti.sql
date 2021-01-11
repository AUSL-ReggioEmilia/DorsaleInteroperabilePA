-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2010-05-07
-- Modify date: 2016-05-11 sandro - Usa nuova vista sac.Pazienti
-- Description:	 
-- =============================================
CREATE VIEW [dbo].[CUSTOM_TracciaAccessiPazienti]
AS
	-- Leggo da TracciaAccessi
	SELECT     
		TracciaAccessi.Id, 
		TracciaAccessi.Data, 
		TracciaAccessi.Operazione, 
		TracciaAccessi.UtenteRichiedente, 
		TracciaAccessi.NomeRichiedente, 
		TracciaAccessi.IdUtenteRichiedente, 
		Pazienti.Cognome, 
		Pazienti.Nome, 
		Pazienti.DataNascita, 
		Pazienti.LuogoNascitaDescrizione AS LuogoNascita, 
		TracciaAccessi.IdPazienti, 
		TracciaAccessi.NomeHostRichiedente, 
		TracciaAccessi.IndirizzoIPHostRichiedente
	FROM   
		TracciaAccessi 
		INNER JOIN sac.Pazienti WITH(NOLOCK) 
			ON TracciaAccessi.IdPazienti = Pazienti.Id
	UNION
	-- Leggo da TracciaAccessi_Storico	
	SELECT     
		TracciaAccessi.Id, 
		TracciaAccessi.Data, 
		TracciaAccessi.Operazione, 
		TracciaAccessi.UtenteRichiedente, 
		TracciaAccessi.NomeRichiedente, 
		TracciaAccessi.IdUtenteRichiedente, 
		Pazienti.Cognome, 
		Pazienti.Nome, 
		Pazienti.DataNascita, 
		Pazienti.LuogoNascitaDescrizione AS LuogoNascita, 
		TracciaAccessi.IdPazienti, 
		TracciaAccessi.NomeHostRichiedente, 
		TracciaAccessi.IndirizzoIPHostRichiedente
	FROM   
		TracciaAccessi_Storico AS TracciaAccessi 
		INNER JOIN sac.Pazienti WITH(NOLOCK) 
			ON TracciaAccessi.IdPazienti = Pazienti.Id


GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_TracciaAccessiPazienti] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_TracciaAccessiPazienti] TO [ReadOlap]
    AS [dbo];

