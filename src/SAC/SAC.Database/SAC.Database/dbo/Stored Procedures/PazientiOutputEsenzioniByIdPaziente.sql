-- =============================================
-- Author:		...
-- Create date: ...
-- Modify sate: 2016-05-26 Rimosso controllo accesso di lettura
-- Description:	Ritorna la lista delle esenzioni copiata da WS
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputEsenzioniByIdPaziente]
	@IdPaziente uniqueidentifier

AS
BEGIN

DECLARE @Identity AS varchar(64)

	SET NOCOUNT ON;

	IF @IdPaziente IS NULL
	BEGIN
		RAISERROR('Il parametro IdPaziente non può essere NULL!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Traslo l'IdPaziente nell'attivo/padre
	---------------------------------------------------
	SET @IdPaziente = dbo.GetPazienteRootByPazienteId(@IdPaziente) 

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT
		  IdPaziente		
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
		dbo.PazientiEsenzioniSpResult
	WHERE
		IdPaziente = @IdPaziente
END












GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputEsenzioniByIdPaziente] TO [DataAccessSql]
    AS [dbo];

