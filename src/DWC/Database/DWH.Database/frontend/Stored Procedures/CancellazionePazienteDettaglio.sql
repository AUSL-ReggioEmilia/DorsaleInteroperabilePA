


CREATE PROCEDURE [frontend].[CancellazionePazienteDettaglio]
@IdPazienti  uniqueidentifier
 AS
 /*

	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsCancellazionePazienteDettaglio2

	Restituisce le informazioni relative al paziente passato
	MODIFICA ETTORE 2014-09-25: utilizzo della funzione GetPazienteConsensoMinimo()
*/
SET NOCOUNT ON

SELECT
	AziendaErogante, 
	SistemaErogante, 
	RepartoErogante, 
	CodiceSanitario,
	Nome, Cognome,
	DataNascita,
	LuogoNascita,
	CodiceFiscale,
	Sesso,
	dbo.GetPazientiConsensoMinimo(Id) as Consenso, 
	DatiAnamnestici
FROM
	Pazienti
WHERE
	Id=@IdPazienti



