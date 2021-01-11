

CREATE PROCEDURE [dbo].[ConsensiBatchAggancioPazienteUpdate] 
	  @Utente AS varchar(64)
	, @IdPaziente uniqueidentifier
	, @PazienteProvenienza varchar(16)
	, @PazienteIdProvenienza varchar(64)
	, @PazienteCodiceFiscale varchar(16)

AS
BEGIN
	SET NOCOUNT ON;

	---------------------------------------------------
	-- Inizio transazione
	---------------------------------------------------

	BEGIN TRAN


	---------------------------------------------------
	-- Dichiaro una variabile tabella che contiene gli Id consenso da notificare
	---------------------------------------------------

	DECLARE @tmp TABLE (IdConsenso uniqueidentifier NOT NULL) 


	---------------------------------------------------
	-- Aggiorna i dati per IdProvenienza
	---------------------------------------------------

	-- Popolo variabile tabella
	INSERT INTO @tmp(IdConsenso)
		SELECT Id 
		FROM Consensi
		WHERE IdPaziente = '00000000-0000-0000-0000-000000000000'
				AND PazienteProvenienza = @PazienteProvenienza
				AND PazienteIdProvenienza = @PazienteIdProvenienza

	-- Update
	UPDATE Consensi
		SET IdPaziente = @IdPaziente		
		WHERE IdPaziente = '00000000-0000-0000-0000-000000000000'
				AND PazienteProvenienza = @PazienteProvenienza
				AND PazienteIdProvenienza = @PazienteIdProvenienza

	IF @@ERROR <> 0 GOTO ERROR_EXIT


	---------------------------------------------------
	-- Aggiorna i dati per CodiceFiscale
	---------------------------------------------------

	-- Popolo variabile tabella
	INSERT INTO @tmp(IdConsenso)
		SELECT Id 
		FROM Consensi
		WHERE IdPaziente = '00000000-0000-0000-0000-000000000000'
				AND PazienteCodiceFiscale = @PazienteCodiceFiscale
				AND (PazienteProvenienza IS NULL AND PazienteIdProvenienza IS NULL)

	-- Update
	UPDATE Consensi
		SET IdPaziente = @IdPaziente		
		WHERE IdPaziente = '00000000-0000-0000-0000-000000000000'
				AND PazienteCodiceFiscale = @PazienteCodiceFiscale
				AND (PazienteProvenienza IS NULL AND PazienteIdProvenienza IS NULL)

	IF @@ERROR <> 0 GOTO ERROR_EXIT

	---------------------------------------------------
	-- Inserisce record di notifica
	---------------------------------------------------
	DECLARE @IdConsenso uniqueidentifier
	DECLARE crsConsensi CURSOR STATIC READ_ONLY FOR	SELECT * FROM @tmp

	BEGIN TRY
		OPEN crsConsensi
		FETCH NEXT FROM crsConsensi INTO @IdConsenso
		WHILE @@FETCH_STATUS = 0
			BEGIN
				exec dbo.ConsensiNotificheAdd @IdConsenso, '0', @Utente

				FETCH NEXT FROM crsConsensi INTO @IdConsenso
			END

		CLOSE crsConsensi
		DEALLOCATE crsConsensi
	END TRY
	BEGIN CATCH
		CLOSE crsConsensi
		DEALLOCATE crsConsensi
	END CATCH


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
    ON OBJECT::[dbo].[ConsensiBatchAggancioPazienteUpdate] TO [DataAccessDll]
    AS [dbo];

