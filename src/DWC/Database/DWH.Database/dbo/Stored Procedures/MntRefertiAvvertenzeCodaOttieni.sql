


-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-25
-- Description:	Prende il primo record da processare dalla tabella "RefertiAvvertenzeCoda"
--				e lo sposta nella tabella di storico "RefertiAvvertenzeCodaProcessate"
-- =============================================
CREATE PROCEDURE [dbo].[MntRefertiAvvertenzeCodaOttieni]
(
@DataProcessoUtc		DATETIME2			OUTPUT
, @IdSequenza			INT					OUTPUT
, @IdReferto			UNIQUEIDENTIFIER	OUTPUT
, @DataInserimentoUtc	DATETIME2			OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION
	--
	-- FONDAMENTALE: si deve restituire un solo record per volta
	--
	SELECT TOP 1 @IdSequenza=IdSequenza
		FROM dbo.RefertiAvvertenzeCoda WITH(READPAST, UPDLOCK) 
		ORDER BY IdSequenza
	
	IF NOT @IdSequenza IS NULL
	BEGIN
		BEGIN TRY

			SET @DataProcessoUtc = GETUTCDATE()
			--
			-- Inserisco record nello storico			
			--
			INSERT INTO dbo.RefertiAvvertenzeCodaProcessate (DataProcessoUtc, IdSequenza, IdReferto, DataInserimentoUtc)
			SELECT @DataProcessoUtc, IdSequenza, IdReferto, DataInserimentoUtc
			FROM dbo.RefertiAvvertenzeCoda
			WHERE IdSequenza = @IdSequenza
			--
			-- Restituisco al chiamante
			--
			SELECT @IdReferto = IdReferto
				,@DataInserimentoUtc = DataInserimentoUtc
			FROM dbo.RefertiAvvertenzeCoda AS OrdiniCoda
			WHERE IdSequenza = @IdSequenza
			--
			-- Cancello  la restituita
			--
			DELETE FROM dbo.RefertiAvvertenzeCoda WHERE IdSequenza = @IdSequenza	
			--
			-- Commit delle modifiche		
			--
			COMMIT  
			
			RETURN 0

		END TRY
		BEGIN CATCH
			--
			-- Raise dell'errore + ROLLBACK
			--
			DECLARE @xact_state INT
			DECLARE @msg NVARCHAR(2000)
			SELECT @xact_state = xact_state(), @msg = error_message()

			IF @@TRANCOUNT > 0 ROLLBACK
			
			DECLARE @report NVARCHAR(4000);
			SELECT @report = N'dbo.RefertiAvvertenzeCodaOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
			RAISERROR(@report, 16, 1)
			PRINT @report;	
			
			RETURN @xact_state
		END CATCH

	END	ELSE BEGIN
		--
		-- Commit della select		
		--
		IF @@TRANCOUNT > 0 COMMIT 

		RETURN 1
	END
END