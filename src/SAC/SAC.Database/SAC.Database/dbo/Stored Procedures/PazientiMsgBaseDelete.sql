

CREATE PROCEDURE [dbo].[PazientiMsgBaseDelete]
	  @Utente AS varchar(64)
	, @IdProvenienza AS varchar(64)
	, @DataSequenza AS datetime
AS
BEGIN
/*
	MODIFICA ETTORE 2016-05-26: Eliminata la chiamata alla SP EXEC PazientiNotificheAdd @IdPaziente, '0', @Utente
				 				perchè ora viene fatta all'interno della data access
*/

DECLARE @IdPaziente as uniqueidentifier
DECLARE @Provenienza AS varchar(16)
DECLARE @LivelloAttendibilitaCorrente AS tinyint
DECLARE @DataSequenzaCorrente AS datetime
DECLARE @RowCount AS integer

	SET NOCOUNT ON;
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiCancellazione(@Utente) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Utente, 0, 'PazientiDelete', 'Utente non ha i permessi di cancellazione!'

		RAISERROR('Errore di controllo accessi durante [PazientiMsgBaseDelete]!', 16, 1)
		SELECT 1002 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Calcolo provenienza da utente
	---------------------------------------------------

	SET @Provenienza = dbo.LeggePazientiProvenienza(@Utente)
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore di Provenienza non trovata durante [PazientiMsgBaseDelete]!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Calcolo id paziente
	---------------------------------------------------
	SET @IdPaziente = dbo.LeggePazientiId(@Provenienza, @IdProvenienza)
	IF @IdPaziente IS NULL
	BEGIN
		RAISERROR('Id paziente non trovato durante [PazientiMsgBaseDelete]!', 16, 1)
		SELECT 2003 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Controlla livello attendibilita; Aggirna solo se pari o maggiore
	-- Controlla data sequenza; Aggirna solo se maggiore
	---------------------------------------------------
	
	SELECT @LivelloAttendibilitaCorrente = LivelloAttendibilita
		, @DataSequenzaCorrente = DataSequenza
	FROM Pazienti
	WHERE Provenienza = @Provenienza AND IdProvenienza = @IdProvenienza
	
	IF @DataSequenza <= @DataSequenzaCorrente
		BEGIN
			RAISERROR('Errore di controllo di Data di Sequenza durante [PazientiMsgBaseDelete]!', 16, 1)
			SELECT 1003 AS ERROR_CODE
			GOTO ERROR_EXIT
		END

	IF dbo.LeggePazientiLivelloAttendibilita(@Utente) < @LivelloAttendibilitaCorrente
		BEGIN
			RAISERROR('Errore sul controllo del Livello di Attendibilita durante [PazientiMsgBaseDelete]!', 16, 1)
			SELECT 1004 AS ERROR_CODE
			GOTO ERROR_EXIT
		END

	----------------------------------------------------
	-- Cancella il record
	----------------------------------------------------
	
	SET NOCOUNT OFF;

	UPDATE Pazienti
	SET	  Disattivato = 1
		, DataDisattivazione = GETDATE()
	WHERE Provenienza = @Provenienza
		AND IdProvenienza = @IdProvenienza
		AND Disattivato = 0

	SET @RowCount = @@ROWCOUNT

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	SELECT @RowCount AS ROW_COUNT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	RETURN 1

END












GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgBaseDelete] TO [DataAccessDll]
    AS [dbo];

