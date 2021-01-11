

-- =============================================
-- Author:		<Nostini ALessandro>
-- Create date: <Create Date,,>
-- Modified: 2015-08-20 SANDRO Usa VIEW store
-- Modified: 2016-05-12 SANDRO Usa DECLARE @Ret TABLE (DELETED_COUNT int)
-- Modified: 2016-12-12 ETTORE Chiamo la SP MntRefertoCancellaPerId()
-- Description:	Cancell auna serie di referti
-- =============================================
CREATE PROCEDURE [dbo].[MntRefertiCancella]
	 @DaData datetime = NULL
	,@ToData datetime = NULL
	,@AziendaErogante varchar(64) = NULL
	,@SistemaErogante varchar(64) = NULL
	,@RepartoErogante varchar(64) = NULL
	,@StatoReferto varchar(64) = NULL
	,@RepartoRichiedenteCodice varchar(16) = NULL
	,@LikeIdEsterno varchar(64) = NULL
	,@Simulazione bit = 1
AS
BEGIN

DECLARE @StatoRefertoCodice tinyint

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @StatoReferto IS NULL
	BEGIN
		RAISERROR('Il parametro @StatoReferto non può essere NULL!', 16, 1)
		RETURN
	END

	SET @StatoRefertoCodice = CASE @StatoReferto
									WHEN 'In corso' THEN 0
									WHEN 'Completata' THEN 1
									WHEN 'Variata' THEN 2
									WHEN 'Cancellata' THEN 3
									ELSE NULL
								END

	IF @StatoRefertoCodice IS NULL
	BEGIN
		RAISERROR('Il parametro @StatoReferto non è tra i valori possibili! In corso | Completata | Variata | Cancellata', 16, 1)
		RETURN
	END

	IF @SistemaErogante IS NULL
	BEGIN
		RAISERROR('Il parametro @SistemaErogante non può essere NULL!', 16, 1)
		RETURN
	END

	IF @DaData IS NULL
		SET @DaData = DATEADD(day, -30, GETDATE())

	IF @ToData IS NULL
		SET @ToData = GETDATE()

	IF @Simulazione = 1
		PRINT 'Modalità simulazione'

	-- =============================================
	-- Declare and using a READ_ONLY cursor
	-- =============================================
	DECLARE LoopReferti CURSOR
	READ_ONLY
	FOR

	SELECT rb.Id
		,rb.NumeroReferto
		,rb.DataReferto
		,rb.IdEsterno
	FROM store.RefertiBase rb
	WHERE rb.AziendaErogante = @AziendaErogante
		AND rb.SistemaErogante = @SistemaErogante
		AND (rb.RepartoErogante = @RepartoErogante
				OR @RepartoErogante IS NULL)
		AND rb.StatoRichiestaCodice = @StatoRefertoCodice
		AND rb.DataReferto BETWEEN @DaData AND @ToData
		AND (rb.RepartoRichiedenteCodice = @RepartoRichiedenteCodice
				OR @RepartoRichiedenteCodice IS NULL)
		AND (rb.IdEsterno LIKE @LikeIdEsterno + '%'
				OR @LikeIdEsterno IS NULL)

	DECLARE @Id uniqueidentifier
	DECLARE @NumeroReferto varchar(16)
	DECLARE @DataReferto datetime
	DECLARE @IdEsterno varchar(64)

	DECLARE @CancellatoSi int
	DECLARE @CancellatoNo int

	OPEN LoopReferti

	SET @CancellatoSi = 0
	SET @CancellatoNo = 0

	FETCH NEXT FROM LoopReferti INTO @Id, @NumeroReferto, @DataReferto, @IdEsterno
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
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
				--
				-- Cancella veramente
				--

				DECLARE @ret as int
				EXEC @ret = dbo.MntRefertoCancellaPerId @Id

			
				PRINT 'Referto: @Id=' + CONVERT(VARCHAR(40), @Id)
						+ ' @IdEsterno=' + ISNULL( @IdEsterno, 'Nullo')
						+ ' @NumeroReferto=' + ISNULL( @NumeroReferto, 'Nullo')
						+ ' @DataReferto=' + ISNULL(CONVERT(VARCHAR(20), @DataReferto, 102), 'Nullo')

				IF @ret = 0
				BEGIN
					SET @CancellatoSi = @CancellatoSi + 1
				END
				ELSE
				BEGIN
					PRINT 'Referto non cancellato' 
					PRINT ''
					SET @CancellatoNo = @CancellatoNo + 1
				END
			END
		END
		FETCH NEXT FROM LoopReferti INTO @Id, @NumeroReferto, @DataReferto, @IdEsterno
	END

	PRINT ''
	PRINT 'Cancellati: ' + CONVERT(VARCHAR(10), @CancellatoSi)
	PRINT 'Non cancellati: ' + CONVERT(VARCHAR(10), @CancellatoNo)

	CLOSE LoopReferti
	DEALLOCATE LoopReferti
END
