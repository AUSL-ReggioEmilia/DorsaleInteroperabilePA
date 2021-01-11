

-- =============================================
-- Author:		Ettore
-- Create date: 2017-10-31
-- Description:	Restituisce il record della coda a BizTalk
-- =============================================
CREATE PROCEDURE [dbo].[BtCodaNoteAnamnesticheOutputOttieni]
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
	FROM [dbo].[CodaNoteAnamnesticheOutputSemaforo] WITH(TABLOCKX)
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
				[CodaNoteAnamnesticheOutput] WITH (READPAST, UPDLOCK)
			ORDER BY 
				--OrdineInvio 0 rappresenta la priorita massima
				OrdineInvio ASC, IdSequenza ASC
		
			IF NOT @IdSequenza IS NULL
			BEGIN 
				SET @Now = GETUTCDATE()
	
				--
				-- Inserisco record nello storico			
				--
				INSERT INTO [CodaNoteAnamnesticheOutputInviati]
					([DataInvio], [IdSequenza], [DataInserimento], [IdNotaAnamnestica], [Operazione]
						, [IdCorrelazione], [CorrelazioneTimeout], [OrdineInvio]
						, [MessaggioCompresso])
				SELECT
					@Now ,[IdSequenza], [DataInserimento], [IdNotaAnamnestica], [Operazione]
						, [IdCorrelazione], [CorrelazioneTimeout], [OrdineInvio]
						, dbo.compress(CONVERT(VARBINARY(MAX), Messaggio))
				FROM 
					[CodaNoteAnamnesticheOutput] WHERE [IdSequenza] = @IdSequenza
		
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
				FROM [CodaNoteAnamnesticheOutput] AS [NoteAnamnesticheOutput]
				WHERE [IdSequenza] = @IdSequenza
				--
				-- Cancello  la restituita
				--
				DELETE FROM [CodaNoteAnamnesticheOutput] WHERE [IdSequenza] = @IdSequenza
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
			SELECT @report = N'BtCodaNoteAnamnesticheOutputOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
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
    ON OBJECT::[dbo].[BtCodaNoteAnamnesticheOutputOttieni] TO [ExecuteBiztalk]
    AS [dbo];

