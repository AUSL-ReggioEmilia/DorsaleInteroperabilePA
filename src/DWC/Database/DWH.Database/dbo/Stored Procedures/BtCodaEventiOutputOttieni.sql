

CREATE PROCEDURE [dbo].[BtCodaEventiOutputOttieni]
AS
BEGIN
/*
	Modifica Ettore 2012-12-17: 
		per evitare deadlock utilizzando la proprietà PoolWhileDataFound=true della porta WCF
		di BizTalk è stata impostata una transazione all'interno della SP per utilizzare un
		livello di serializzazione meno forte di quello usato da BizTalk e degli HINT sulla 
		SELECT che ottiene l'id del record da inviare a BizTalk:
			l'hint READPASTE viene usato "saltare" record già bloccati da un'altra transazione
			l'hint UPDLOCK viene usato per bloccare il record per tutta la durata della transazione 
			
	Modifica Sandro 2015-06-20:		Compressione campo messaggio
	Modifica Sandro 2015-11-26:		Salva anche dati non compressi
	Modify date: 2017-02-03 ETTORE: Gestione con Semaforo
*/

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
	FROM [dbo].[CodaEventiOutputSemaforo] WITH(TABLOCKX)
	WHERE [DataLettura] > DATEADD( SECOND, @TimeOutReadSecond * -1, GETUTCDATE())
	ORDER BY [Primario] DESC, [HostBiztalk]

	--/////////////////////////////////////////////////////////////////////////////////////////////////////
	--
	-- Esegue solo sul PRIMARIO
	--

	IF @HostNamePriority = @HostName
	BEGIN

		DECLARE @Now DATETIME
		DECLARE @IdSequenza as INT
		--
		-- Imposto il livello di serializzazione che verrà usato dalla SP (meno forte di quello di default di BizTalk)
		--
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED

		BEGIN TRANSACTION
		BEGIN TRY
			--
			-- FONDAMENTALE: si deve restituire un solo record per volta
			--
			SELECT TOP 1 
				@IdSequenza=IdSequenza
			FROM 
				[CodaEventiOutput] WITH (READPAST, UPDLOCK) 
			ORDER BY 
				--OrdineInvio 0 rappresenta la priorita massima
				OrdineInvio ASC, IdSequenza ASC
		
			IF NOT @IdSequenza IS NULL
			BEGIN
				SET @Now = GETUTCDATE()
				--
				-- Inserisco record nello storico			
				--
				INSERT INTO [CodaEventiOutputInviati]
					([DataInvio], [IdSequenza], [DataInserimento], [IdEvento], [Operazione]
					, [IdCorrelazione],[CorrelazioneTimeout] ,[OrdineInvio]
					, [Messaggio]
					, [MessaggioCompresso] )
				SELECT
					@Now ,[IdSequenza], [DataInserimento], [IdEvento], [Operazione]
					, [IdCorrelazione], [CorrelazioneTimeout], [OrdineInvio]
					, dbo.TrasformEventoXmlForCodaInviati(Messaggio)  
					, dbo.compress(CONVERT(VARBINARY(MAX), Messaggio))
				FROM 
					[CodaEventiOutput] WHERE [IdSequenza] = @IdSequenza
		
				--
				-- Restituisco al chiamante (BizTalk) l'XML
				--
				SELECT [IdSequenza]
					, @Now AS [DataInvio]
					, [DataInserimento] AS [DataLog]
					, Operazione
					, IdCorrelazione 
					-- Timeout della correlazione
					, CorrelazioneTimeout
					, Messaggio
				FROM [CodaEventiOutput] AS [EventiOutput]
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Cancello  la restituita
				--
				DELETE FROM [CodaEventiOutput] WHERE [IdSequenza] = @IdSequenza	
			END
			--
			-- Commit delle modifiche
			--
			COMMIT
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
			SELECT @report = N'BtCodaEventiOutputOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
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
    ON OBJECT::[dbo].[BtCodaEventiOutputOttieni] TO [ExecuteBiztalk]
    AS [dbo];

