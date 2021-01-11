


CREATE PROCEDURE [dbo].[PazientiMsgBaseMerge]
	  @IdPaziente uniqueidentifier
	, @IdPazienteFuso uniqueidentifier
	, @Provenienza AS varchar(16)
	, @IdProvenienzaPazienteFuso varchar(64)
	, @Motivo tinyint
	, @Note as text
	, @Utente AS varchar(64)
	, @ControlloFasciaOraria bit

AS
BEGIN
/*
	MODIFICA ETTORE 2016-05-26: Eliminata la chiamata alla SP EXEC PazientiNotificheAdd @IdPazienteFuso, '0', @Utente
				 				perchè ora viene fatta all'interno della data access
*/

DECLARE @Id AS uniqueidentifier
DECLARE @DataInserimento AS datetime

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo fascia orara
	---------------------------------------------------
	IF @ControlloFasciaOraria = 1 AND dbo.GetPermessoFusioneByFasciaOraria() = 0
	BEGIN
		SELECT 1 AS ROW_COUNT
        RETURN 0
	END
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiScrittura(@Utente) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Utente, 0, 'PazientiMsgBaseMerge', 'Utente non ha i permessi di scrittura!'

		RAISERROR('Errore di controllo accessi durante [PazientiMsgBaseMerge]!', 16, 1)
		SELECT 1002 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	IF @Provenienza IS NULL
	BEGIN
		SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
		IF @Provenienza IS NULL
		BEGIN
			RAISERROR('Errore di Provenienza non trovata durante [PazientiMsgBaseMerge]!', 16, 1)
			SELECT 2001 AS ERROR_CODE
			GOTO ERROR_EXIT
		END
	END

	---------------------------------------------------
	-- Cerco Id del paziente fuso
	---------------------------------------------------

	IF @IdPazienteFuso IS NULL
	BEGIN
		SET @IdPazienteFuso = dbo.GetPazienteIdByProvenienza(@Provenienza, @IdProvenienzaPazienteFuso)
		IF @IdPazienteFuso IS NULL
		BEGIN
			RAISERROR('Errore di Paziente non trovato durante [PazientiMsgBaseMerge]!', 16, 1)
			SELECT 2002 AS ERROR_CODE
			GOTO ERROR_EXIT
		END
	END
	
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
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	SET @DataInserimento = GetDate()
	SET @Id = NewId()

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
		, @Motivo
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
			, @Motivo
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
		, @IdProvenienzaPazienteFuso
		, @DataInserimento
		, @Motivo
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
			, @Motivo
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
		--, DataSequenza = GetDate()
		, Disattivato = 2
		, DataDisattivazione = GetDate()
		
	WHERE Id = @IdPazienteFuso

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	SELECT 1 AS ROW_COUNT
	COMMIT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	SELECT 0 AS ROW_COUNT
	ROLLBACK
	RETURN 1

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgBaseMerge] TO [DataAccessDll]
    AS [dbo];

