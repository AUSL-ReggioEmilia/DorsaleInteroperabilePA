
CREATE PROCEDURE [dbo].[PazientiUiEsenzioniDelete]
	  @Id AS uniqueidentifier
	, @Ts AS timestamp
	, @Utente AS varchar(64)
AS
BEGIN

DECLARE @LivelloAttendibilitaCorrente AS tinyint
DECLARE @IdPaziente as uniqueidentifier

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN

	---------------------------------------------------
	-- Controlla livello attendibilita del padre; Aggirna solo se pari o maggiore
	---------------------------------------------------
	
	SELECT @LivelloAttendibilitaCorrente = Pazienti.LivelloAttendibilita
	FROM Pazienti INNER JOIN PazientiEsenzioni
		ON Pazienti.Id = PazientiEsenzioni.IdPaziente
	WHERE PazientiEsenzioni.Id = @Id
	
	IF dbo.ConfigPazientiLivelloAttendibilitaUi() < @LivelloAttendibilitaCorrente
		BEGIN
			RAISERROR('Errore sul controllo del Livello di Attendibilita!', 16, 1)
			RETURN 1001
		END

	---------------------------------------------------
	--  Esegue la cancellazione
	---------------------------------------------------

	DELETE FROM PazientiEsenzioni
	WHERE Id = @Id AND Ts = @Ts

	---------------------------------------------------
	-- Inserisce record di notifica dopo aver recuperato l'ID del paziente
	---------------------------------------------------
	SELECT @IdPaziente = IdPaziente FROM PazientiUiEsenzioniResult
						WHERE Id = @Id

	exec PazientiNotificheAdd @IdPaziente, '1', @Utente


	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Completato
	--  Ritorna i dati inseriti
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
    ON OBJECT::[dbo].[PazientiUiEsenzioniDelete] TO [DataAccessUi]
    AS [dbo];

