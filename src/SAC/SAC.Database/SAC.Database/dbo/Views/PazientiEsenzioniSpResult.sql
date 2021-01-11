CREATE VIEW [dbo].[PazientiEsenzioniSpResult]
AS
/*
	Modifica Ettore 2014-05-23:
		Invece di leggere la tabella PazientiEsenzioni leggo dalla vista 
		EsenzioniPazienti che fornisce tutte le esenzioni associate ad una catena di fusione
*/
SELECT    Id
		, IdPaziente
		, DataInserimento
		, DataModifica
		, CodiceEsenzione
		, CodiceDiagnosi
		, Patologica
		, DataInizioValidita
		, DataFineValidita
		, NumeroAutorizzazioneEsenzione
		, NoteAggiuntive
		, CodiceTestoEsenzione
		, TestoEsenzione
		, DecodificaEsenzioneDiagnosi
		, AttributoEsenzioneDiagnosi

FROM
	--PazientiEsenzioni with(nolock)
	EsenzioniPazienti with(nolock)


