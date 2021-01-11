CREATE VIEW DataAccess.TracciaAccessi
AS 
/*
	CREATA DA ETTORE 2016-01-29: 
		Nuova vista ad uso esclusivo accesso ESTERNO per restituire il log degli accessi al DWH
*/
SELECT  
	[Id]
	,[Data]
	,[UtenteRichiedente]
	,[NomeRichiedente]
	,[IdUtenteRichiedente]
	,[IdPazienti]
	,[Operazione]
	,[NomeHostRichiedente]
	,[IndirizzoIPHostRichiedente]
	,[IdReferti]
	,[IdRicoveri]
	,[IdEventi]
	,[IdEsterno]
	,[RuoloUtenteCodice]
	,[RuoloUtenteDescrizione]
	,[MotivoAccesso]
	,[Note]
FROM [dbo].[TracciaAccessi]  with (nolock)
UNION
SELECT 
	[Id]
	,[Data]
	,[UtenteRichiedente]
	,[NomeRichiedente]
	,[IdUtenteRichiedente]
	,[IdPazienti]
	,[Operazione]
	,[NomeHostRichiedente]
	,[IndirizzoIPHostRichiedente]
	,[IdReferti]
	,[IdRicoveri]
	,[IdEventi]
	,[IdEsterno]
	,[RuoloUtenteCodice]
	,[RuoloUtenteDescrizione]
	,[MotivoAccesso]
	,[Note]
FROM [dbo].[TracciaAccessi_Storico] with (nolock)