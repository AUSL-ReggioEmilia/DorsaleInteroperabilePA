


-- =============================================
-- Author:		Stefano P
-- Create date: 2017-01-04
-- Description:	Cancella i consensi di tipo 1,2,3 del paziente passato
-- Modify date: 2018-05-08 ETTORE: A seguito della cancellazione dei consesni del paziente eseguo anche una notifica paziente di tipo 8
-- Modify date: 2018-06-08 ETTORE: Mi assicuro di notificare il paziente attivo
-- =============================================
CREATE PROCEDURE [pazienti_ws].[ConsensiRimuoviByIdPaziente]
(	
	@UtenteOperazione VARCHAR(128)
   ,@IdPaziente UNIQUEIDENTIFIER  
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MotivoOperazione VARCHAR(1024) = 'Cancellazione invocata da interfaccia DWH User'
	DECLARE @CONSENSI TABLE (Id UNIQUEIDENTIFIER)
	DECLARE @ProcName NVARCHAR(128) = OBJECT_SCHEMA_NAME(@@PROCID) + '.' + OBJECT_NAME(@@PROCID)
		
	BEGIN TRY
		---------------------------------------------------
		-- Controllo accesso
		---------------------------------------------------
		IF dbo.LeggeConsensiPermessiCancellazione(@UtenteOperazione) = 0
		BEGIN
			EXEC dbo.ConsensiEventiAccessoNegato @UtenteOperazione, 0, @ProcName, 'Utente non ha i permessi di cancellazione!'			
			RAISERROR('Errore di controllo accessi!', 16, 1)
			RETURN
		END
		
		--
		-- SELEZIONO I CONSENSI DA ELIMINARE
		--
		INSERT INTO @CONSENSI (Id)
		SELECT	ID 
		FROM	dbo.ConsensiPazienti
		WHERE 	IdPaziente = @IdPaziente
				AND IdTipo IN (1,2,3)	--Solo consensi DWH: GENERICO, DOSSIER, STORICO	

		IF @@ROWCOUNT = 0 BEGIN
			PRINT 'NESSUN CONSENSO DA ELIMINARE'
			RETURN
		END

		BEGIN TRANSACTION	
	
		--
		-- SALVO I CONSENSI CHE STO PER CANCELLARE NELLA TABELLA ConsensiLog
		--
		INSERT INTO dbo.ConsensiLog
			( DataOperazione, UtenteOperazione, MotivoOperazione, DataInserimento
			, DataDisattivazione, Disattivato, Provenienza, IdProvenienza
			, IdPaziente, IdTipo, DataStato, Stato, OperatoreId
			, OperatoreCognome, OperatoreNome, OperatoreComputer
			, PazienteProvenienza, PazienteIdProvenienza
			, PazienteCognome, PazienteNome, PazienteCodiceFiscale, PazienteDataNascita
			, PazienteComuneNascitaCodice, PazienteNazionalitaCodice, PazienteTessera, MetodoAssociazione)
	
		SELECT 
			  GETDATE(), @UtenteOperazione, @MotivoOperazione, DataInserimento
			, DataDisattivazione, Disattivato, Provenienza, IdProvenienza
			--Se IdPazienteFuso è valorizzato uso IdPazienteFuso altrimenti IdPaziente
			, ISNULL(IdPazienteFuso, IdPaziente), IdTipo, DataStato, Stato, OperatoreId
			, OperatoreCognome, OperatoreNome, OperatoreComputer
			, PazienteProvenienza, PazienteIdProvenienza
			, PazienteCognome, PazienteNome, PazienteCodiceFiscale, PazienteDataNascita
			, PazienteComuneNascitaCodice, PazienteNazionalitaCodice, PazienteTessera, MetodoAssociazione
		FROM 
			dbo.ConsensiPazienti
		INNER JOIN 
			@CONSENSI CON ON ConsensiPazienti.ID = CON.ID
			
		--
		-- CANCELLAZIONE
		--
		DELETE FROM dbo.ConsensiNotificheUtenti 
		WHERE IdConsensiNotifica IN (
			SELECT Id FROM dbo.ConsensiNotifiche 
			WHERE IdConsenso IN (
				SELECT Id FROM @CONSENSI
			)
		)
		
		DELETE FROM dbo.ConsensiNotifiche 
		WHERE IdConsenso IN (
			SELECT Id FROM @CONSENSI
		)
		
		DELETE FROM dbo.Consensi 
		WHERE Id IN (
			SELECT Id FROM @CONSENSI
		)

		---------------------------------------------------
		-- MODIFICA ETTORE 2018-05-08: Inserisce record di notifica del paziente
		---------------------------------------------------
		--Mi assicuro che sia il paziente attivo
		SELECT @IdPaziente = [dbo].[GetPazienteRootByPazienteId] (@IdPaziente)
		EXEC [dbo].[PazientiNotificheAdd] @IdPaziente , 8, @UtenteOperazione 
		
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
		EXEC dbo.ConsensiEventiAvvertimento @UtenteOperazione, 0, @ProcName, @msg
		-- PASSO FUORI L'ECCEZIONE
		;THROW;


	END CATCH
END