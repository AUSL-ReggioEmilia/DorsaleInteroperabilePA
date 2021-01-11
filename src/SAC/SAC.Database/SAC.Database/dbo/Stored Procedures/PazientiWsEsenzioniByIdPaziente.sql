


CREATE PROCEDURE [dbo].[PazientiWsEsenzioniByIdPaziente]
(
	@Identity varchar(64),
	@IdPaziente uniqueidentifier
)
AS
BEGIN
/*
	Modifica Ettore 2014-05-15: 
		Cambiato il nome della vista PazientiEsenzioniOutputResult in PazientiEsenzioniSpResult
		La vista PazientiEsenzioniSpResult restituisce le esenzioni di una catena di fusione associate all'IdPadre/attivo
*/

	SET NOCOUNT ON;
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	--IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	--BEGIN
	--	EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsEsenzioniByIdPaziente', 'Utente non ha i permessi di lettura!'

	--	RAISERROR('Errore di controllo accessi durante PazientiWsEsenzioniByIdPaziente!', 16, 1)
	--	RETURN
	--END
	
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
    ON OBJECT::[dbo].[PazientiWsEsenzioniByIdPaziente] TO [DataAccessWs]
    AS [dbo];

