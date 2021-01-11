
-- =============================================
-- Author:		ALESSANDRO NOSTINI
-- Create date: 2017-10-10
-- Description:	Cancella dalle code CodaXXXInviati i record più vecchi di N giorni
--				Svuota il campo MessaggioCompresso dalle code CodaXXXInviati per i record più vecchi M giorni
-- Modify Date: 2017-12-05 ETTORE: Aggiunto la cancellazione delle code SOLE
-- Modify Date: 2018-10-08 ETTORE: Aggiunto la cancellazione della coda di output delle note anamnestiche
-- Modify Date: 2019-03-05 SANDRO: Aggiunto la cancellazione nuove code SOLE
-- Modify Date: 2022-06-24 SANDRO: Parametrizzati i giorni di purge, Xml e Row su 2 livelli
--
-- =============================================
CREATE PROCEDURE [dbo].[MntPuliziaCodeInvio]
(
 @CountBatch INT = 10
,@Top INT = 1000
,@DayPurgeXml INT = 2
,@DayPurgeRow INT = 180
)
AS
BEGIN

DECLARE @trip INT
DECLARE @err INT
DECLARE @row INT
		
	-- Cancellazione dalla CodaRefertiOutputInviati
	--
	print 'Cancellazione dalla CodaRefertiOutputInviati' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		DELETE TOP(@Top) FROM CodaRefertiOutputInviati
		WHERE DataInvio < DateAdd(day, -@DayPurgeRow, GetDate())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END
	
	--		
	-- Cancellazione dalla CodaEventiOutputInviati
	--
	print 'Cancellazione dalla CodaEventiOutputInviati' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		DELETE TOP(@Top) FROM CodaEventiOutputInviati
		WHERE DataInvio < DateAdd(day, -@DayPurgeRow, GetDate())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END

	--		
	-- Cancellazione dalla CodaPrescrizioniOutputInviati
	--
	print 'Cancellazione dalla CodaPrescrizioniOutputInviati' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		DELETE TOP(@Top) FROM CodaPrescrizioniOutputInviati
		WHERE DataInvio < DateAdd(day, -@DayPurgeRow, GetDate())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END
	

	--		
	-- Cancellazione dalla CodaNoteAnamnesticheOutputInviati
	--

	print 'Cancellazione dalla CodaNoteAnamnesticheOutputInviati' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		DELETE TOP(@Top) FROM CodaNoteAnamnesticheOutputInviati
		WHERE DataInvio < DateAdd(day, -@DayPurgeRow, GetDate())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END

	
	--
	-- Cancellazione dalla [sole].[CodaEventiInviati]
	--
	print 'Cancellazione dalla [sole].[CodaEventiInviati]' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		DELETE TOP(@Top) FROM [sole].[CodaEventiInviati]
		WHERE DataInvio < DateAdd(day, -@DayPurgeRow, GetDate())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END

	--		
	-- Cancellazione dalla [sole].[CodaRefertiInviati]
	--
	print 'Cancellazione dalla [sole].[CodaRefertiInviati]' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		DELETE TOP(@Top) FROM [sole].[CodaRefertiInviati]
		WHERE DataInvio < DateAdd(day, -@DayPurgeRow, GetDate())

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END

	/********************************************
	
		SVUOTAMENTO BODY
	
	********************************************/
	--		
	-- Vuota body dalla CodaRefertiOutputInviati
	--
	print 'Vuota body dalla CodaRefertiOutputInviati' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		UPDATE TOP(@Top) CodaRefertiOutputInviati
			SET MessaggioCompresso = NULL
		WHERE DataInvio < DateAdd(day, -@DayPurgeXml, GetDate())
			AND NOT MessaggioCompresso IS NULL

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END

	--		
	-- Vuota body dalla CodaEventiOutputInviati
	--
	print 'Vuota body dalla CodaEventiOutputInviati' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		UPDATE TOP(@Top) CodaEventiOutputInviati
				SET MessaggioCompresso = NULL
		WHERE DataInvio < DateAdd(day, -@DayPurgeXml, GetDate())
			AND NOT MessaggioCompresso IS NULL

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END	
	
	--		
	-- Vuota body dalla CodaPrescrizioniOutputInviati
	--
	print 'Vuota body dalla CodaPrescrizioniOutputInviati' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		UPDATE TOP(@Top) CodaPrescrizioniOutputInviati
				SET MessaggioCompresso = NULL
		WHERE DataInvio < DateAdd(day, -@DayPurgeXml, GetDate())
			AND NOT MessaggioCompresso IS NULL

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END


	--		
	-- Vuota body dalla CodaNoteAnamnesticheOutputInviati
	--
	print 'Vuota body dalla CodaNoteAnamnesticheOutputInviati' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		UPDATE TOP(@Top) CodaNoteAnamnesticheOutputInviati
				SET MessaggioCompresso = NULL
		WHERE DataInvio < DateAdd(day, -@DayPurgeXml, GetDate())
			AND NOT MessaggioCompresso IS NULL

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END



	--		
	-- Vuota body dalla [sole].[CodaEventiInviati]
	--
	print 'Vuota body dalla [sole].[CodaEventiInviati]' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		UPDATE TOP(@Top) [sole].[CodaEventiInviati]
			SET Messaggio = NULL
		WHERE DataInvio < DateAdd(day, -@DayPurgeXml, GetDate())
			AND NOT Messaggio IS NULL

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END

	--		
	-- Vuota body dalla [sole].[CodaRefertiInviati]
	--
	print 'Vuota body dalla [sole].[CodaRefertiInviati]' + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

	SET @trip = ISNULL(@CountBatch, 1)
	SET @err = 0
	SET @row = 1

	WHILE @trip > 0 AND @err = 0 AND @row > 0
	BEGIN
		print '-- Trip=' + CONVERT(VARCHAR, @trip) + ' ;' + CONVERT(VARCHAR, GETDATE(), 120)

		UPDATE TOP(@Top) [sole].[CodaRefertiInviati]
				SET Messaggio = NULL
		WHERE DataInvio < DateAdd(day, -@DayPurgeXml, GetDate())
			AND NOT Messaggio IS NULL

		SELECT @err = @@ERROR, @row = @@ROWCOUNT
		IF NOT @CountBatch IS NULL SET @trip = @trip - 1
	END	

END