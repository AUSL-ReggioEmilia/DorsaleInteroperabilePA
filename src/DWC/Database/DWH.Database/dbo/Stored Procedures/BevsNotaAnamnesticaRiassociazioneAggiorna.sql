

CREATE PROCEDURE [dbo].[BevsNotaAnamnesticaRiassociazioneAggiorna]
(
 @IdNotaAnamnestica uniqueidentifier,
 @IdPaziente uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	-- DATI LETTI DA SAC
	DECLARE
	@Nome SQL_VARIANT,
	@Cognome SQL_VARIANT, 
	@Sesso SQL_VARIANT, 
	@DataNascita SQL_VARIANT, 
	@Provenienza SQL_VARIANT,
	@IdProvenienza SQL_VARIANT,	
	@Tessera SQL_VARIANT, 
	@CodiceFiscale SQL_VARIANT,
	@ComuneNascitaNome SQL_VARIANT,
	@ComuneNascitaCodice VARCHAR(6),
	@ProvinciaNascitaNome SQL_VARIANT
	
	-- DATI LETTI DALLA NOTA ANAMNESTICA
	DECLARE @IdEsterno VARCHAR(64)
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @IdPazienteOld UNIQUEIDENTIFIER
	DECLARE @Datapartizione SMALLDATETIME

	BEGIN TRY
		--
		-- RECUPERO IL PAZIENTE DAL SAC  
		--
		SELECT
			  @Nome = Nome
			, @Cognome = Cognome 
			, @Sesso = Sesso
			, @DataNascita = DataNascita 
			, @Provenienza = Provenienza 
			, @IdProvenienza = IdProvenienza 
			, @Tessera = Tessera 	
			, @CodiceFiscale = CodiceFiscale
			, @ComuneNascitaNome = ComuneNascitaNome
			, @ComuneNascitaCodice = ComuneNascitaCodice
			, @ProvinciaNascitaNome = @ProvinciaNascitaNome
		FROM  dbo.Sac_Pazienti  --uso la dbo.SAC_Pazienti perchè in questo modo ho anche le anagrafiche figlie
		WHERE Id = @IdPaziente

		--
		--MOSTRO MESSAGGIO DI ERRORE SE NON TROVO IL PAZIENTE.
		--
		IF @@ROWCOUNT = 0 BEGIN
		   RAISERROR('Paziente non trovato sul SAC ', 16, 1)
		END
		
		--
		--RECUPERO LA NOTA ANAMNESTICA DAL DWH
		--
		SELECT 
			@IdEsterno = IdEsterno
		  , @AziendaErogante = AziendaErogante
		  , @SistemaErogante = SistemaErogante
		  , @IdPazienteOld = IdPaziente
		  , @Datapartizione = DataPartizione
		FROM store.NoteAnamnesticheBase
		WHERE Id = @IdNotaAnamnestica 

		--
		--MOSTRO MESSAGGIO DI ERRORE SE NON TROVO LA NOTA ANAMNESTICA.
		--
		IF @@ROWCOUNT = 0 BEGIN
		   RAISERROR('Nota Anamnestica non trovata', 16, 1)
		END	
					
		BEGIN TRANSACTION

			--
			-- AGGIORNO LA NOTA ANAMNESTICA.
			--
			UPDATE store.NoteAnamnesticheBase 
				SET IdPaziente = @IdPaziente
			WHERE Id = @IdNotaAnamnestica

			----------------------------------------------------------------------------------------------------------------------
			-- CANCELLAZIONE E REINSERIMENTO DEGLI ATTRIBUTI DELLA NOTA ANAMNESTICA                      
			----------------------------------------------------------------------------------------------------------------------

			DELETE store.NoteAnamnesticheAttributi  
			WHERE IdNoteAnamnesticheBase = @IdNotaAnamnestica
			AND Nome IN ('Cognome', 'Nome', 'Sesso', 'DataNascita', 'CodiceFiscale', 'NomeAnagraficaCentrale',
			'CodiceAnagraficaCentrale','CodiceSanitario', 'ComuneNascita', 'ProvinciaNascita', 'IdEsternoPaziente', 'ComuneNascitaCodice' )

			--
			-- REINSERISCO GLI ATTRIBUTI.
			--
			IF (ISNULL(@Cognome,'') <> '')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'Cognome', @Cognome, @Datapartizione)
			END
		
			IF (ISNULL(@Nome,'') <> '')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'Nome', @Nome, @Datapartizione)
			END

			IF (ISNULL(@Sesso,'') <> '')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'Sesso', @Sesso, @Datapartizione)
			END

			IF (@DataNascita IS NOT NULL)  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'DataNascita', @DataNascita, @Datapartizione)
			END

			IF (ISNULL(@CodiceFiscale,'') <> '')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'CodiceFiscale', @CodiceFiscale, @Datapartizione)
			END

			IF (ISNULL(@Provenienza,'') <> '')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'NomeAnagraficaCentrale', @Provenienza, @Datapartizione)
			END

			IF (ISNULL(@IdProvenienza,'') <> '')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'CodiceAnagraficaCentrale', @IdProvenienza, @Datapartizione)
			END

			IF (ISNULL(@Tessera,'') <> '')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'CodiceSanitario', @Tessera, @Datapartizione)
			END

			IF (ISNULL(@ComuneNascitaNome,'') <> '' AND @ComuneNascitaCodice <> '000000')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'ComuneNascita', @ComuneNascitaNome, @Datapartizione)
			END

			IF (ISNULL(@ComuneNascitaCodice,'000000') <> '000000')  BEGIN
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'ComuneNascitaCodice', @ComuneNascitaCodice, @Datapartizione)
			END
			
			IF (ISNULL(@ProvinciaNascitaNome,'') <> '')  BEGIN	
				INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
				VALUES (@IdNotaAnamnestica, 'ProvinciaNascita', @ProvinciaNascitaNome, @Datapartizione)
			END
		
			INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase, Nome, Valore, DataPartizione)
			VALUES (@IdNotaAnamnestica, 'IdEsternoPaziente', 'SAC_' + CAST(@IdPaziente AS VARCHAR(36)), @Datapartizione)

			----------------------------------------------------------------------------------------------------------------------
			-- FINE CANCELLAZIONE E REINSERIMENTO DEGLI ATTRIBUTI DELLA NOTA ANAMNESTICA                      
			----------------------------------------------------------------------------------------------------------------------

		
			----------------------------------------------------------------------------------------------------------------------
			-- NOTIFICA DI MODIFICA                       
			----------------------------------------------------------------------------------------------------------------------

			DECLARE @OperazioneLog INT
			DECLARE @IdCorrelazione VARCHAR(64)
			DECLARE @TimeoutCorrelazione INT

			SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput', 'TimeoutCorrelazione'), 1)
			SET @IdCorrelazione = [dbo].[GetCodaNoteAnamnesticheOutputIdCorrelazione](@AziendaErogante, @SistemaErogante, @IdEsterno)
			SET @OperazioneLog = 1 --1=MODIFICA, 0=INSERIMENTO

			INSERT INTO CodaNoteAnamnesticheOutput (IdNotaAnamnestica,Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
			VALUES(@IdNotaAnamnestica, @OperazioneLog , @IdCorrelazione , @TimeoutCorrelazione, 0 --Per le note anamnestiche non c'è un ordine di priorità.
					,dbo.GetNotaAnamnesticaXml(@IdNotaAnamnestica, @DataPartizione))

			----------------------------------------------------------------------------------------------------------------------
			-- FINE NOTIFICA DI MODIFICA                       
			----------------------------------------------------------------------------------------------------------------------

			--
			-- Comando aggiornamento dell'anteprima per il paziente nuovo e il precedente
			--
			EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPaziente, 0, 0,1
			EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPazienteOld, 0, 0,1

		COMMIT
	
    END TRY     
    BEGIN CATCH
		IF @@TRANCOUNT > 0
		BEGIN
		  ROLLBACK TRANSACTION;
		END
		
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'ERRORE: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;               

	END CATCH

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNotaAnamnesticaRiassociazioneAggiorna] TO [ExecuteFrontEnd]
    AS [dbo];

