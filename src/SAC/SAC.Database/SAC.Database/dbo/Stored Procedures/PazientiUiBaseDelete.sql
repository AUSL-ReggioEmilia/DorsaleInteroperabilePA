
CREATE PROCEDURE [dbo].[PazientiUiBaseDelete]
	  @Id AS uniqueidentifier
	, @Ts AS timestamp
	, @Utente AS varchar(64)
AS
BEGIN

DECLARE @LivelloAttendibilitaCorrente AS tinyint

	---------------------------------------------------
	-- Controlla livello attendibilita; Aggirna solo se pari o maggiore
	---------------------------------------------------
	
	SELECT @LivelloAttendibilitaCorrente = LivelloAttendibilita
	FROM Pazienti
	WHERE Id = @Id
	
	IF dbo.ConfigPazientiLivelloAttendibilitaUi() < @LivelloAttendibilitaCorrente
		BEGIN
			RAISERROR('Errore sul controllo del Livello di Attendibilita!', 16, 1)
			RETURN 1001
		END

	-------------------------------------------------------------------
	-- Cancella i figli
	-------------------------------------------------------------------
	BEGIN TRAN

	Exec PazientiUiEsenzioniDeleteAll @Id

	IF @@ERROR <> 0 GOTO ROLLBACK_EXIT

	-------------------------------------------------------------------
	-- Cancella il record con il controllo della concorrenza (TS)
	-------------------------------------------------------------------
	
	DELETE FROM Pazienti
	WHERE Id = @Id AND Ts = @Ts

	IF @@ERROR <> 0 GOTO ROLLBACK_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	exec PazientiNotificheAdd @Id, '1', @Utente

	IF @@ERROR <> 0 GOTO ROLLBACK_EXIT
	--IF @@ROWCOUNT = 0 GOTO ROLLBACK_EXIT

	---------------------------------------------------
	-- Completato
	---------------------------------------------------

	COMMIT
	RETURN 0

ROLLBACK_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	RETURN 1

END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiUiBaseDelete] TO [DataAccessUi]
    AS [dbo];

