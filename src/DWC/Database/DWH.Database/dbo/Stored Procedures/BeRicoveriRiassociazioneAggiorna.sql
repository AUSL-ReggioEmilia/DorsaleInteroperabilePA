


-- =============================================
-- Author:	Simone Bitti	
-- Create date:  28-05-2019
-- Description:	Esegue l'associazione di un ricovero ad un paziente e si occupa della rinotifica del ricovero modificato
-- =============================================
CREATE PROCEDURE [dbo].[BeRicoveriRiassociazioneAggiorna]
(
 @IdRicovero  uniqueidentifier,
 @IdPaziente uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @DateStart AS DATETIME = GETUTCDATE()

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
	
	--DATI LETTI DAL RICOVERO
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @NumeroNosologico VARCHAR(16)
	DECLARE @IdPazienteOld UNIQUEIDENTIFIER
	DECLARE @Datapartizione SMALLDATETIME
	DECLARE @IdEsternoRicovero VARCHAR(64)

	DECLARE @OperazioneLog INT
	DECLARE @IdCorrelazione VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT

	BEGIN TRY
	
		-- RECUPERO IL PAZIENTE DAL SAC  
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

		IF @@ROWCOUNT = 0 BEGIN
		   RAISERROR('Paziente non trovato sul SAC ', 16, 1)
		   RETURN
		END
		
		--RECUPERO IL RICOVERO DAL DWH
		SELECT 
		   @AziendaErogante = AziendaErogante
		  , @SistemaErogante = SistemaErogante
		  , @NumeroNosologico = NumeroNosologico 
		  , @IdPazienteOld = IdPaziente
		  , @Datapartizione = DataPartizione
		  , @IdEsternoRicovero = IdEsterno
		FROM store.RicoveriBase
		WHERE Id = @IdRicovero

		IF @@ROWCOUNT = 0 BEGIN
		   RAISERROR('Ricovero non trovato ', 16, 1)
		   RETURN 
		END	
		
		-- CALCOLO VALORI CHE SERVONO DOPO
		SELECT @IdCorrelazione = [dbo].[GetCodaEventiOutputIdCorrelazione] (
							@AziendaErogante, @SistemaErogante, @NumeroNosologico)
		SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput','TimeoutCorrelazione'), 1)

					
		BEGIN TRANSACTION

			--
			-- UPDATE RICOVERO
			--
			UPDATE store.RicoveriBase 
				SET IdPaziente = @IdPaziente
			WHERE Id = @IdRicovero
	
			--
			-- UPDATE ATTRIBUTI DEL RICOVERO (DELETE E INSERT)
			--	 
			DELETE store.RicoveriAttributi  
			WHERE IdRicoveriBase = @IdRicovero 
			AND Nome IN ('Cognome', 'Nome', 'Sesso', 'DataNascita', 'CodiceFiscale', 'NomeAnagraficaCentrale',
			'CodiceAnagraficaCentrale','CodiceSanitario', 'ComuneNascita', 'ProvinciaNascita', 'IdEsternoPaziente' )

			IF (ISNULL(@Cognome,'') <> '')  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'Cognome', @Cognome, @Datapartizione)
			END
		
			IF (ISNULL(@Nome,'') <> '')  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'Nome', @Nome, @Datapartizione)
			END

			IF (ISNULL(@Sesso,'') <> '')  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'Sesso', @Sesso, @Datapartizione)
			END

			IF (@DataNascita IS NOT NULL)  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'DataNascita', @DataNascita, @Datapartizione)
			END

			IF (ISNULL(@CodiceFiscale,'') <> '')  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'CodiceFiscale', @CodiceFiscale, @Datapartizione)
			END

			IF (ISNULL(@Provenienza,'') <> '')  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'NomeAnagraficaCentrale', @Provenienza, @Datapartizione)
			END

			IF (ISNULL(@IdProvenienza,'') <> '')  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'CodiceAnagraficaCentrale', @IdProvenienza, @Datapartizione)
			END

			IF (ISNULL(@Tessera,'') <> '')  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'CodiceSanitario', @Tessera, @Datapartizione)
			END

			IF (ISNULL(@ComuneNascitaNome,'') <> '' AND @ComuneNascitaCodice <> '000000')  BEGIN
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'ComuneNascita', @ComuneNascitaNome, @Datapartizione)
			END

			IF (ISNULL(@ProvinciaNascitaNome,'') <> '')  BEGIN	
				INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
				VALUES (@IdRicovero, 'ProvinciaNascita', @ProvinciaNascitaNome, @Datapartizione)
			END
		
			INSERT INTO store.RicoveriAttributi(IdRicoveriBase, Nome, Valore, DataPartizione)
			VALUES (@IdRicovero, 'IdEsternoPaziente', 'SAC_' + CAST(@IdPaziente AS VARCHAR(36)), @Datapartizione)
		
		
			--
			-- UPDATE DEGLI EVENTI DEL RICOVERO E DEI SUOI ATTRIBUTI
			--

			DECLARE @Cur_IdEvento uniqueidentifier

			DECLARE curEventi CURSOR STATIC READ_ONLY FOR	
			SELECT Id
			FROM store.EventiBase
			WHERE AziendaErogante = @AziendaErogante
				AND NumeroNosologico = @NumeroNosologico

			OPEN curEventi
			FETCH NEXT FROM curEventi INTO @Cur_IdEvento
			WHILE (@@fetch_status <> -1)																																																																	WHILE (@@fetch_status <> -1)
				BEGIN
				IF (@@fetch_status <> -2)
					BEGIN
					
						--
						-- UPDATE EVENTO
						--
						UPDATE store.EventiBase 
							SET IdPaziente = @IdPaziente
						WHERE Id = @Cur_IdEvento
	
						--
						-- UPDATE ATTRIBUTI (DELETE E INSERT)
						--	 
						DELETE store.EventiAttributi  
						WHERE IdEventiBase = @Cur_IdEvento 
						AND Nome IN ('Cognome', 'Nome', 'Sesso', 'DataNascita', 'CodiceFiscale', 'NomeAnagraficaCentrale',
						'CodiceAnagraficaCentrale','CodiceSanitario', 'ComuneNascita', 'ProvinciaNascita', 'IdEsternoPaziente' )


						IF (ISNULL(@Cognome,'') <> '')  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'Cognome', @Cognome, @Datapartizione)
						END
		
						IF (ISNULL(@Nome,'') <> '')  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'Nome', @Nome, @Datapartizione)
						END

						IF (ISNULL(@Sesso,'') <> '')  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'Sesso', @Sesso, @Datapartizione)
						END

						IF (@DataNascita IS NOT NULL)  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'DataNascita', @DataNascita, @Datapartizione)
						END

						IF (ISNULL(@CodiceFiscale,'') <> '')  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'CodiceFiscale', @CodiceFiscale, @Datapartizione)
						END

						IF (ISNULL(@Provenienza,'') <> '')  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'NomeAnagraficaCentrale', @Provenienza, @Datapartizione)
						END

						IF (ISNULL(@IdProvenienza,'') <> '')  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'CodiceAnagraficaCentrale', @IdProvenienza, @Datapartizione)
						END

						IF (ISNULL(@Tessera,'') <> '')  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'CodiceSanitario', @Tessera, @Datapartizione)
						END

						IF (ISNULL(@ComuneNascitaNome,'') <> '' AND @ComuneNascitaCodice <> '000000')  BEGIN
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'ComuneNascita', @ComuneNascitaNome, @Datapartizione)
						END

						IF (ISNULL(@ProvinciaNascitaNome,'') <> '')  BEGIN	
							INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
							VALUES (@Cur_IdEvento, 'ProvinciaNascita', @ProvinciaNascitaNome, @Datapartizione)
						END
		
						INSERT INTO store.EventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
						VALUES (@Cur_IdEvento, 'IdEsternoPaziente', 'SAC_' + CAST(@IdPaziente AS VARCHAR(36)), @Datapartizione)

					END

				-- Prossima riga
				FETCH NEXT FROM curEventi INTO @Cur_IdEvento
			END

			-- Fine
			CLOSE curEventi
			DEALLOCATE curEventi

			--ESEGUE LA RINOTIFICA DEGLI EVENTI
			EXECUTE [dbo].[BeRicoveroNotificaEventi] @AziendaErogante, @NumeroNosologico

			--
			-- Comando aggiornamento dell'anteprima per il paziente nuovo e il precedente
			--
			EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPaziente, 1, 0
			EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPazienteOld, 1, 0

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
    ON OBJECT::[dbo].[BeRicoveriRiassociazioneAggiorna] TO [ExecuteFrontEnd]
    AS [dbo];

