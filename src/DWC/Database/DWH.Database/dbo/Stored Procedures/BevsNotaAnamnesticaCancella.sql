


-- =============================================
-- Author:		ETTORE
-- Create date: 2017-12-27
-- Description:	CANCELLAZIONE FISICA o ANNULLAMENTO (cancellazione logica) di una nota anamnestica
--				Il parametro @TipoCancellazione decide che tipo di cancellazione eseguire
-- Modify date: 2019-09-04 - ETTORE: spsotata la lettura dell'ZML a seconda del tipo di cancellazione
-- =============================================
CREATE PROCEDURE [dbo].[BevsNotaAnamnesticaCancella]
(
	@Id UNIQUEIDENTIFIER		-- <= IdNotaAnamnestica
	, @DataPartizione SMALLDATETIME		-- <= DataPartizione
	, @TipoCancellazione VARCHAR(16)		--Valori: FINE_VALIDITA, FISICA
)
AS
BEGIN	
	--
	-- Controllo sul parametro @TipoCancellazione
	-- 
	IF NOT (@TipoCancellazione = 'FINE_VALIDITA' OR @TipoCancellazione= 'FISICA') 
	BEGIN 
		RAISERROR('Parametro @TipoCancellazione non valido. Valori possibili: ''FINE_VALIDITA'', ''FISICA''', 16, 1)
		RETURN
	END 

	DECLARE @IdEsterno VARCHAR(64)
	DECLARE @AziendaErogante VARCHAR(16)
	DECLARE @SistemaErogante VARCHAR(16)
	DECLARE @OperazioneLog smallint
	DECLARE @IdCorrelazione VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @XmlNotaAnamnestica xml

	SET NOCOUNT ON;
	BEGIN TRANSACTION 
	BEGIN TRY
			
		SELECT 
			 @IdEsterno = IdEsterno 
			, @AziendaErogante = AziendaErogante
			, @SistemaErogante = SistemaErogante
			, @IdPaziente = IdPaziente
		FROM store.NoteAnamnesticheBase
		WHERE ID=@Id AND DataPartizione = @DataPartizione

		IF @TipoCancellazione = 'FINE_VALIDITA' 
		BEGIN 
			--
			-- Notifica di aggiornamento
			--
			SET @OperazioneLog = 1		--log di UPDATE
		
			UPDATE store.NoteAnamnesticheBase 
				SET --StatoCodice = 3 --Questo significa ANNULLATA 
					DataFineValidita = GETDATE()
			WHERE Id = @Id AND DataPartizione = @DataPartizione

			--	
			-- Leggo xml dopo avere aggiornato la DataFIneValidità per inserirlo nella coda di putput 
			--
			SET @XmlNotaAnamnestica = dbo.GetNotaAnamnesticaXml(@Id, @DataPartizione)

			PRINT 'BevsNotaAnamnesticaCancella: invalidata la nota anamnestica con Id: ' + CAST(@Id AS VARCHAR(40))

		END
		ELSE IF @TipoCancellazione = 'FISICA'
		BEGIN 
			--	
			-- Leggo xml prima di eseguire cancellazione fisica per inserirlo nella coda di putput 
			--
			SET @XmlNotaAnamnestica = dbo.GetNotaAnamnesticaXml(@Id, @DataPartizione)

			--
			-- Notifica di cancellazione
			--
			SET @OperazioneLog = 2
			--
			-- Eseguo la cancellazione FISICA
			--
			DELETE FROM store.NoteAnamnesticheAttributi
			WHERE  IdNoteAnamnesticheBase = @Id AND DataPartizione = @DataPartizione

		
			DELETE FROM store.NoteAnamnesticheBase
			WHERE Id = @Id AND DataPartizione = @DataPartizione
			
			PRINT 'BevsNotaAnamnesticaCancella: cancellata la nota anamnestica con Id: ' + CAST(@Id AS VARCHAR(40))

		END	
		--
		-- Si notifica solo se è avvenuto l'aggancio paziente
		--
		IF @IdPaziente <> '00000000-0000-0000-0000-000000000000' 
		BEGIN 
			--
			-- Inserimento nella tabella di LOG
			--
			--
			-- Valorizzo l'Id di correlazione
			--
			SELECT @IdCorrelazione = [dbo].[GetCodaNoteAnamnesticheOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante, @IdEsterno)
			--
			-- Valorizzo il timeout di correlazione
			--
			SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput','TimeoutCorrelazione'), 1)
		
			--
			-- Eseguo l'inserimento della notifica nella tabella di coda
			--
			INSERT INTO CodaNoteAnamnesticheOutput (IdNotaAnamnestica, Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
			VALUES(@Id, @Operazionelog , @IdCorrelazione, @TimeoutCorrelazione, 0, @XmlNotaAnamnestica)

			--
			-- Fine inserimento nella tabella di LOG
			--
			PRINT 'BevsNotaAnamnesticaCancella: accodata notifica in CodaNoteAnamensticheOutput'

			--
			-- Imposto il ricalcolo dell'anteprima per le note anamnestiche
			--
			EXEC CorePazientiAnteprimaSetCalcolaAnteprima @IdPaziente, 0, 0, 1
		END
		--
		-- COMMIT
		--
		COMMIT		
		
	END TRY		
	BEGIN CATCH
		--
		-- Raise dell'errore + ROLLBACK
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		ROLLBACK
		
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsNotaAnamnesticaCancella In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;			
		
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNotaAnamnesticaCancella] TO [ExecuteFrontEnd]
    AS [dbo];

