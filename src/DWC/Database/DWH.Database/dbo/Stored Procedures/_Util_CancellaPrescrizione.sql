

-- =============================================
-- Author:		ETTORE
-- Create date: 2020-11-09
-- Description:	Cancellazione di una prescrizione
-- =============================================
CREATE PROCEDURE [dbo].[_Util_CancellaPrescrizione]
(
	@IdPrescrizione UNIQUEIDENTIFIER
	, @Debug BIT = 1
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @DataPartizione SMALLDATETIME

	--
	-- Ricavo la Data di Partizione
	--
	SELECT 
		@DataPartizione = DataPartizione 
	FROM [store].[PrescrizioniBase] 
		WHERE Id = @IdPrescrizione

	IF @DataPartizione IS NULL
	BEGIN
		RAISERROR('Impossibile trovare la @DataPartizione. Il record non esiste!', 16, 1)		
		RETURN
	END 


	IF @Debug = 1 
	BEGIN
		--
		-- Cancellazione EstesaFarmaceutica
		--
		SELECT 'PrescrizioniEstesaFarmaceutica' AS PrescrizioniEstesaFarmaceutica, * FROM [store].[PrescrizioniEstesaFarmaceutica]
		WHERE IdPrescrizioniBase = @IdPrescrizione
			AND DataPartizione = @DataPartizione
		--
		-- Cancellazione EstesaSpecialistica
		--
		SELECT 'PrescrizioniEstesaSpecialistica' AS PrescrizioniEstesaSpecialistica, * FROM [store].[PrescrizioniEstesaSpecialistica]
		WHERE IdPrescrizioniBase = @IdPrescrizione
			AND DataPartizione = @DataPartizione

		
		SELECT 'PrescrizioniEstesaTestata' AS PrescrizioniEstesaTestata, * FROM [store].[PrescrizioniEstesaTestata]
		WHERE IdPrescrizioniBase = @IdPrescrizione
			AND DataPartizione = @DataPartizione

		SELECT 'PrescrizioniAllegatiAttributi' AS PrescrizioniAllegatiAttributi, * FROM [store].[PrescrizioniAllegatiAttributi]
		WHERE IdPrescrizioniAllegatiBase IN (
			SELECT Id FROM [store].[PrescrizioniAllegatiBase]
			WHERE IdPrescrizioniBase = @IdPrescrizione
				AND DataPartizione = @DataPartizione
		)

		SELECT 'PrescrizioniAllegatiBase' AS PrescrizioniAllegatiBase, * FROM [store].[PrescrizioniAllegatiBase]
		WHERE IdPrescrizioniBase = @IdPrescrizione
			AND DataPartizione = @DataPartizione

		SELECT 'PrescrizioniAttributi' AS PrescrizioniAttributi, * FROM [store].[PrescrizioniAttributi]
		WHERE IdPrescrizioniBase = @IdPrescrizione
			AND DataPartizione = @DataPartizione

		SELECT 'PrescrizioniBase' AS PrescrizioniBase, * FROM [store].[PrescrizioniBase] 
		WHERE Id = @IdPrescrizione
			AND DataPartizione = @DataPartizione


	END 
	ELSE
	BEGIN 

		BEGIN TRANSACTION 

		BEGIN TRY
			--
			-- Cancellazione EstesaFarmaceutica
			--
			DELETE FROM [store].[PrescrizioniEstesaFarmaceutica]
			WHERE IdPrescrizioniBase = @IdPrescrizione
				AND DataPartizione = @DataPartizione
			--
			-- Cancellazione EstesaSpecialistica
			--
			DELETE FROM [store].[PrescrizioniEstesaSpecialistica]
			WHERE IdPrescrizioniBase = @IdPrescrizione
				AND DataPartizione = @DataPartizione

			--
			-- Cancellazione PrescrizioniEstesaTestata
			--
			DELETE FROM [store].[PrescrizioniEstesaTestata]
			WHERE IdPrescrizioniBase = @IdPrescrizione
				AND DataPartizione = @DataPartizione

			--
			-- Cancellazione PrescrizioniAllegatiAttributi
			--
			DELETE FROM [store].[PrescrizioniAllegatiAttributi]
			WHERE IdPrescrizioniAllegatiBase IN (
				SELECT Id FROM [store].[PrescrizioniAllegatiBase]
				WHERE IdPrescrizioniBase = @IdPrescrizione
				AND DataPartizione = @DataPartizione
			)

			--
			-- Cancellazione PrescrizioniAllegatiBase
			--
			DELETE FROM [store].[PrescrizioniAllegatiBase]
			WHERE IdPrescrizioniBase = @IdPrescrizione
				AND DataPartizione = @DataPartizione

			--
			-- Cancellazione PrescrizioniAttributi
			--
			DELETE FROM [store].[PrescrizioniAttributi]
			WHERE IdPrescrizioniBase = @IdPrescrizione
				AND DataPartizione = @DataPartizione

			--
			-- Cancellazione PrescrizioniBase
			--
			DELETE FROM [store].[PrescrizioniBase] 
			WHERE Id = @IdPrescrizione
				AND DataPartizione = @DataPartizione


			COMMIT

			PRINT '_Util_CancellaPrescrizione: cancellata la prescrizione con Id: ' + CAST(@IdPrescrizione AS VARCHAR(40))

		END TRY		
		BEGIN CATCH
			--
			-- Raise dell'errore + ROLLBACK
			--
			DECLARE @xact_state INT
			DECLARE @msg NVARCHAR(2000)
			SELECT @xact_state = xact_state(), @msg = error_message()

			ROLLBACK
		
			DECLARE @report NVARCHAR(4000);
			SELECT @report = N'_Util_CancellaPrescrizione. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
			RAISERROR(@report, 16, 1)
			PRINT @report;			
		
		END CATCH

	END

END