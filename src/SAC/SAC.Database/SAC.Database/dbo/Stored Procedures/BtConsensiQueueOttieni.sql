



-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Modify date: 2017-02-03 ETTORE: Gestione con Semaforo. Impostato TOP 1
-- Modify date: 2017-03-02 ETTORE: Applicato pattern corretto per lettura da una coda: aggiunto WITH(READPAST, UPDLOCK), spostato il COMMIT dentro il TRY CATCH, tolto i WITH(NOLOCK)
-- =============================================
CREATE PROCEDURE  [dbo].[BtConsensiQueueOttieni]
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
	FROM [dbo].[ConsensiQueueSemaforo] WITH(TABLOCKX)
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
				declare @tblTempConsensiQueue table(IdSeq uniqueidentifier)

				declare @dtDataAttuale datetime
				set @dtDataAttuale = getdate()

				insert into @tblTempConsensiQueue
				select top 1 IdSeq --<------------------ DEVE ESSERE TOP 1
				from ConsensiQueue WITH (READPAST, UPDLOCK)
				order by 
					case when (DataStato > dateadd(m, -1 ,@dtDataAttuale)) then 1 else 0 end desc, -- Importazione massiva
					case when (DataStato > dateadd(m, -1 ,@dtDataAttuale)) then datediff(mi,DataOperazione,@dtDataAttuale ) else -(datediff(mi, @dtDataAttuale, DataStato)) end,
					Utente
					--DataOperazione, Utente -- Originale

				SELECT ConsensiQueue.DataOperazione
					  ,ConsensiQueue.Utente
					  ,Operazione
					  ,Id
					  ,Tipo
					  ,DataStato
					  ,Stato
					  ,OperatoreId
					  ,OperatoreCognome
					  ,OperatoreNome
					  ,OperatoreComputer
					  ,PazienteProvenienza
					  ,PazienteProvenienzaId
					  ,PazienteCognome
					  ,PazienteNome
					  ,ISNULL(PazienteCodiceFiscale, '0000000000000000') AS PazienteCodiceFiscale
					  ,PazienteDataNascita
					  ,PazienteComuneNascitaCodice
					  ,PazienteNazionalitaCodice
					  ,PazienteTessera
				FROM ConsensiQueue inner join @tblTempConsensiQueue tblTemp on 
					(ConsensiQueue.IdSeq = tblTemp.IdSeq) 
				
				--
				-- Scrive nello storico (2011-08-11)
				--
				INSERT INTO [dbo].[ConsensiQueue_Storico]
						   ([Utente]
						   ,[Operazione]
						   ,[DataOperazione]
						   ,[IdConsenso]
						   ,[Consenso])
				SELECT cq.[Utente]
						, cq.[Operazione]
						, cq.[DataOperazione]
						, cq.[Id] AS IdConsenso
						, CONVERT(XML, (SELECT Consenso.*
									FROM [ConsensiQueue] AS Consenso
									WHERE Consenso.IdSeq = cq.IdSeq 
									FOR XML AUTO, ELEMENTS)) AS Consenso
				  FROM [dbo].[ConsensiQueue] AS cq
						inner join @tblTempConsensiQueue tblTemp on 
								cq.[IdSeq] = tblTemp.IdSeq
				--
				-- Rimuove dalla drop-table
				--
				delete ConsensiQueue
				FROM ConsensiQueue inner join @tblTempConsensiQueue tblTemp on 
					(ConsensiQueue.IdSeq = tblTemp.IdSeq) 
				--
				-- COMMIT
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
			  select @report = N'BtConsensiQueueOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state as nvarchar(5));
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
    ON OBJECT::[dbo].[BtConsensiQueueOttieni] TO [ExecuteBiztalk]
    AS [dbo];

