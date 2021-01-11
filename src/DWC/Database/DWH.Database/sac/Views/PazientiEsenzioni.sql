-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-05-12
-- Description:	Accesso al SAC - Esenzione del paziente
-- =============================================
CREATE VIEW [sac].[PazientiEsenzioni]
AS
	SELECT	Id
		, IdPaziente AS IdPazienti
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
	FROM SAC_Esenzioni WITH(NOLOCK)