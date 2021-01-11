



-- =============================================
-- Author:		ETTORE
-- Create date: 2018-10-26
-- Description:	Gestione dell'oscuramento per IdPaziente
--				Poichè inserire in PazientiCancellati equivaleva a non mostrare nulla di quel paziente
--				passando alla nuova tabella OscuramentiPaziente bisogna popolare il record di tale tabella
--				con tutti flag (che si riferiscono agli oggetti del database) valorizzati a 1
--
--				Restituisco il paziente cancellato cosi che il designere non crei un QueryTableAdapter
--				ma un table adapter standard
--
-- =============================================
CREATE PROCEDURE [frontend].[CancellazionePazienteAggiungi2]
(
	@IdPazientiBase	uniqueidentifier	--il paziente da oscurare
	, @Utente AS VARCHAR(64)			--l'utente che esegue l'inserimento
)
AS
SET NOCOUNT ON
DECLARE @Inserimento BIT = 0
BEGIN TRANSACTION
	BEGIN TRY
		---------------------------------------------------------------------------------
		-- Inserimento in PazientiCancellati (a regime sarà da eliminare!)
		---------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT * FROM PazientiCancellati WHERE IdPazientiBase = @IdPazientiBase)
		BEGIN
			INSERT INTO PazientiCancellati(Id, IdPazientiBase, DataCancellazione) 
			VALUES
				(NEWID(), @IdPazientiBase, GETDATE())
			
			SET @Inserimento = 1
		END
		---------------------------------------------------------------------------------
		-- Inserimento in OscuramentiPaziente
		---------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT * FROM OscuramentiPazienti WHERE IdPaziente = @IdPazientiBase)
		BEGIN
			INSERT INTO dbo.OscuramentiPazienti(IdPaziente, DataModifica, UtenteModifica, OscuraReferti, OscuraRicoveri, OscuraPrescrizioni, OscuraNoteAnamnestiche)
			VALUES (@IdPazientiBase, GETDATE(), @Utente, 1,1,1,1) 
			
			SET @Inserimento = 1
		END
		ELSE
		BEGIN
			--Se già esiste l'IdPaziente imposto tutti i flag a 1
			UPDATE dbo.OscuramentiPazienti
				SET OscuraReferti = 1
				, OscuraRicoveri = 1
				, OscuraPrescrizioni = 1
				, OscuraNoteAnamnestiche = 1
			WHERE IdPaziente = @IdPazientiBase
		END
		--
		-- COMMIT
		--
		COMMIT
		--
		-- Restituisco il paziente se ho fatto almeno un inserimento
		--
		IF @Inserimento = 1 
		BEGIN
			SELECT @IdPazientiBase AS IdPazientiBase
		END 

	END TRY
	BEGIN CATCH
		--
		-- ROLLBACK
		--
		IF @@TRANCOUNT > 0 
			ROLLBACK
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'[frontend].[CancellazionePazienteAggiungi2]. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
	END CATCH