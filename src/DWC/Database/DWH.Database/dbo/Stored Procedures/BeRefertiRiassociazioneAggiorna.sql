

-- =============================================
-- Author:		
-- Create date: 
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Description:	Esegue l'associazione di un referto ad un paziente SAC e aggiorna gli attributi anagrafici del referto
--				Non si deve notifiare nella CodaRefertiSole: in caso di riaggancio anagrafico si deve contattare SOLE
-- =============================================
CREATE PROCEDURE [dbo].[BeRefertiRiassociazioneAggiorna]
(
 @IdReferto  uniqueidentifier,
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
	
	--DATI LETTI DAL REFERTO
	DECLARE @IdEsternoReferto VARCHAR(64)
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @IdPazienteOld UNIQUEIDENTIFIER
	DECLARE @Datapartizione SMALLDATETIME

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
		END
		
		--RECUPERO IL REFERTO DAL DWH
		SELECT 
			@IdEsternoReferto = IdEsterno
		  , @AziendaErogante = AziendaErogante
		  , @SistemaErogante = SistemaErogante
		  , @IdPazienteOld = IdPaziente
		  , @Datapartizione = DataPartizione
		FROM store.RefertiBase
		WHERE Id = @IdReferto

		IF @@ROWCOUNT = 0 BEGIN
		   RAISERROR('Referto non trovato ', 16, 1)
		END	
		
		-- CALCOLO VALORI CHE SERVONO DOPO
		SELECT @IdCorrelazione = [dbo].[GetCodaRefertiOutputIdCorrelazione] (
							@AziendaErogante, @SistemaErogante, @IdEsternoReferto)
		SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput','TimeoutCorrelazione'), 1)

					
		BEGIN TRANSACTION

		--
		-- UPDATE REFERTO
		--
		UPDATE store.RefertiBase 
			SET IdPaziente = @IdPaziente
		WHERE Id = @IdReferto
	
		--
		-- UPDATE ATTRIBUTI (DELETE E INSERT)
		--	 
		DELETE store.RefertiAttributi  
		WHERE IdRefertiBase = @IdReferto 
		AND Nome IN ('Cognome', 'Nome', 'Sesso', 'DataNascita', 'CodiceFiscale', 'NomeAnagraficaCentrale',
		'CodiceAnagraficaCentrale','CodiceSanitario', 'ComuneNascita', 'ProvinciaNascita', 'IdEsternoPaziente' )

		IF (ISNULL(@Cognome,'') <> '')  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'Cognome', @Cognome, @Datapartizione)
		END
		
		IF (ISNULL(@Nome,'') <> '')  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'Nome', @Nome, @Datapartizione)
		END

		IF (ISNULL(@Sesso,'') <> '')  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'Sesso', @Sesso, @Datapartizione)
		END

		IF (@DataNascita IS NOT NULL)  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'DataNascita', @DataNascita, @Datapartizione)
		END

		IF (ISNULL(@CodiceFiscale,'') <> '')  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'CodiceFiscale', @CodiceFiscale, @Datapartizione)
		END

		IF (ISNULL(@Provenienza,'') <> '')  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'NomeAnagraficaCentrale', @Provenienza, @Datapartizione)
		END

		IF (ISNULL(@IdProvenienza,'') <> '')  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'CodiceAnagraficaCentrale', @IdProvenienza, @Datapartizione)
		END

		IF (ISNULL(@Tessera,'') <> '')  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'CodiceSanitario', @Tessera, @Datapartizione)
		END

		IF (ISNULL(@ComuneNascitaNome,'') <> '' AND @ComuneNascitaCodice <> '000000')  BEGIN
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'ComuneNascita', @ComuneNascitaNome, @Datapartizione)
		END

		IF (ISNULL(@ProvinciaNascitaNome,'') <> '')  BEGIN	
			INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
			VALUES (@IdReferto, 'ProvinciaNascita', @ProvinciaNascitaNome, @Datapartizione)
		END
		
		INSERT INTO store.RefertiAttributi (IdRefertiBase, Nome, Valore, DataPartizione)
		VALUES (@IdReferto, 'IdEsternoPaziente', 'SAC_' + CAST(@IdPaziente AS VARCHAR(36)), @Datapartizione)
		

		--
		-- NOTIFICA DI MODIFICA                       
		--
		SET @OperazioneLog = 1 --1=MODIFICA, 0=INSERIMENTO
		INSERT INTO CodaRefertiOutput 
			( IdReferto,Operazione, IdCorrelazione, 
			  CorrelazioneTimeout, OrdineInvio, Messaggio
			)
		VALUES
			( @IdReferto, @OperazioneLog , @IdCorrelazione , 
			  @TimeoutCorrelazione, dbo.GetCodaRefertiOutputOrdineInvio(@SistemaErogante), 
			  dbo.GetRefertoXml2(@IdReferto)
			)
			

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
    ON OBJECT::[dbo].[BeRefertiRiassociazioneAggiorna] TO [ExecuteFrontEnd]
    AS [dbo];

