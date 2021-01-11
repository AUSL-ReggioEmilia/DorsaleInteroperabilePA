







-- =============================================
-- Author:		ETTORE
-- Create date: 2020-03-10
-- Description:	Aggiorna l'attributo NumeroNosologico dell'evento DL
--				con il numero nosologico del ricovero associato
--				Usata nella gestione delle liste di attesa di HERO
-- =============================================
CREATE PROCEDURE [dbo].[ExtEventiListaAttesaDLAggiornaAttributoNumeroNosologico]
(	
	@IdEventoA UNIQUEIDENTIFIER				--dati di testata dell'evento A
	, @DataPartizioneA SMALLDATETIME
	, @IdPazienteA UNIQUEIDENTIFIER
	, @AziendaEroganteA VARCHAR(16)
	, @SistemaEroganteA VARCHAR(16)

	--------------------------------------
	, @NumeroNosologicoA VARCHAR(64)			--nosologico dell'evento A
	--------------------------------------
	, @NosologicoPrenotazione VARCHAR(64)	--nosologico della prenotazione
)
AS 
BEGIN
	BEGIN TRANSACTION 
	BEGIN TRY
		--------------------------------------------------------------------------------------------------------
		-- Aggiungo all'evento DL della lista di attesa collegata l'attributo 'NumeroNosologico' con valore @NumeroNosologicoA
		-- uguale a quello del ricovero
		--------------------------------------------------------------------------------------------------------
		DECLARE @IdEventoDL UNIQUEIDENTIFIER
		DECLARE @DataPartizioneEventoDL SMALLDATETIME
		DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		--	
		-- Determino catena di fusione
		--
		SELECT @IdPazienteAttivo = dbo.GetPazienteAttivoByIdSac(@IdPazienteA)
		--
		-- Popolo tabella con tutti gli IdPaziente
		--
		INSERT INTO @TablePazienti(Id)
		SELECT Id FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienteAttivo)
		--	
		-- Dichiaro un range di data partizione
		--
		--DECLARE @DataPartizioneMin SMALLDATETIME = DATEADD(year, -1, @DataPartizioneA)
		--DECLARE @DataPartizioneMax SMALLDATETIME  = DATEADD(year, +1, @DataPartizioneA)

		--
		-- Se in A non viene passato PrericoveroIdCodice devo cancellare l'attributo 'NumeroNosologico' del DL
		-- Cerco nell'evento LA l'attributo 'CodiceListaAttesa' che è valorizzato con il numero nosologico della prenotazione
		-- In questo modo se per un aggiornamento successivo di A il parametro @NosologicoPrenotazione è vuoto lo ricavo dall'LA 
		-- 
		DECLARE @NosologicoPrenotazioneTemp VARCHAR(64)
		SET @NosologicoPrenotazioneTemp = @NosologicoPrenotazione

		--Se @NosologicoPrenotazioneTemp è vuoto cerco nosologico prenotazione in LA
		IF ISNULL(@NosologicoPrenotazioneTemp , '') = ''
		BEGIN 
			-- Cerco LA associato al ricovero per trovare il il Nosologico della Prenotazione
			SELECT TOP 1
				@NosologicoPrenotazioneTemp = CAST(Valore AS VARCHAR(64))
			FROM store.EventiBase AS EB
				INNER JOIN @TablePazienti AS P
					ON P.Id = EB.IdPaziente
				INNER JOIN store.EventiAttributi AS EA
					ON EA.IdEventiBase = EB.Id
			WHERE 
				AziendaErogante = @AziendaEroganteA
				AND SistemaErogante = @SistemaEroganteA 
				AND NumeroNosologico = @NumeroNosologicoA
				AND TipoEventoCodice = 'LA'
				AND EA.Nome = 'CodiceListaAttesa'
				AND EB.DataPartizione = @DataPartizioneA --L'evento LA viene creato con la data partizione di A
				AND EA.DataPartizione = @DataPartizioneA
				--AND EB.DataPartizione BETWEEN @DataPartizioneMin AND @DataPartizioneMax
			OPTION(RECOMPILE) 
		END


		--
		-- Cerco l'evento DL
		--
		SELECT TOP 1
			@IdEventoDL = EB.Id 
			, @DataPartizioneEventoDL = EB.DataPartizione
		FROM store.EventiBase AS EB
			INNER JOIN @TablePazienti AS P
				ON P.Id = EB.IdPaziente
		WHERE 
			AziendaErogante = @AziendaEroganteA
			AND SistemaErogante = @SistemaEroganteA 
			AND NumeroNosologico = @NosologicoPrenotazioneTemp 
			AND TipoEventoCodice = 'DL'
			--AND EB.DataPartizione BETWEEN @DataPartizioneMin AND @DataPartizioneMax
		OPTION(RECOMPILE) 

			
	
		--
		-- Se ho trovato l'evento DL Aggiungo l'attributo 'NumeroNosologico'
		--
		IF NOT @IdEventoDL IS NULL
		BEGIN 
			--
			-- Cancello eventuale record
			--
			DELETE FROM store.EventiAttributi
			WHERE IdEventibase = @IdEventoDL
				--AND DataPartizione IN ( @DataPartizioneEventoDL, @DataPartizioneA)
				AND DataPartizione = @DataPartizioneEventoDL 
				AND Nome = 'NumeroNosologico'
			--
			-- Solo se da A arriva @NosologicoPrenotazione valorizzato devo creare per l'evento DL 
			-- l'attributo 'NumeroNosologico' valorizzato con il numero nosologico dell'evento A (@NumeroNosologicoA)
			--
			IF ISNULL(@NosologicoPrenotazione, '') <> ''
			BEGIN
				--
				-- Inserisco  
				--
				INSERT INTO store.EventiAttributi(IdEventiBase,Nome,Valore,DataPartizione)
				VALUES(@IdEventoDL, 'NumeroNosologico', @NumeroNosologicoA, @DataPartizioneEventoDL)
			END
		
		END 
		--------------------------------------------------------------------------------------------------------
		-- FINE
		--------------------------------------------------------------------------------------------------------
		COMMIT

		RETURN 0
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 
			ROLLBACK
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'ExtEventiListaAttesaDLAggiornaAttributoNumeroNosologico. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		RETURN 1
	END CATCH

END