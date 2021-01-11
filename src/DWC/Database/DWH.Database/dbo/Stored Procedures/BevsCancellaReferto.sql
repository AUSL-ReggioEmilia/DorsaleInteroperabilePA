
-- =============================================
-- Author:		Stefano P.
-- Create date: 2016-10-07
-- Description:	Cancellazione referto; Copia di [_Util_CancellaReferto]
-- Modify date: 2018-01-09: Notifica sia nella coda standard che nella coda Sole
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- Modify date: 2019-01-21 - SANDRO - Usa nuovo SP SOLE ([sole].[CodaRefertiAggiungi])
-- =============================================
CREATE PROCEDURE [dbo].[BevsCancellaReferto]
(
	 @Id UNIQUEIDENTIFIER -- <= IdRefertiBase
	,@Esito INT OUTPUT --0: NESSUN ERRORE   1:REFERTO NON ELIMINABILE   2:ECCEZIONE
)
AS
BEGIN	
	DECLARE @IdEsterno			VARCHAR(64)
	DECLARE @DataPartizione		SMALLDATETIME
	DECLARE @AziendaErogante	VARCHAR(16)
	DECLARE @SistemaErogante	VARCHAR(16)
	DECLARE @OperazioneLog		smallint
	DECLARE @IdCorrelazione		VARCHAR(64)
	DECLARE @TimeoutCorrelazione INT
	DECLARE @CancellazioneAbilitata INT
	DECLARE @IdPaziente			UNIQUEIDENTIFIER
	DECLARE @StatoRichiestaCodice TINYINT

	SET NOCOUNT ON;
	BEGIN TRANSACTION 
	BEGIN TRY
			
		SELECT 
			 @IdEsterno = IdEsterno 
			,@DataPartizione = DataPartizione
		FROM store.RefertiBase
		WHERE ID=@Id

		--
		-- FUNZIONE PER DETERMINARE SE IL REFERTO È CANCELLABILE
		--
		SELECT @CancellazioneAbilitata = dbo.GetRefertiCancellabile2(@IdEsterno,  @Id, @DataPartizione)
		IF @CancellazioneAbilitata > 0 
		BEGIN 
			SELECT @AziendaErogante = AziendaErogante
				 , @SistemaErogante = SistemaErogante
				 , @IdPaziente = IdPaziente
				 , @StatoRichiestaCodice = StatoRichiestaCodice
			FROM store.RefertiBase 
			WHERE	Id = @Id
					AND DataPartizione = @DataPartizione

			PRINT 'BevsCancellaReferto: cancellato il referto con Id: ' + CAST(@Id AS VARCHAR(40))
			SET @Esito = 0

			--
			-- Si notifica solo se è avvenuto l'aggancio paziente
			--
			IF @IdPaziente <> '00000000-0000-0000-0000-000000000000' 
			BEGIN 
				--
				-- Inserimento nella tabella di LOG
				--
				SET @OperazioneLog = 2		--log di cancellazione
				--
				-- Valorizzo l'Id e timeout di correlazione
				--
				SELECT @IdCorrelazione = [dbo].[GetCodaRefertiOutputIdCorrelazione] (@AziendaErogante, @SistemaErogante, @IdEsterno)
				SELECT @TimeoutCorrelazione = ISNULL([dbo].[GetConfigurazioneInt] ('CodeOutput','TimeoutCorrelazione'), 1)
		
				------------------------------------------------------------------------
				-- Eseguo l'inserimento della notifica nella tabella di coda
				------------------------------------------------------------------------

				DECLARE @Messaggio XML
				SET @Messaggio = dbo.GetRefertoXml2(@Id)

				INSERT INTO CodaRefertiOutput (IdReferto,Operazione, IdCorrelazione, CorrelazioneTimeout, OrdineInvio, Messaggio)
				VALUES(@Id, @OperazioneLog , @IdCorrelazione, @TimeoutCorrelazione
						, dbo.GetCodaRefertiOutputOrdineInvio(@SistemaErogante)
						, @Messaggio)

				PRINT 'BevsCancellaReferto: accodata notifica in CodaRefertiOutput'

				------------------------------------------------------------------------
				-- Eseguo notifica nella coda Sole
				------------------------------------------------------------------------

				DECLARE @MessaggioSole XML
				SET @MessaggioSole = [sole].[OttieneRefertoXml](@Id)

				DECLARE @DataModifica DATETIME = GETDATE()

				EXEC [sole].[CodaRefertiAggiungi] @Id, @OperazioneLog, 'Admin', @AziendaErogante
											, @SistemaErogante, @StatoRichiestaCodice
											, @DataModifica, @MessaggioSole
				
				PRINT 'BevsCancellaReferto: accodata notifica in CodaRefertiSole'
			END
			--
			-- Eseguo la cancellazione
			--
			DELETE FROM store.AllegatiAttributi 
			WHERE IdAllegatiBase IN (
					SELECT Id FROM store.AllegatiBase (nolock) WHERE IdRefertiBase = @Id
					)
			
			DELETE FROM store.AllegatiBase 
			WHERE IdRefertiBase = @Id

			DELETE FROM store.PrestazioniAttributi WHERE 
			IdPrestazioniBase IN (
				SELECT Id FROM store.PrestazioniBase (nolock) WHERE IdRefertiBase = @Id
			)

			DELETE FROM store.PrestazioniBase 
			WHERE IdRefertiBase = @Id

			DELETE FROM store.RefertiAttributi
			WHERE  IdRefertiBase = @Id

			DELETE FROM store.RefertiBaseRiferimenti
			WHERE IdRefertiBase = @Id
		
			DELETE FROM store.RefertiBase
			WHERE Id = @Id
			
		END ELSE BEGIN
			SET @Esito = 1
			PRINT 'BevsCancellaReferto: referto non eliminabile con Id: ' + CAST(@Id AS VARCHAR(40))
		END
		--
		-- Commit della transazione
		-- 
		COMMIT		
		
	END TRY		
	BEGIN CATCH
		SET @Esito = 2
		--
		-- Raise dell'errore + ROLLBACK
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		ROLLBACK
		
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BevsCancellaReferto In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;			
		
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsCancellaReferto] TO [ExecuteFrontEnd]
    AS [dbo];

