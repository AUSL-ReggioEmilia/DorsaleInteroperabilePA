


-- =============================================
-- Author:		ETTORE
-- Create date: 2017-02-03
-- Description:	Conta i record paziente nella drop table dei pazienti usando la tabella semaforo.
-- =============================================
CREATE PROCEDURE [dbo].[BtPazientiDropTableConta]
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @TimeOutReadSecond INT = 60

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION 

	BEGIN TRY
		--/////////////////////////////////////////////////////////////////////////////////////////////////////
		--   Nuovo gestione di accesso sequenziale tramite semaforo per uso con più host di BT
		--/////////////////////////////////////////////////////////////////////////////////////////////////////
		--
		-- Incrementa il record del semaforo, se serve lo aggiunge
		--
		DECLARE @HostName VARCHAR(64) = CONVERT(VARCHAR(64), @@SPID)
		SELECT @HostName = RTRIM(hostname) FROM sys.sysprocesses WHERE spid = @@SPID

		IF EXISTS (SELECT * FROM [dbo].[PazientiDropTableSemaforo] WITH(TABLOCKX) WHERE [HostBiztalk] = @HostName)
			UPDATE [dbo].[PazientiDropTableSemaforo] WITH(TABLOCKX)
			SET [DataLettura] = GETUTCDATE()
				, [ContatoreLetture] = CASE WHEN [ContatoreLetture] < 1000000 THEN [ContatoreLetture] + 1 ELSE 0 END
			WHERE [HostBiztalk] = @HostName
		ELSE
			INSERT INTO [dbo].[PazientiDropTableSemaforo] WITH(TABLOCKX) ([HostBiztalk], [DataLettura], [Primario])
			VALUES ( @HostName, GETUTCDATE(), 0)
		--
		-- Cerca [HostBiztalk] con priorità al primario che abbia fatto polling negli ultimi X sec
		--
		DECLARE @HostNamePriority VARCHAR(64) = ''
		SELECT TOP 1 @HostNamePriority = [HostBiztalk]
		FROM [dbo].[PazientiDropTableSemaforo] WITH(TABLOCKX)
		WHERE [DataLettura] > DATEADD( SECOND, @TimeOutReadSecond * -1, GETUTCDATE())
		ORDER BY [Primario] DESC, [HostBiztalk]
		--
		-- Aggiorno primario con il corrente
		--
		IF @HostNamePriority <> ''
			UPDATE [dbo].[PazientiDropTableSemaforo] WITH(TABLOCKX)
			SET [Primario] = CASE WHEN [HostBiztalk] = @HostNamePriority THEN 1 ELSE 0 END
			WHERE [Primario] <> CASE WHEN [HostBiztalk] = @HostNamePriority THEN 1 ELSE 0 END
		--
		-- Commit delle modifiche
		--
		COMMIT
		--/////////////////////////////////////////////////////////////////////////////////////////////////////
		--
		-- Se sono il primario CONTO le righe
		--
		IF @HostNamePriority = @HostName
		BEGIN
			SELECT COUNT(*) FROM dbo.PazientiDropTable WITH(NOLOCK)
			WHERE (Inviato = 0)
				--
				-- Ritardo di 30 secondi
				--
				AND DataLog < DATEADD(second, -30, GETDATE())
			RETURN 1
		END ELSE BEGIN
			SELECT 0
			RETURN 0
		END

	END TRY
	BEGIN CATCH
		--
		-- Rollback delle modifiche
		--
		ROLLBACK
		--
		-- Raise dell'errore
		--
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()

		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'BtPazientiDropTableConta. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;			
	END CATCH
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BtPazientiDropTableConta] TO [Execute Biztalk]
    AS [dbo];

