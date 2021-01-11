

CREATE PROCEDURE [dbo].[BtCodaPrescrizioniOutputOttieni]
AS
BEGIN
/*
	Nuova: 2015-11-13 - Sandro copiata da [BtCodaRefertiOutputOttieni]
		per evitare deadlock utilizzando la proprietà PoolWhileDataFound=true della porta WCF
		di BizTalk è stata impostata una transazione all'interno della SP per utilizzare un
		livello di serializzazione meno forte di quello usato da BizTalk e degli HINT sulla 
		SELECT che ottiene l'id del record da inviare a BizTalk:
			l'hint READPASTE viene usato "saltare" record già bloccati da un'altra transazione
			l'hint UPDLOCK viene usato per bloccare il record per tutta la durata della transazione 

	Modify date: 2017-02-03 ETTORE: Gestione con Semaforo
	Modify date: 2017-04-13 SANDRO: Processa il parsing HL7 prima dell'invio

*/

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
	FROM [dbo].[CodaPrescrizioniOutputSemaforo] WITH(TABLOCKX)
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
		DECLARE @IdPrescrizione UNIQUEIDENTIFIER
		--
		-- Imposto il livello di serializzazione che verrà usato dalla SP (meno forte di quello di default di BizTalk)
		--
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED

		BEGIN TRANSACTION 
		BEGIN TRY
			--
			-- FONDAMENTALE: si deve restituire un solo record per volta
			--		OrdineInvio 0 rappresenta la priorita massima
			--
			SELECT TOP 1 @IdSequenza=IdSequenza, @IdPrescrizione = IdPrescrizione
			FROM dbo.[CodaPrescrizioniOutput] WITH (READPAST, UPDLOCK)
			ORDER BY OrdineInvio ASC, IdSequenza ASC
		
			IF NOT @IdSequenza IS NULL
			BEGIN
				--
				-- Processa il parsing HL7 prima della notifica
				--
				EXEC [dbo].[ExtPrescrizioniParseHl7] @IdPrescrizione, NULL, 1
				--
				-- Aggiorno messaggio con i dati del parsing
				--
				UPDATE dbo.[CodaPrescrizioniOutput]
				SET Messaggio = dbo.GetPrescrizioneXml(@IdPrescrizione)
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Processo notifica
				--
				SET @Now = GETUTCDATE()
				--
				-- Inserisco record nello storico			
				--
				INSERT INTO [CodaPrescrizioniOutputInviati]
					([DataInvio], [IdSequenza], [DataInserimento], [IdPrescrizione], [Operazione]
						, [IdCorrelazione], [CorrelazioneTimeout], [OrdineInvio], [MessaggioCompresso])
				SELECT @Now ,[IdSequenza], [DataInserimento], [IdPrescrizione], [Operazione]
						, [IdCorrelazione], [CorrelazioneTimeout], [OrdineInvio]
						, dbo.compress(CONVERT(VARBINARY(MAX), Messaggio))
				FROM dbo.[CodaPrescrizioniOutput]
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Restituisco al chiamante (BizTalk) l'XML
				--
				SELECT [IdSequenza]
					, @Now AS [DataInvio]
					, [DataInserimento] AS [DataLog]
					, Operazione				
					, IdCorrelazione 
					, CorrelazioneTimeout --In minuti!
					, Messaggio 
				FROM dbo.[CodaPrescrizioniOutput] AS [PrescrizioniOutput]
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Cancello  la restituita
				--
				DELETE FROM dbo.[CodaPrescrizioniOutput] WHERE [IdSequenza] = @IdSequenza
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
			SELECT @report = N'BtCodaPrescrizioniOutputOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
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
    ON OBJECT::[dbo].[BtCodaPrescrizioniOutputOttieni] TO [ExecuteBiztalk]
    AS [dbo];

