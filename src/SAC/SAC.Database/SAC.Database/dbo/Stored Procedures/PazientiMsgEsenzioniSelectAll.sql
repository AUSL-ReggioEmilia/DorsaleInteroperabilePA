-- =============================================
-- Author:		?
-- Create date: ?
-- Description:	<Description,,>
-- Modify date: 2018-07-30 - ETTORE: Aggiunto i nuovi campi della tabella delle esenzioni
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgEsenzioniSelectAll]
	@Id AS uniqueidentifier
AS
BEGIN

	SET NOCOUNT ON;

	SELECT     
		PazientiEsenzioni.Id
		, PazientiEsenzioni.CodiceEsenzione
		, PazientiEsenzioni.CodiceDiagnosi
		, PazientiEsenzioni.Patologica
		, PazientiEsenzioni.DataInizioValidita
		, PazientiEsenzioni.DataFineValidita
		, PazientiEsenzioni.NumeroAutorizzazioneEsenzione
		, PazientiEsenzioni.NoteAggiuntive
		, PazientiEsenzioni.CodiceTestoEsenzione
		, PazientiEsenzioni.TestoEsenzione
		, PazientiEsenzioni.DecodificaEsenzioneDiagnosi
		, PazientiEsenzioni.AttributoEsenzioneDiagnosi

		-- Modify date: 2018-07-30 - ETTORE: Aggiunto i nuovi campi della tabella delle esenzioni
		, PazientiEsenzioni.Provenienza
		, PazientiEsenzioni.OperatoreId
		, PazientiEsenzioni.OperatoreCognome
		, PazientiEsenzioni.OperatoreNome
		, PazientiEsenzioni.OperatoreComputer	
	FROM         
		PazientiEsenzioni 
	WHERE   
		PazientiEsenzioni.IdPaziente = @Id

END;




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgEsenzioniSelectAll] TO [DataAccessDll]
    AS [dbo];

