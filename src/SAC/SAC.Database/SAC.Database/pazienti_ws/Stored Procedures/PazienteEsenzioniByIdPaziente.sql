

-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-10-25
-- Description: Restituisce le esenzioni del paziente passato
-- Modify Date: SimoneB - 2018-03-26, Restituito il campo Provenienza
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteEsenzioniByIdPaziente]
(
	@Identity varchar(64),
	@IdPaziente uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	


	---------------------------------------------------
	--  Traslo l'IdPaziente nell'attivo/padre
	---------------------------------------------------
	SET @IdPaziente = dbo.GetPazienteRootByPazienteId(@IdPaziente) 
	
	SELECT
		Id
		, IdPaziente		
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
		[pazienti_ws].[PazientiEsenzioni]
	WHERE
		IdPaziente = @IdPaziente
	
END