
-- =============================================
-- Author:		Stefano P
-- Create date: 2016-12-28
-- Description:	Disabilita un record di dbo.Pazienti
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteRimuovi]
	  @Utente AS varchar(64)
	, @Id uniqueidentifier
	, @Provenienza varchar(16)
	, @IdProvenienza varchar(64)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LivelloAttendibilita AS tinyint
	DECLARE @LivelloAttendibilitaCorrente AS tinyint
	DECLARE @ErrorMsg VARCHAR(1024)
	DECLARE @Error INT = 0
	DECLARE @Disattivato tinyint
	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
		
BEGIN TRY

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------
	IF dbo.LeggePazientiPermessiCancellazione(@Utente) = 0
	BEGIN
		EXEC dbo.PazientiEventiAccessoNegato @Utente, 0, @ProcName, 'Utente non ha i permessi di cancellazione!'
		SET @ErrorMsg = 'Errore di controllo accessi in ' + @ProcName
		RAISERROR(@ErrorMsg, 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Controllo provenienza da utente
	---------------------------------------------------
	IF @Provenienza IS NULL
	BEGIN
		SET @ErrorMsg = 'Il campo Provenienza è vuoto!'
		RAISERROR(@ErrorMsg, 16, 1)
		RETURN
	END

	IF @IdProvenienza IS NULL AND @Id IS NULL
	BEGIN
		SET @ErrorMsg = 'Il campo IdProvenienza ed Id sono entrambi vuoti!'
		RAISERROR(@ErrorMsg, 16, 1)
		RETURN
	END

	---------------------------------------------------
	-- Controlla livello attendibilità; Cancella solo se pari o maggiore
	---------------------------------------------------	
	IF @Id IS NULL
	BEGIN
		--
		--	PASSAGGIO DI PROVENIENZA+IDPROVENIENZA
		--
		IF NOT EXISTS (SELECT 1
				FROM dbo.Pazienti 
				WHERE Provenienza = @Provenienza 
				AND IdProvenienza = @IdProvenienza)
		BEGIN
			SET @ErrorMsg = 'Errore Paziente non trovato!'
			RAISERROR(@ErrorMsg, 16, 1)
			RETURN
		END

		
		SELECT @Id = Id, @LivelloAttendibilitaCorrente = LivelloAttendibilita
			, @Disattivato = Disattivato
		FROM dbo.Pazienti 
		WHERE Provenienza = @Provenienza 
			AND IdProvenienza = @IdProvenienza
			AND Disattivato = 0

		IF @Id IS NULL BEGIN
			--
			-- SE CI SONO SOLO RIGHE IN STATO DISATTIVATO=2 LO SEGNALO ED ESCO
			--
			IF EXISTS (SELECT 1
				FROM dbo.Pazienti 
				WHERE Provenienza = @Provenienza 
				AND IdProvenienza = @IdProvenienza
				AND Disattivato = 2
			)			
			BEGIN
				SET @ErrorMsg = 'L''anagrafica con Provenienza=' + @Provenienza + ' e IdProvenienza=' + @IdProvenienza + ' è fusa e non può essere cancellata.' 
				RAISERROR(@ErrorMsg, 16, 1)
				RETURN
			END
		END

	END	ELSE BEGIN
		--
		--	PASSAGGIO DI ID PAZIENTE
		--
		SELECT @IdProvenienza = IdProvenienza, @LivelloAttendibilitaCorrente = LivelloAttendibilita
			, @Disattivato = Disattivato
		FROM dbo.Pazienti 
		WHERE Id = @Id

		IF @IdProvenienza IS NULL
		BEGIN
			SET @ErrorMsg = 'Errore Paziente non trovato!'
			RAISERROR(@ErrorMsg, 16, 1)
			RETURN
		END
		
		IF @Disattivato = 2 
		BEGIN
			SET @ErrorMsg = 'L''anagrafica con Id =' + CAST(@Id AS VARCHAR(40))+ ' è fusa e non può essere cancellata.' 
			RAISERROR(@ErrorMsg, 16, 1)
			RETURN
		END

	END
	
	SET @LivelloAttendibilita = dbo.LeggePazientiLivelloAttendibilita(@Utente)

	IF @LivelloAttendibilita < @LivelloAttendibilitaCorrente
	BEGIN
		SET @ErrorMsg = 'Errore sul controllo del Livello di Attendibilità!'
		RAISERROR(@ErrorMsg, 16, 1)
		RETURN
	END
	

	-- AGGIORNO PAZIENTE SE NON GIÀ DISABILITATO
	UPDATE 
		dbo.Pazienti
	SET	DataModifica = GETDATE()
		, Disattivato = 1
		, DataDisattivazione = GETDATE()
	WHERE Id = @Id
		AND Disattivato = 0
		
		
END TRY
BEGIN CATCH

	---------------------------------------------------
	--     GESTIONE ERRORI (LOG E PASSO FUORI)
	---------------------------------------------------
    DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE()    
	EXEC dbo.PazientiEventiAvvertimento @Utente, 0, @ProcName, @msg
	-- PASSO FUORI L'ECCEZIONE
	;THROW;

END CATCH

END