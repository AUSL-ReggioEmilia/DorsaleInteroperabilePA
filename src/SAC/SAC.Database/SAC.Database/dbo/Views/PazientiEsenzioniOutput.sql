

CREATE VIEW [dbo].[PazientiEsenzioniOutput]
AS
--
--2016-05-26 SANDRO Rimosso WHERE LeggePazientiPermessiLettura()=1
--
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
	PazientiEsenzioni with(nolock)











GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiEsenzioniOutput] TO [DataAccessSql]
    AS [dbo];

