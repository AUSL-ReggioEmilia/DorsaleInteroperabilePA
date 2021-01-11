

CREATE PROCEDURE [dbo].[PazientiUiEsenzioniInsert]
	( @IdPaziente uniqueidentifier
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

DECLARE @DataInserimento AS datetime
DECLARE @Id AS uniqueidentifier

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Inserisce record
	---------------------------------------------------

	SET @DataInserimento = GetDate()
	SET @Id = NewId()
	
	INSERT INTO PazientiEsenzioni
		( Id
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
		)
	VALUES
		( @Id
		, @IdPaziente
		, @DataInserimento
		, @DataInserimento	--DataModifica

		, @CodiceEsenzione
		, @CodiceDiagnosi
		, @Patologica
		, @DataInizioValidita
		, @DataFineValidita
		, @NumeroAutorizzazioneEsenzione
		, @NoteAggiuntive
		, @CodiceTestoEsenzione
		, @TestoEsenzione
		, @DecodificaEsenzioneDiagnosi
		, @AttributoEsenzioneDiagnosi
		)

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
    ON OBJECT::[dbo].[PazientiUiEsenzioniInsert] TO [DataAccessUi]
    AS [dbo];

