-- =============================================
-- Author:		Stefano P
-- Create date: 2015-10-29
-- Description:	Cancella i consensi di tipo 1,2,3 del paziente passato
-- Modify date: 2018-05-08 ETTORE: A seguito della cancellazione dei consenso del paziente eseguo anche una notifica paziente di tipo 8
-- Modify date: 2018-06-08 ETTORE: Mi assicuro di notificare il paziente attivo
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiWsDeleteByIdPaziente]
(
  @IdPaziente UNIQUEIDENTIFIER
 ,@UtenteOperazione VARCHAR(128)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @MotivoOperazione VARCHAR(1024) = 'Cancellazione invocata da interfaccia DWH User'
	DECLARE @CONSENSI TABLE (Id UNIQUEIDENTIFIER)

	BEGIN TRANSACTION
	BEGIN TRY
		
		--
		-- SELEZIONO I CONSENSI DA ELIMINARE
		--
		INSERT INTO @CONSENSI (Id)
		SELECT	ID 
		FROM	ConsensiPazienti
		WHERE 	IdPaziente = @IdPaziente
				AND IdTipo IN (1,2,3)	--Solo consensi DWH: GENERICO, DOSSIER, STORICO	
	
		--
		-- SALVO I CONSENSI CHE STO PER CANCELLARE NELLA TABELLA ConsensiLog
		--
		INSERT INTO ConsensiLog
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
			ConsensiPazienti
		INNER JOIN 
			@CONSENSI CON ON ConsensiPazienti.ID = CON.ID
			
		--
		-- CANCELLAZIONE
		--
		DELETE FROM ConsensiNotificheUtenti 
		WHERE IdConsensiNotifica IN (
			SELECT Id FROM ConsensiNotifiche 
			WHERE IdConsenso IN (
				SELECT Id FROM @CONSENSI
			)
		)
		
		DELETE FROM ConsensiNotifiche 
		WHERE IdConsenso IN (
			SELECT Id FROM @CONSENSI
		)
		
		DELETE FROM Consensi 
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
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		

		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'Errore: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		PRINT '---------------------------'
		PRINT @report;						
		PRINT '---------------------------'
	END CATCH
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsDeleteByIdPaziente] TO [DataAccessWs]
    AS [dbo];

