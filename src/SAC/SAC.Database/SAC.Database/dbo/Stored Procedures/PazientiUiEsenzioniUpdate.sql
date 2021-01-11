

CREATE PROCEDURE [dbo].[PazientiUiEsenzioniUpdate]
	( @Id uniqueidentifier
	, @Ts Timestamp
	, @IdPaziente uniqueidentifier
	, @CodiceEsenzione varchar(32)
	, @CodiceDiagnosi varchar(32)
	, @Patologica bit
	, @DataInizioValidita datetime
	, @DataFineValidita datetime
	, @NumeroAutorizzazioneEsenzione varchar(64)
	, @NoteAggiuntive varchar(2048)
	, @CodiceTestoEsenzione varchar(64)
	, @TestoEsenzione varchar(2048)
	, @DecodificaEsenzioneDiagnosi varchar(1024)
	, @AttributoEsenzioneDiagnosi varchar(1024)
	, @Utente AS varchar(64)
	)
AS
BEGIN

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	UPDATE PazientiEsenzioni
	SET   IdPaziente = @IdPaziente
		, DataModifica = GetDate()
		, CodiceEsenzione = @CodiceEsenzione
		, CodiceDiagnosi = @CodiceDiagnosi
		, Patologica = @Patologica
		, DataInizioValidita = @DataInizioValidita
		, DataFineValidita = @DataFineValidita
		, NumeroAutorizzazioneEsenzione = @NumeroAutorizzazioneEsenzione
		, NoteAggiuntive = @NoteAggiuntive
		, CodiceTestoEsenzione = @CodiceTestoEsenzione
		, TestoEsenzione = @TestoEsenzione
		, DecodificaEsenzioneDiagnosi = @DecodificaEsenzioneDiagnosi
		, AttributoEsenzioneDiagnosi = @AttributoEsenzioneDiagnosi

	WHERE Id = @Id AND Ts = @Ts

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @IdPaziente, '1', @Utente


	---------------------------------------------------
	-- Completato
	--  Ritorna i dati inseriti
	---------------------------------------------------

	COMMIT
	
	SELECT *
	FROM PazientiUiEsenzioniResult
	WHERE Id = @Id
	
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	RETURN 1

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiEsenzioniUpdate] TO [DataAccessUi]
    AS [dbo];

