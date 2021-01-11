

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-14:
-- Description:	Scrive negli attributi Persistente-Visualizzazioni-[Utente] e Persistente-Visualizzazioni-[Utente]-[Ver]
--				Verifica che il referto possa essere "visto" in base al token 
--				NON verifico se il token può accedere al referto!
-- =============================================
CREATE PROCEDURE [ws3].[RefertoIncrementaVisionatoById]
(
  @IdToken UNIQUEIDENTIFIER
, @IdReferti  uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON
	DECLARE @UtenteProcesso VARCHAR(64)
	DECLARE @DataPartizione SMALLDATETIME
	DECLARE @NomeAttributo_Visualizzazioni VARCHAR(64)
	DECLARE @NomeAttributo_Visualizzazioni_Ver VARCHAR(64) 

	--
	-- Ricavo l'Id del ruolo Role Manager associato al token e l'utente del processo
	--
	SELECT 
		@UtenteProcesso  = UtenteProcesso --Utente dell'apppool o l'utente che si è autenticato al WS3
	FROM 
		dbo.Tokens 
	WHERE Id = @IdToken

	--
	-- Eseguo SELECT per trovare la data partizione del referto e poi eseguo l'inserimento dell'attributo
	--
	SELECT @DataPartizione = DataPartizione FROM store.RefertiBase WHERE Id = @IdReferti 

	--*******************************************************
	-- Valorizzo gli attributi $@Visualizzazioni@[Utente] e $@Visualizzazioni@[Utente]@[Ver]
	--*******************************************************
	BEGIN TRANSACTION
	BEGIN TRY
		SET @NomeAttributo_Visualizzazioni = [dbo].[NomeAttributoPersistenteVisionato](@UtenteProcesso, NULL)
		--
		-- Se esiste l'attributo Persistente-Visualizzazioni-[Utente] lo incrememto altrimenti lo inserisco
		-- Per ora non uso transazioni
		--
		UPDATE store.RefertiAttributi 
			SET Valore = CAST(Valore AS INTEGER) + 1
		WHERE IdRefertiBase = @IdReferti 
			AND Nome = @NomeAttributo_Visualizzazioni 
			AND DataPartizione = @DataPartizione 
		OPTION(RECOMPILE)

		IF @@ROWCOUNT = 0
		BEGIN 
			--
			-- Eseguo inserimento attributo Persistente-Visualizzazioni-[Utente]
			--
			INSERT INTO store.RefertiAttributi(IdRefertiBase,Nome,Valore,DataPartizione)
			VALUES(@IdReferti, @NomeAttributo_Visualizzazioni, CAST(1 AS INTEGER),@DataPartizione )
		END 

		--
		-- Cerco l'attributo Persistente-NumeroVersione
		--
		DECLARE @NumeroVersione INTEGER
		SELECT 
			@NumeroVersione = CAST(Valore AS INTEGER) 
		FROM store.RefertiAttributi
		WHERE IdRefertiBase = @IdReferti AND nome = '$@NumeroVersione'

		--
		-- 
		--
		IF NOT @NumeroVersione IS NULL
		BEGIN 
			--
			-- Se esiste l'attributo Persistente-Visualizzazioni-[Utente]-Ver lo incrememto altrimenti lo inserisco
			-- Per ora non uso transazioni
			--
			SET @NomeAttributo_Visualizzazioni_Ver = [dbo].[NomeAttributoPersistenteVisionato](@UtenteProcesso, @NumeroVersione )
			UPDATE store.RefertiAttributi 
				SET Valore = CAST(Valore AS INTEGER) + 1
			WHERE IdRefertiBase = @IdReferti 
				AND Nome = @NomeAttributo_Visualizzazioni_Ver 
				AND DataPartizione = @DataPartizione 
			OPTION(RECOMPILE)

			IF @@ROWCOUNT = 0
			BEGIN 
				--
				-- Eseguo inserimento attributo Persistente-Visualizzazioni-[Utente]-[Ver]
				--
				INSERT INTO store.RefertiAttributi(IdRefertiBase,Nome,Valore,DataPartizione)
				VALUES(@IdReferti, @NomeAttributo_Visualizzazioni_Ver, CAST(1 AS INTEGER),@DataPartizione )
			END 
		END
		--
		-- COMMIT
		--
		COMMIT
	END TRY
	BEGIN CATCH
		--
		-- ROLLBACK DELLE MODIFICHE
		--
		IF @@TRANCOUNT > 0 
			ROLLBACK
		--
		-- RAISE DELL'ERRORE
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'ws3.RefertoIncrementaVisionatoById. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;		
	END CATCH

END