



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Modify:	MARCCOD - 2015-06-29 Non convertire più il paziente fuso in paziente padre, 
--									ora c'è un campo specifico per IdPazientreFuso
-- Modify:	MARCCOD - 2016-02-18 da TOP 100 a TOP 1  per sequenzializzare modifica e merge 
--				su BizTalk pool while data found = true  e   pool intervall = 5 sec
-- Modify date: 2017-02-03 ETTORE: Gestione con Semaforo
-- Modify date: 2018-05-08 ETTORE: Aggiunto la gestione di PazientiNotifiche.Tipo uguale a 8 (=Modifica consenso) e 9 (=Modifica esenzione)
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[BtPazientiNotificheUtentiConta]
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

		IF EXISTS (SELECT * FROM [dbo].[PazientiNotificheUtentiSemaforo] WITH(TABLOCKX) WHERE [HostBiztalk] = @HostName)
			UPDATE [dbo].[PazientiNotificheUtentiSemaforo] WITH(TABLOCKX)
			SET [DataLettura] = GETUTCDATE()
				, [ContatoreLetture] = CASE WHEN [ContatoreLetture] < 1000000 THEN [ContatoreLetture] + 1 ELSE 0 END
			WHERE [HostBiztalk] = @HostName
		ELSE
			INSERT INTO [dbo].[PazientiNotificheUtentiSemaforo] WITH(TABLOCKX) ([HostBiztalk], [DataLettura], [Primario])
			VALUES ( @HostName, GETUTCDATE(), 0)
		--
		-- Cerca [HostBiztalk] con priorità al primario che abbia fatto polling negli ultimi X sec
		--
		DECLARE @HostNamePriority VARCHAR(64) = ''
		SELECT TOP 1 @HostNamePriority = [HostBiztalk]
		FROM [dbo].[PazientiNotificheUtentiSemaforo] WITH(TABLOCKX)
		WHERE [DataLettura] > DATEADD( SECOND, @TimeOutReadSecond * -1, GETUTCDATE())
		ORDER BY [Primario] DESC, [HostBiztalk]
		--
		-- Aggiorno primario con il corrente
		--
		IF @HostNamePriority <> ''
			UPDATE [dbo].[PazientiNotificheUtentiSemaforo] WITH(TABLOCKX)
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

			declare @dt datetime
			set @dt = getdate()
			
			select COUNT(*)
			from PazientiNotifiche(nolock) inner join PazientiNotificheUtenti(nolock) 
				on PazientiNotificheUtenti.IdPazientiNotifica = PazientiNotifiche.Id
			where (isnull(PazientiNotifiche.Tipo, 0) in (1,2,3,4,5,6,7,8,9)) and (isnull(PazientiNotificheUtenti.InvioEffettuato, 0) = 0)
				and 
				( 
					@dt > 
						case
							when isnull(PazientiNotifiche.Tipo, 0) in (3, 4, 5, 6) then DATEADD(second,10, PazientiNotifiche.Data)
							else DATEADD(second,5, PazientiNotifiche.Data)
						end	
				)

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
		SELECT @report = N'BtPazientiNotificheUtentiConta. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		RAISERROR(@report, 16, 1)
		PRINT @report;			
	END CATCH

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BtPazientiNotificheUtentiConta] TO [ExecuteBiztalk]
    AS [dbo];

