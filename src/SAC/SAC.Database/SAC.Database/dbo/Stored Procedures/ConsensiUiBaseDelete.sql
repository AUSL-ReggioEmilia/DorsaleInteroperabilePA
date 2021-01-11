
-- =============================================
-- Author:		Pichierri
-- Create date: ???
-- Description:	Cancella logicamente un consenso
-- Modify date: 2018-05-08 ETTORE: A seguito della modifica dei consesni del paziente eseguo anche una notifica paziente di tipo 8
--									Aggiunto gestione degli errori con TRY CATCH			
-- =============================================
CREATE PROCEDURE [dbo].[ConsensiUiBaseDelete]
(
	  @Id AS UNIQUEIDENTIFIER
	, @Utente AS VARCHAR(64)
)
AS
BEGIN
	DECLARE @IdPaziente UNIQUEIDENTIFIER

	BEGIN TRANSACTION
	BEGIN TRY
		-------------------------------------------------------------------
		-- Elimina il consenso
		-------------------------------------------------------------------
		UPDATE Consensi 
			SET Disattivato = 1
				, DataDisattivazione = GetDate() 
		WHERE Id = @Id

		---------------------------------------------------
		-- Inserisce record di notifica
		---------------------------------------------------
		EXEC ConsensiNotificheAdd @Id, '1', @Utente

		---------------------------------------------------
		-- MODIFICA ETTORE 2018-05-08: Inserisce record di notifica del paziente
		---------------------------------------------------
		--
		-- Ricavo l'Id del paziente da consenso
		--
		SELECT @IdPaziente = IdPaziente FROM Consensi WHERE Id =  @Id

		IF NOT @IdPaziente IS NULL 
		BEGIN 
			--Mi assicuro che sia il paziente attivo
			SELECT @IdPaziente = [dbo].[GetPazienteRootByPazienteId] (@IdPaziente)
			--Eseguo la notifica
			EXEC [dbo].[PazientiNotificheAdd] @IdPaziente , 8, @Utente 
		END
		ELSE
		BEGIN
			DECLARE @MsgErr AS VARCHAR(200) = 'Impossibile ricavare l''idpaziente associato al consenso!'
			RAISERROR(@MsgErr, 16, 1)
		END 

		---------------------------------------------------
		-- Completato
		---------------------------------------------------
		COMMIT

		RETURN 0

	END TRY
	BEGIN CATCH
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		  
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'ConsensiUiBaseDelete. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)

		RETURN 1
	END CATCH 

ROLLBACK_EXIT:

	---------------------------------------------------
	--     Error
	---------------------------------------------------

	ROLLBACK
	RETURN 1

END









GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiUiBaseDelete] TO [DataAccessUi]
    AS [dbo];

