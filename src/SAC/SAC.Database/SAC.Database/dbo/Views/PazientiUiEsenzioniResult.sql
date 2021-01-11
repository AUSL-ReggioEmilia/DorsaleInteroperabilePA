
CREATE VIEW [dbo].[PazientiUiEsenzioniResult]
AS

SELECT     
	Id, 
	IdPaziente, 
	DataInserimento, 
	DataModifica, 
	CodiceEsenzione, 
	CodiceDiagnosi, 
	Patologica, 
	DataInizioValidita, 
	DataFineValidita, 
    NumeroAutorizzazioneEsenzione, 
	NoteAggiuntive, 
	CodiceTestoEsenzione, 
	TestoEsenzione, 
	DecodificaEsenzioneDiagnosi, 
	AttributoEsenzioneDiagnosi

FROM         
	PazientiEsenzioni with(nolock)

