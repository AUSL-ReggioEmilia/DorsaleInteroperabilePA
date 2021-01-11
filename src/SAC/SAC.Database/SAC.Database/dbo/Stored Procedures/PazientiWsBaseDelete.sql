

-- =============================================
-- Data create: 29/09/2011: Cancellazione logica non rimuoco sinonimi
-- Data modifica: 27/05/2016: review
-- Descrizione	: aggiunto il controllo del parametro @IdProvenienza e @Id
-- Modifica Ettore 2016-12-12: aggiunto controllo per impedire che una anagrafica fusa (Disattivato=2) venga posta nello stato cancellato (Disattivato=1)
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsBaseDelete]
	  @Utente AS varchar(64)
	, @Id uniqueidentifier
	, @Provenienza varchar(16)
	, @IdProvenienza varchar(64)
AS
BEGIN

DECLARE @LivelloAttendibilita AS tinyint
DECLARE @LivelloAttendibilitaCorrente AS tinyint
DECLARE @ErrorMsg_PazienteFuso VARCHAR(1024)
DECLARE @Disattivato tinyint

	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo provenienza da utente
	---------------------------------------------------
	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Errore durante PazientiWsBaseDelete, il campo Provenienza è vuoto!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	IF @IdProvenienza IS NULL AND @Id IS NULL
	BEGIN
		RAISERROR('Errore durante PazientiWsBaseDelete, il campo IdProvenienza ed Id sono entrambi vuoti!', 16, 1)
		SELECT 2001 AS ERROR_CODE
		GOTO ERROR_EXIT
	END

	---------------------------------------------------
	-- Controlla livello attendibilità; Cancella solo se pari o maggiore
	---------------------------------------------------	
	IF @Id IS NULL
	BEGIN

		SELECT @Id = Id, @LivelloAttendibilitaCorrente = LivelloAttendibilita
			, @Disattivato = Disattivato
		FROM Pazienti 
		WHERE Provenienza = @Provenienza AND IdProvenienza = @IdProvenienza

		IF @Disattivato = 2 
		BEGIN
			SET @ErrorMsg_PazienteFuso = 'L''anagrafica con Provenienza=' + @Provenienza + ' e IdProvenienza=' + @IdProvenienza + ' è fusa e non può essere cancellata.' 
			RAISERROR(@ErrorMsg_PazienteFuso , 16, 1)
			RETURN
		END

	END	ELSE BEGIN

		SELECT @IdProvenienza = IdProvenienza, @LivelloAttendibilitaCorrente = LivelloAttendibilita
			, @Disattivato = Disattivato
		FROM Pazienti 
		WHERE Id = @Id

		IF @Disattivato = 2 
		BEGIN
			SET @ErrorMsg_PazienteFuso = 'L''anagrafica con Id =' + CAST(@Id AS VARCHAR(40))+ ' è fusa e non può essere cancellata.' 
			RAISERROR(@ErrorMsg_PazienteFuso , 16, 1)
			RETURN
		END

	END
	
	SET @LivelloAttendibilita = dbo.LeggePazientiLivelloAttendibilita(@Utente)

	IF @LivelloAttendibilita < @LivelloAttendibilitaCorrente
	BEGIN
		RAISERROR('Errore sul controllo del Livello di Attendibilita!', 16, 1)
		RETURN 1001
	END


	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN	

	-- Aggiorno paziente se non già disabilitato
	UPDATE Pazienti
	SET DataModifica = GETDATE(), Disattivato = 1, DataDisattivazione = GETDATE()
	WHERE Id = @Id
		AND Disattivato <> 1

	IF @@ERROR <> 0 GOTO ERROR_EXIT
		
	COMMIT
	RETURN 0

ERROR_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------
	EXEC dbo.PazientiEventiAvvertimento @Utente, 0, 'PazientiWsBaseDelete', 'Errore durante la cancellazione'

	IF @@TRANCOUNT > 0 ROLLBACK
	RETURN 1
END



























GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsBaseDelete] TO [DataAccessWs]
    AS [dbo];

