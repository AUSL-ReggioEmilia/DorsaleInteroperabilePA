




-- =============================================
-- Author:		ETTORE
-- Create date: 2020-10-21
-- Description:	Legge dalla coda ara_svc.CodaAnagraficheDaAggiornareInput un record 
--				Salva il record letto nella coda ara_svc.CodaAnagraficheDaAggiornareProcessati
--				Restituisce al servizio il record letto
--				Cancella dalla coda ara_svc.CodaAnagraficheDaAggiornareInput il record letto
-- =============================================
CREATE PROCEDURE [ara_svc].[CodaAnagraficheDaAggiornareOttieni]
AS
BEGIN
/*
		per evitare deadlock è stata impostata una transazione all'interno della SP per utilizzare un
		livello di serializzazione meno forte di quello usato da BizTalk e degli HINT sulla 
		SELECT che ottiene l'id del record da inviare a BizTalk:
			l'hint READPASTE viene usato "saltare" record già bloccati da un'altra transazione
			l'hint UPDLOCK viene usato per bloccare il record per tutta la durata della transazione 
*/

	SET NOCOUNT ON;
	DECLARE @Now DATETIME
	DECLARE @IdSequenza INT
	DECLARE @IdSac UNIQUEIDENTIFIER
	DECLARE @IdProvenienza VARCHAR(64)
	--
	-- Imposto il livello di serializzazione che verrà usato dalla SP
	--
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED

	BEGIN TRANSACTION 
	BEGIN TRY
		--
		-- FONDAMENTALE: si deve restituire un solo record per volta
		--
		SELECT TOP 1 @IdSequenza = [IdSequenza], @IdSac = IdSac
		FROM ara_svc.CodaAnagraficheDaAggiornareInput WITH (READPAST, UPDLOCK)
		ORDER BY [IdSequenza] ASC
		
		IF NOT @IdSequenza IS NULL
		BEGIN 
			SET @Now = GETUTCDATE()
			--
			-- Inserisco record nello storico			
			--
			INSERT INTO ara_svc.CodaAnagraficheDaAggiornareProcessati
				(DataProcessoUtc, IdSequenza, DataInserimentoUtc, IdSac)
			SELECT	
				@Now, IdSequenza, DataInserimentoUtc, IdSac
			FROM ara_svc.CodaAnagraficheDaAggiornareInput
			WHERE IdSequenza = @IdSequenza

			--
			-- Leggo l'IdProvenienza dalla tabella dbo.Pazienti
			--
			SELECT @IdProvenienza = IdProvenienza FROM dbo.Pazienti WHERE Id = @IdSac
		    --
			-- Restituisco i dati
			--
			SELECT 
				@Now AS DataProcessoUtc
				, IdSequenza
				, DataInserimentoUtc 
				, IdSac
				, @IdProvenienza AS IdProvenienza
			FROM 
				ara_svc.CodaAnagraficheDaAggiornareInput
			WHERE 
				IdSequenza = @IdSequenza
			--
			-- Cancello il record restituito
			--
			DELETE FROM ara_svc.CodaAnagraficheDaAggiornareInput WHERE IdSequenza = @IdSequenza
		END
		--
		-- Commit delle modifiche
		--
		COMMIT
		--
		-- Se no trova nessun record ritorna -1
		--
		IF NOT @IdSequenza IS NULL
			RETURN 0
		ELSE
			RETURN -1

	END TRY
	BEGIN CATCH
		--
		-- Rollback delle modifiche
		--
		IF @@TRANCOUNT > 0
			ROLLBACK
		--
		-- Raise dell'errore
		--
		DECLARE @err INT
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = XACT_STATE(), @msg = ERROR_MESSAGE(), @err = ERROR_NUMBER()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'[ara_svc.CodaAnagraficheDaAggiornareOttieni]. In catch: ' + @msg + N' xact_state:' + CAST(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		--
		-- Restituisce il codice dell'errore (già presente nel messaggio di errore)
		--	
		RETURN @err
	END CATCH
END