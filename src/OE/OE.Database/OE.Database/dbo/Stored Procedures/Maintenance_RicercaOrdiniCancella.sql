
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2020-02-26
--
-- Description:	Processa le cancellazioni e purge
-- =============================================
CREATE PROCEDURE [dbo].[Maintenance_RicercaOrdiniCancella]
(
 @NoInformation BIT = 1
,@BatchSize INT = 1000
,@BatchCount INT = 100
)
AS
BEGIN
	SET NOCOUNT ON
	--
	-- CONSTANT
	--
	DECLARE @GIORNI INT = 10
	--
	-- Variabili
	--
	DECLARE @Err AS INT, @Row AS INT
	DECLARE @TotaleRecord INT

	SET @TotaleRecord = 0
	SET @Err = 0
	SET @Row = 1

	----------------------------------------
	-- Cancello [RicercaOrdiniCodaProcessate]
	----------------------------------------

	WHILE @Err = 0 AND @Row > 0
	BEGIN
		--
		-- Exec COMMAND
		--
		DELETE TOP(@BatchSize) [dbo].[RicercaOrdiniCodaProcessate]
		WHERE DataProcessoUtc < DATEADD(DAY, @GIORNI * -1, GETUTCDATE())
		--
		-- Verifico risultato
		--
		SELECT @Err = @@Error, @Row = @@Rowcount
		SET @TotaleRecord = @TotaleRecord + @Row
	END

	IF @NoInformation = 0
	BEGIN
		PRINT ''
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120)
				+ ' [RicercaOrdiniCodaProcessate]: Cancellati  = '	+ CONVERT(VARCHAR(10), @TotaleRecord)
	END

	----------------------------------------
	-- Cancello [RicercaOrdiniProcessoLog]
	----------------------------------------

	SET @TotaleRecord = 0
	SET @Err = 0
	SET @Row = 1

	WHILE @Err = 0 AND @Row > 0
	BEGIN
		--
		-- Exec COMMAND
		--
		DELETE TOP(@BatchSize) [dbo].[RicercaOrdiniProcessoLog]
		WHERE DataProcessoUtc < DATEADD(DAY, @GIORNI * -1, GETUTCDATE())
		--
		-- Verifico risultato
		--
		SELECT @Err = @@Error, @Row = @@Rowcount
		SET @TotaleRecord = @TotaleRecord + @Row
	END

	IF @NoInformation = 0
	BEGIN
		PRINT ''
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120)
				+ ' [RicercaOrdiniProcessoLog]: Cancellati  = '	+ CONVERT(VARCHAR(10), @TotaleRecord)
	END

	----------------------------------------
	-- Cancello [dbo].[RicercaOrdini]
	----------------------------------------

	SET @TotaleRecord = 0
	SET @Err = 0
	SET @Row = 1

	WHILE @Err = 0 AND @Row > 0
	BEGIN
		--
		-- Exec COMMAND
		--
		DELETE TOP(@BatchSize) [dbo].[RicercaOrdini]
		FROM [dbo].[RicercaOrdini] fore
		WHERE NOT EXISTS (SELECT * FROM [dbo].[OrdiniTestate] ot
							WHERE ot.ID = fore.[IdOrdineTestata])

		--
		-- Verifico risultato
		--
		SELECT @Err = @@Error, @Row = @@Rowcount
		SET @TotaleRecord = @TotaleRecord + @Row
	END

	IF @NoInformation = 0
	BEGIN
		PRINT ''
		PRINT CONVERT(VARCHAR(20), GETDATE(), 120)
				+ ' [RicercaOrdini]: Cancellati  = '	+ CONVERT(VARCHAR(10), @TotaleRecord)
	END

END