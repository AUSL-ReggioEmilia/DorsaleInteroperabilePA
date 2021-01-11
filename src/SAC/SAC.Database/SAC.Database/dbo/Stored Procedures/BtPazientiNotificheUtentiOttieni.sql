





-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Modify:	MARCCOD - 2015-06-29 Non convertire più il paziente fuso in paziente padre, 
--									ora c'è un campo specifico per IdPazientreFuso
-- Modify:	MARCCOD - 2016-02-18 da TOP 100 a TOP 1  per sequenzializzare modifica e merge 
--				su BizTalk pool while data found = true  e   pool intervall = 5 sec
-- Modify date: 2017-02-03 ETTORE: Gestione con Semaforo
-- Modify date: 2017-03-02 ETTORE: Applicato pattern corretto per lettura da una coda: aggiunto WITH(READPAST, UPDLOCK), spostato il COMMIT dentro il TRY CATCH, tolto i WITH(NOLOCK)
-- Modify date: 2018-05-08 ETTORE: Aggiunto la gestione di PazientiNotifiche.Tipo uguale a 8 (=Modifica consenso) e 9 (=Modifica esenzione)
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE  [dbo].[BtPazientiNotificheUtentiOttieni]
AS
BEGIN
	SET NOCOUNT ON;
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
	FROM [dbo].[PazientiNotificheUtentiSemaforo] WITH(TABLOCKX)
	WHERE [DataLettura] > DATEADD( SECOND, @TimeOutReadSecond * -1, GETUTCDATE())
	ORDER BY [Primario] DESC, [HostBiztalk]

	--/////////////////////////////////////////////////////////////////////////////////////////////////////
	--
	-- Esegue solo sul PRIMARIO
	--

	IF @HostNamePriority = @HostName
	BEGIN

		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION
	
		BEGIN TRY

			declare @Errore int
			set @Errore = 0
		
		
			declare @dt datetime
			set @dt = getdate()

			declare @tblPazientiNotifiche table (
				[Id] [uniqueidentifier] NOT NULL,
				[IdPaziente] [uniqueidentifier] NOT NULL,
				[Tipo] [tinyint] NOT NULL,
				[Data] [datetime] NOT NULL,
				[Utente] [varchar](64) NOT NULL)

			insert into  @tblPazientiNotifiche
				select top 1 PazientiNotifiche.[Id],PazientiNotifiche.[IdPaziente],PazientiNotifiche.[Tipo],PazientiNotifiche.[Data],PazientiNotifiche.[Utente]
				from PazientiNotifiche WITH (READPAST, UPDLOCK) inner join PazientiNotificheUtenti 
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
				order by 
					case 
						when isnull(PazientiNotifiche.Tipo, 0) in (3, 4, 5, 6) then DATEADD(second,60, PazientiNotifiche.Data)
						else PazientiNotifiche.Data
				end asc

			UPDATE PazientiNotificheUtenti
			SET InvioData = @dt, InvioEffettuato = 1
			FROM PazientiNotificheUtenti INNER JOIN 
					(
						select Id from @tblPazientiNotifiche where Tipo <= 2
						union
						select Id from @tblPazientiNotifiche pnNoMrg where Tipo >= 3 and IdPaziente not in (select IdPaziente from @tblPazientiNotifiche where Tipo <= 2)					
					) as PazientiNotifiche 
				ON PazientiNotificheUtenti.IdPazientiNotifica = PazientiNotifiche.Id
			WHERE (isnull(PazientiNotificheUtenti.InvioEffettuato, 0) = 0)


			SELECT IdPaziente , InvioUtente, Data, Operazione, InvioSoapUrl, InvioSoapAccount, InvioSoapPassword, IdPazienteFuso
			FROM (
				SELECT 
					  IdPaziente
					   , isnull(InvioUtente,'') as InvioUtente, isnull(InvioSoapUrl,'') as InvioSoapUrl, Data, 

						-- 
						-- sostituzione del merge originale dell'originale "Pazienti.Disattivato as Operazione"
						-- 
						-- Operazione per distinguere il tipo di notifica (messaggio HL7)
						case 
							-- Merge: 3 bach, 4 msg, 5 ui, 6 ws 
							when (PazientiNotifiche.Tipo >= 3) and (PazientiNotifiche.Tipo <= 6) then 2
						
							-- Provenienza: 1 ui, 2 ws, 7 data access: aggiornamento data decesso; 8 modifica consenso; 9 modifica esenzione
							when ((PazientiNotifiche.Tipo >= 1) and (PazientiNotifiche.Tipo <= 2)) or (PazientiNotifiche.Tipo IN (7, 8, 9)) then
								case 
									when Pazienti.Disattivato = 0 then 0
									when Pazienti.Disattivato = 1 then 1
									when Pazienti.Disattivato = 2 then 0
								end
						end as Operazione  -- 0 modifica, 1 cancelazione, 2 merge					
					   , '' as InvioSoapAccount, '' as InvioSoapPassword
					   , IdPazienteFuso
				FROM PazientiNotifiche 
				INNER JOIN PazientiNotificheUtenti 
					ON PazientiNotificheUtenti.IdPazientiNotifica = PazientiNotifiche.Id
				INNER JOIN Pazienti 
					ON Pazienti.Id = PazientiNotifiche.IdPaziente
				WHERE (InvioEffettuato = 1) and (InvioData = @dt)
				) PazientiNotificheUtenti
			ORDER BY Data
			--
			-- Commit
			--
			COMMIT

		END TRY
		BEGIN CATCH
			  declare @xact_state int
			  declare @msg nvarchar(2000)
			  select @xact_state = xact_state(), @msg = error_message()

			  IF @@TRANCOUNT > 0
			  BEGIN
				ROLLBACK TRANSACTION;
			  END
		  
			  declare @report nvarchar(4000);
			  select @report = N'BtPazientiNotificheUtentiOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state as nvarchar(5));
			  RAISERROR(@report, 16, 1)
			  print @report;
		END CATCH

		RETURN 1
	END ELSE BEGIN
		RETURN 0
	END 

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BtPazientiNotificheUtentiOttieni] TO [ExecuteBiztalk]
    AS [dbo];

