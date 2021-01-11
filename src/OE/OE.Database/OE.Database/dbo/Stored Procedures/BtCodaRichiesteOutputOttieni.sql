


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	Prende la prima richiesta non inviata,  la restituisce al chiamante
--				e la sposta nello storico
-- Modify date: 2017-03-02 ETTORE: Applicato pattern corretto per lettura da una coda: tolto i WITH(NOLOCK)
-- =============================================
CREATE PROCEDURE [dbo].[BtCodaRichiesteOutputOttieni]
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
	FROM [dbo].[CodaRichiesteOutputSemaforo] WITH(TABLOCKX)
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
	
		SET TRANSACTION ISOLATION LEVEL READ COMMITTED
		BEGIN TRANSACTION
		--
		-- FONDAMENTALE: si deve restituire un solo record per volta
		--
		SELECT TOP 1 @IdSequenza=IdSequenza
			FROM [CodaRichiesteOutput] WITH(READPAST, UPDLOCK) 
			ORDER BY IdSequenza
	
		IF NOT @IdSequenza IS NULL
		BEGIN
			BEGIN TRY
				SET @Now = GETDATE()
				--
				-- Inserisco record nello storico			
				--
				INSERT INTO [CodaRichiesteOutputInviate]
					([IdSequenza] ,[DataInserimento] ,[IDTicketInserimento] ,[IDOrdineTestata] ,[Messaggio], [DataInvio])
				SELECT
					[IdSequenza] ,[DataInserimento] ,[IDTicketInserimento] ,[IDOrdineTestata] ,[Messaggio], @Now
				FROM 
					[CodaRichiesteOutput] WHERE [IdSequenza] = @IdSequenza
				--
				-- Restituisco al chiamante (BizTalk) l'XML
				--
				SELECT [IdSequenza]
					, @Now AS [DataInvio]
					, [DataInserimento] AS [DataLog]
				
					-- Come correlazione usa SistemaRichiedente oppure IDSistemaRichiedente
					, (SELECT COALESCE( s.[Codice] + '/' + s.[CodiceAzienda]
								, CONVERT(VARCHAR(36), ot.IDSistemaRichiedente)) AS Nome
							FROM dbo.OrdiniTestate ot 
								LEFT OUTER JOIN  [dbo].[Sistemi] s 
									ON ot.IDSistemaRichiedente = s.Id
							WHERE ot.Id = [IDOrdineTestata])
						+ '/' + REPLACE(CONVERT(VARCHAR(4), @Now, 114 ), ':', '') AS [IdCorrelazione]
					
					-- Timeout della correlazione minuti
					, CONVERT(INT, 15) AS [CorrelazioneTimeout]
					, CONVERT(VARBINARY(MAX), [Messaggio]) AS MessaggioBase64
				FROM [CodaRichiesteOutput] AS [RichiesteOutput]
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Cancello  la restituita
				--
				DELETE FROM [CodaRichiesteOutput] WHERE [IdSequenza] = @IdSequenza	
				--
				-- Commit delle modifiche		
				--
				COMMIT 
			
			END TRY
			BEGIN CATCH
				--
				-- Raise dell'errore + ROLLBACK
				--
				DECLARE @xact_state INT
				DECLARE @msg NVARCHAR(2000)
				SELECT @xact_state = xact_state(), @msg = error_message()

				IF @@TRANCOUNT > 0
					ROLLBACK
			
				DECLARE @report NVARCHAR(4000);
				SELECT @report = N'BtCodaRichiesteOutputOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
				RAISERROR(@report, 16, 1)
				PRINT @report;			
			END CATCH
		END
		ELSE
		BEGIN
			--
			-- Commit della select		
			--
			COMMIT 
		END

		RETURN 1
	END ELSE BEGIN
		RETURN 0
	END 

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BtCodaRichiesteOutputOttieni] TO [ExecuteBiztalk]
    AS [dbo];

