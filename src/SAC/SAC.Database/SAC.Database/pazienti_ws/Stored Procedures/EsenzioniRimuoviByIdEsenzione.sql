

-- =============================================
-- Author:		Simone B
-- Create date: 2018-03-26
-- Description:	Cancella le esenzioni del paziente passato

-- Modify date: 2019-06-26
-- Description: Prima la cancellazione era fisica, adesso è logica
-- =============================================
CREATE PROCEDURE [pazienti_ws].[EsenzioniRimuoviByIdEsenzione]
(	
	@UtenteOperazione VARCHAR(128)
   ,@IdEsenzione UNIQUEIDENTIFIER  
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
		
	BEGIN TRY
		-----------------------------------------------------
		---- Controllo accesso
		-----------------------------------------------------
		IF dbo.LeggeEsenzioniPermessiCancellazione(@UtenteOperazione) = 0
		BEGIN
			EXEC [dbo].[EsenzioniEventiInserisce] @UtenteOperazione, 0,'ACCESSO NEGATO',@ProcName, 'Utente non ha i permessi di cancellazione sulle esenzioni!'
			RAISERROR('Errore di controllo accessi!', 16, 1)
			RETURN
		END
		
		BEGIN TRANSACTION	
		
		--
		--OTTENGO L'ID DEL PAZIENTE
		--
		DECLARE @IdPaziente AS UNIQUEIDENTIFIER
		SELECT @IdPaziente = IdPaziente
		FROM dbo.PazientiEsenzioni
		WHERE Id = @IdEsenzione

		--
		--CANCELLO IL RECORD (Adesso solo cancellazione logica, non più fisica)
		--
		UPDATE dbo.PazientiEsenzioni
		SET DataFineValidita = getdate(),
			OperatoreId = @UtenteOperazione
		WHERE Id = @IdEsenzione

		--
		--RINOTIFICO IL PAZIENTE
		--
		--Mi assicuro che sia il paziente attivo
		SELECT @IdPaziente = [dbo].[GetPazienteRootByPazienteId] (@IdPaziente)
		EXEC dbo.PazientiNotificheAdd @IdPaziente, 9, @UtenteOperazione

		--
		-- COMMIT DELLA TRANSAZIONE
		--
		COMMIT TRANSACTION
			
	END TRY
	BEGIN CATCH
	
		--
		-- ROLLBACK DELLA TRANSAZIONE
		--
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	
		---------------------------------------------------
		--     GESTIONE ERRORI (LOG E PASSO FUORI)
		---------------------------------------------------
		DECLARE @msg NVARCHAR(4000) = ERROR_MESSAGE()    
		
		EXEC [dbo].[EsenzioniEventiInserisce] @UtenteOperazione, 0,'AVVERTIMENTO',@ProcName,@msg
		
		-- PASSO FUORI L'ECCEZIONE
		;THROW;
	END CATCH
END