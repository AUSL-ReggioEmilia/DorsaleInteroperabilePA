
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[MntRefertiCancellaLabCdaAnnullatiUnoPerUno]
	 @FromData datetime = NULL
	,@ToData datetime = NULL
	,@Batch int = 1000
	,@Simulazione bit = 1
AS
BEGIN
/*
	Modificata SANDRO 2015-08-20: Usa VIEW store
*/
DECLARE @StatoRefertoCodice tinyint

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @FromData IS NULL
		SET @FromData = DATEADD(day, -30, GETDATE())

	IF @ToData IS NULL
		SET @ToData = GETDATE()

	IF @Simulazione = 1
		PRINT 'Modalità simulazione'

	-- =============================================
	-- Declare and using a READ_ONLY cursor
	-- =============================================
	DECLARE LoopReferti CURSOR STATIC READ_ONLY	FOR
	SELECT TOP (@Batch) rb.Id
		,rb.NumeroReferto
		,rb.DataReferto
		,rb.IdEsterno
	FROM [store].[RefertiBase] rb WITH(NOLOCK)
	WHERE rb.SistemaErogante = 'LABCDA'
		AND rb.RepartoErogante LIKE 'RepLabCda%'
		AND rb.StatoRichiestaCodice = 3
		AND rb.DataReferto BETWEEN @FromData AND @ToData
	ORDER BY rb.DataModifica

	DECLARE @Id uniqueidentifier
	DECLARE @NumeroReferto varchar(16)
	DECLARE @DataReferto datetime
	DECLARE @IdEsterno varchar(64)

	DECLARE @Trovati int = 0
	DECLARE @Corrente int = 0
	
	DECLARE @CancellatoSi int = 0
	DECLARE @CancellatoNo int = 0

	OPEN LoopReferti

	SET @Trovati = @@CURSOR_ROWS 
	PRINT 'Trovati ' + ISNULL(CONVERT(VARCHAR(10), @Trovati), '0') + ' referti LABCDA annullati!'

	FETCH NEXT FROM LoopReferti INTO @Id, @NumeroReferto, @DataReferto, @IdEsterno
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			SET @Corrente = @Corrente + 1
			 
			IF @Simulazione = 1
			BEGIN
				-- Simula cancellazione
				---
				PRINT 'Referto: @Id=' + CONVERT(VARCHAR(40), @Id)
						+ ' @IdEsterno=' + ISNULL( @IdEsterno, 'Nullo')
						+ ' @NumeroReferto=' + ISNULL( @NumeroReferto, 'Nullo')
						+ ' @DataReferto=' + ISNULL(CONVERT(VARCHAR(20), @DataReferto, 102), 'Nullo')

				SET @IdEsterno = NULL
				SET @IdEsterno = dbo.GetRefertiIdEsterno(@Id)
				IF NOT @IdEsterno IS NULL
					SET @CancellatoSi = @CancellatoSi + 1
				ELSE
					SET @CancellatoNo = @CancellatoNo + 1
			END
			ELSE
			BEGIN
				-- Cancella veramente
				---
				PRINT 'Referto: @Id=' + CONVERT(VARCHAR(40), @Id)
						+ ' @IdEsterno=' + ISNULL( @IdEsterno, 'Nullo')
						+ ' @NumeroReferto=' + ISNULL( @NumeroReferto, 'Nullo')
						+ ' @DataReferto=' + ISNULL(CONVERT(VARCHAR(20), @DataReferto, 102), 'Nullo')

				PRINT '---' + CONVERT(VARCHAR(10), @Corrente) + ' di ' + CONVERT(VARCHAR(10), @Trovati)

				DECLARE @ret as int
				
				EXEC @ret = dbo.MntRefertoCancellaPerId @Id
				
				IF @ret = 0
				BEGIN
					SET @CancellatoSi = @CancellatoSi + 1
				END
				ELSE
				BEGIN
					PRINT 'Errore: Referto non cancellato' 
					PRINT ''
					SET @CancellatoNo = @CancellatoNo + 1
				END
			END
		END
		FETCH NEXT FROM LoopReferti INTO @Id, @NumeroReferto, @DataReferto, @IdEsterno
	END

	PRINT ''
	PRINT 'Trovati ' + ISNULL(CONVERT(VARCHAR(10), @Trovati), '0') + ' referti!'
	PRINT 'Cancellati: ' + CONVERT(VARCHAR(10), @CancellatoSi)
	PRINT 'Non cancellati: ' + CONVERT(VARCHAR(10), @CancellatoNo)

	CLOSE LoopReferti
	DEALLOCATE LoopReferti
END

