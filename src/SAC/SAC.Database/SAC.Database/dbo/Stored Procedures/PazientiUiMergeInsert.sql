

CREATE PROCEDURE [dbo].[PazientiUiMergeInsert]
	( @IdPaziente uniqueidentifier
	, @IdPazienteFuso uniqueidentifier
	, @Provenienza varchar(16)
	, @IdProvenienza varchar(64)
	, @Note as text
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

	SET @DataInserimento = GetDate()
	SET @Id = NewId()
	
	--
	-- Modifica Ettore: 2012-12-03: controllo che l'id del paziente da fondere non sia già fuso
	--
	DECLARE @Disattivato TINYINT
	SELECT @Disattivato = Disattivato FROM Pazienti WHERE Id = @IdPazienteFuso
	IF @Disattivato = 2 
	BEGIN 
		DECLARE @ErroMsg VARCHAR(200)
		SET @ErroMsg = 'Impossibile eseguire la fusione: il paziente con Id=' + CAST(@IdPazienteFuso AS VARCHAR(40)) + ' è già fuso!'
		RAISERROR(@ErroMsg, 16, 1)
	END

	---------------------------------------------------
	-- Inserisce la fusione
	-- ATTENZIONE: il progressivo fusione non va impostato nella insert, si lascia il default a 0
	---------------------------------------------------
	
	-- nuovo merge
	INSERT INTO PazientiFusioni
		( Id
		, IdPaziente
		, IdPazienteFuso
		, DataInserimento
		, Motivo
		, Note
		)
	VALUES
		( @Id
		, @IdPaziente
		, @IdPazienteFuso
		, @DataInserimento
		, 3
		, @Note
		)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	-- riassocio quelli già esistenti 
	INSERT INTO PazientiFusioni
		( Id
		, IdPaziente
		, IdPazienteFuso
		, DataInserimento
		, Motivo
		, Note
		)
		SELECT NewId()
			, @IdPaziente
			, IdPazienteFuso
			, GetDate()
			, 3
			, @Note
		FROM PazientiFusioni
		WHERE IdPaziente = @IdPazienteFuso 
			AND Abilitato = 1 --(condizione di AND aggiunta il 20/06/2011)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce il sinonimo
	-- ATTENZIONE: il progressivo sinonimo non va impostato nella insert, si lascia il default a 0
	---------------------------------------------------

	-- nuovo merge
	INSERT INTO PazientiSinonimi
		( Id
		, IdPaziente
		, Provenienza
		, IdProvenienza
		, DataInserimento
		, Motivo
		, Note
		)
	VALUES
		( @Id
		, @IdPaziente
		, @Provenienza
		, @IdProvenienza
		, @DataInserimento
		, 3
		, @Note
		)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	-- riassocio quelli già esistenti 
	INSERT INTO PazientiSinonimi
		( Id
		, IdPaziente
		, Provenienza
		, IdProvenienza
		, DataInserimento
		, Motivo
		, Note
		)
		SELECT NewId()
			, @IdPaziente
			, Provenienza
			, IdProvenienza
			, GetDate()
			, 3
			, @Note
		FROM PazientiSinonimi
		WHERE IdPaziente = @IdPazienteFuso 
			AND Abilitato = 1 --(condizione di AND aggiunta il 20/06/2011)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Aggiorno il campo Disattivato della tab. Pazienti
	---------------------------------------------------
	UPDATE Pazienti
	SET   DataModifica = GetDate()
		, DataSequenza = GetDate()
		, Disattivato = 2
		, DataDisattivazione = GetDate()
		
	WHERE Id = @IdPazienteFuso

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	--
	-- Modifica Ettore 2013-03-01: notifico operazione merge da UI Tipo=5
	--
	exec PazientiNotificheAdd @IdPazienteFuso, 5, @Utente
	

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	COMMIT	
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
    ON OBJECT::[dbo].[PazientiUiMergeInsert] TO [DataAccessUi]
    AS [dbo];

