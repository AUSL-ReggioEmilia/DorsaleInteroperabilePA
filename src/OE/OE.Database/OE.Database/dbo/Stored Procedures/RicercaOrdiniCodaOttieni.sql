
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-02-26
--
-- Description:	Prende il primo ordine da processare e lo sposta nello storico
-- =============================================
CREATE PROCEDURE [dbo].[RicercaOrdiniCodaOttieni]
(
 @IdOrdineTestata uniqueidentifier OUTPUT
,@DataInserimentoUtc datetime2 OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @IdSequenza INT = NULL
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED
	BEGIN TRANSACTION
	--
	-- FONDAMENTALE: si deve restituire un solo record per volta
	--
	SELECT TOP 1 @IdSequenza=IdSequenza
		FROM [dbo].[RicercaOrdiniCoda] WITH(READPAST, UPDLOCK) 
		ORDER BY IdSequenza
	
	IF NOT @IdSequenza IS NULL
	BEGIN
		BEGIN TRY
			--
			-- Inserisco record nello storico			
			--
			INSERT INTO [dbo].[RicercaOrdiniCodaProcessate] ([IdSequenza], [IdOrdineTestata], [DataInserimentoUtc])
			SELECT [IdSequenza], [IdOrdineTestata], [DataInserimentoUtc]
			FROM [dbo].[RicercaOrdiniCoda]
			WHERE [IdSequenza] = @IdSequenza
			--
			-- Restituisco al chiamante
			--
			SELECT @IdOrdineTestata = [IdOrdineTestata]
				,@DataInserimentoUtc = [DataInserimentoUtc]
			FROM [dbo].[RicercaOrdiniCoda] AS [OrdiniCoda]
			WHERE [IdSequenza] = @IdSequenza
			--
			-- Cancello  la restituita
			--
			DELETE FROM [dbo].[RicercaOrdiniCoda] WHERE [IdSequenza] = @IdSequenza	
			--
			-- Commit delle modifiche		
			--
			IF @@TRANCOUNT > 0 COMMIT  
			
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
			SELECT @report = N'dbo.RicercaOrdiniCodaOttieni. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
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