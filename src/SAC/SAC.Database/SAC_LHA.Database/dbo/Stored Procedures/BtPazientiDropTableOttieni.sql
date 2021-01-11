

-- =============================================
-- Author:		ETTORE
-- Create date: 2017-02-03
-- Description:	Legge dalla drop table dei pazienti usando la tabella semaforo un record alla volta. Sostituisce la SP PazientiDropTableLHABT
-- Modify date: 2017-03-02 ETTORE: Applicato pattern corretto per lettura da una coda: WITH (READPAST, UPDLOCK) nella select sulla tabella di coda
-- Modify date: 2017-03-09 ETTORE: Applicato pattern corretto per lettura da una coda: mancava SET TRANSACTION ISOLATION LEVEL READ COMMITTED
-- =============================================
CREATE PROCEDURE [dbo].[BtPazientiDropTableOttieni]
AS
BEGIN
	SET NOCOUNT ON
	--/////////////////////////////////////////////////////////////////////////////////////////////////////
	--   Nuovo gestione di accesso sequenziale tramite semaforo per uso con più host di BT
	--/////////////////////////////////////////////////////////////////////////////////////////////////////

	DECLARE @TimeOutReadSecond INT = 60
	--
	-- Controllo [HostBiztalk] con priorità di risposta
	--
	DECLARE @HostName VARCHAR(64) = CONVERT(VARCHAR(64), @@SPID)
	SELECT @HostName = RTRIM(hostname) FROM sys.sysprocesses WHERE spid = @@SPID

	DECLARE @HostNamePriority VARCHAR(64) = ''
	SELECT TOP 1 @HostNamePriority = [HostBiztalk]
	FROM [dbo].[PazientiDropTableSemaforo] WITH(TABLOCKX)
	WHERE [DataLettura] > DATEADD( SECOND, @TimeOutReadSecond * -1, GETUTCDATE())
	ORDER BY [Primario] DESC, [HostBiztalk]

	--/////////////////////////////////////////////////////////////////////////////////////////////////////
	--
	-- Esegue solo sul PRIMARIO
	--

	IF @HostNamePriority = @HostName
	BEGIN

		DECLARE @DataSessione AS DATETIME
		SET @DataSessione = GETDATE()

		--
		-- Imposto il livello di serializzazione che verrà usato dalla SP (meno forte di quello di default di BizTalk)
		--
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	
		BEGIN TRAN
		BEGIN TRY

			-- Prenoto i primi pazienti
			UPDATE dbo.PazientiDropTable
			SET DataInvio = @DataSessione,
				Inviato = 1
			WHERE Id IN (	
							SELECT TOP 1 Id ----<---- DEVE ESSERE TOP 1
							FROM dbo.PazientiDropTable WITH (READPAST, UPDLOCK)
							WHERE (Inviato = 0)
								--
								-- Ritardo di 30 secondi
								--
								AND DataLog < DATEADD(second, -30, GETDATE())
							ORDER BY DataLog
						)
	
			-- Ritorno i pazienti prenotati
			SELECT IdLha 
			FROM dbo.PazientiDropTable
			WHERE DataInvio = @DataSessione
			ORDER BY DataLog
			--
			-- Commit
			--
			COMMIT
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
			DECLARE @xact_state INT
			DECLARE @msg NVARCHAR(2000)
			SELECT @xact_state = xact_state(), @msg = error_message()

			DECLARE @report NVARCHAR(4000);
			SELECT @report = N'BtPazientiDropTableOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
			RAISERROR(@report, 16, 1)
			PRINT @report;	
	
		END CATCH

		RETURN 1

	END ELSE BEGIN
		RETURN 0
	END 
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BtPazientiDropTableOttieni] TO [Execute Biztalk]
    AS [dbo];

