



-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-10-26
-- Description: Restituisce le esenzioni 
-- Modify date: Simone B - 2018-03-26, Restituito il campo Provenienza
-- =============================================
CREATE VIEW [pazienti_ws].[PazientiEsenzioni]
AS

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
		, Provenienza
		, OperatoreId
		, OperatoreCognome
		, OperatoreNome
		, OperatoreComputer	

FROM	
	dbo.EsenzioniPazienti with(nolock)