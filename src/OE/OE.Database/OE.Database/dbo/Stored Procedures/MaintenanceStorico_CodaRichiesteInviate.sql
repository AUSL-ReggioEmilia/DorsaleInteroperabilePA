
CREATE PROCEDURE [dbo].[MaintenanceStorico_CodaRichiesteInviate]
 @NR_GG_NO_HISTORY INT=2
,@BATCH_SIZE INT=1000
,@DEBUG BIT=0
,@LOG BIT=0
AS
BEGIN
--MODIFICHE:
-- 2019-04-08 Sandro: Primo rilascio 

	SET NOCOUNT ON
	
	-- @NR_GG_NO_HISTORY
	-- Totale dei giorni che non saranno storicizzati.
	--
	SET @NR_GG_NO_HISTORY = CASE WHEN @NR_GG_NO_HISTORY < 1 THEN 1
									ELSE @NR_GG_NO_HISTORY END

	-- Se (@MAX_ORDERS_HISTORY <= 0), non c'è limite
	-- Numero massimo di ordini da storicizzare nel range. 
	--
	DECLARE @TOP as int
	SET @TOP = CASE WHEN @BATCH_SIZE < 1 THEN 2147483647
									ELSE @BATCH_SIZE END

	-- Contatori
	DECLARE @TOT_HISTORY as int = 0
	
	IF @DEBUG = 1
	BEGIN
		--
		-- Smulazione
		--
		DECLARE @NumSumula INT

		SELECT @NumSumula = COUNT(*)
		FROM [dbo].[CodaRichiesteOutputInviate] c WITH(NOLOCK)
		WHERE DataInvio < DATEADD(DAY, @NR_GG_NO_HISTORY * -1, GETDATE())
			AND NOT EXISTS (SELECT *
						FROM [dbo].[CodaRichiesteOutputInviate_Storico] e
						WHERE e.[Id] = c.[Id]
						)

		PRINT '[Debug] CodaRichiesteInviate da storicizzare ' + CONVERT(varchar(40), GETDATE(), 120)
					+ '. Archvierà ' + CONVERT(varchar(10), @NumSumula) + 'record!'
		PRINT ''

	END ELSE BEGIN

		BEGIN TRY
			PRINT 'Inizio loop sui CodaRichiesteInviate da storicizzare ' + CONVERT(varchar(40), GETDATE(), 120)
			PRINT ''

			DECLARE @Err INT = 0
			DECLARE @Row INT = 1

			WHILE @Err = 0 AND @Row > 0
			BEGIN
				--
				-- Exec COMMAND
				--
				INSERT INTO [dbo].[CodaRichiesteOutputInviate_Storico]
				SELECT TOP(@TOP) *
				FROM [dbo].[CodaRichiesteOutputInviate] c WITH(NOLOCK)
				WHERE DataInvio < DATEADD(DAY, @NR_GG_NO_HISTORY * -1, GETDATE())
					AND NOT EXISTS (SELECT *
								FROM [dbo].[CodaRichiesteOutputInviate_Storico] e
								WHERE e.[Id] = c.[Id]
								)
				ORDER BY c.[Id]
				--
				-- Verifico risultato
				--
				SELECT @Err = @@Error, @Row = @@Rowcount

				PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Archiviati ' + CAST(@Row as varchar(max)) + ' record!'
			END

			SET @Err = 0
			SET @Row = 1

			WHILE @Err = 0 AND @Row > 0
			BEGIN
				--
				-- Exec COMMAND
				--
				DELETE TOP(@TOP) [dbo].[CodaRichiesteOutputInviate]
				FROM [dbo].[CodaRichiesteOutputInviate] c
				WHERE EXISTS (SELECT *
								FROM [dbo].[CodaRichiesteOutputInviate_Storico] e
								WHERE e.[Id] = c.[Id]
								)
				--
				-- Verifico risultato
				--
				SELECT @Err = @@Error, @Row = @@Rowcount

				SET @TOT_HISTORY = @TOT_HISTORY + @Row
				PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Cancellati ' + CAST(@Row as varchar(max)) + ' record!'
			END

			PRINT ''
			PRINT '[' + CONVERT(varchar(40), GETDATE(), 120) + '] Storicizzazione CodaRichiesteInviate. Totale storicizzati '
							+ CAST(@TOT_HISTORY as varchar(max)) 
		END TRY
		BEGIN CATCH
	
			DECLARE @ErrorMessage varchar(2560)
			SELECT @ErrorMessage = dbo.GetException()
			RAISERROR(@ErrorMessage, 16, 1)
		END CATCH

	END --@DEBUG

END