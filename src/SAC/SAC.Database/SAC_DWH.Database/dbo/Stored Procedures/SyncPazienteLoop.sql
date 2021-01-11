
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2012-03-12
-- Description:	Sync Paziente Attributi tutti
-- =============================================
CREATE PROCEDURE [dbo].[SyncPazienteLoop]
	 @DaData datetime = NULL
	,@ToData datetime = NULL
	,@MaxPazienti int = 1000
	,@Simulazione bit = 1
AS
BEGIN

	SET NOCOUNT ON

	IF @DaData IS NULL
		SET @DaData = DATEADD(day, -30, GETDATE())

	IF @ToData IS NULL
		SET @ToData = GETDATE()

	IF @Simulazione = 1
		PRINT 'Modalità simulazione'

	IF @MaxPazienti < 1
	BEGIN
		PRINT 'Parametro errato, @MaxPazienti deve essere > 0!'
		RETURN 1
	END

	-- =============================================
	-- Declare and using a READ_ONLY cursor
	-- =============================================
	DECLARE LoopPazienti CURSOR STATIC READ_ONLY
		FOR
		SELECT TOP(@MaxPazienti) pb.Id, pb.DataModifica
			FROM DwhCLinico_PazientiBase pb INNER JOIN
					Sac_PazientiOutput2 po 
				ON pb.Id = po.Id
			WHERE pb.DataModifica BETWEEN @DaData AND @ToData
				AND NOT pb.Id IN (SELECT IdPazientiBase FROM  DwhCLinico_PazientiAttributi
									WHERE Nome = 'SyncPaziente')
			ORDER BY pb.DataModifica DESC

	DECLARE @Id uniqueidentifier
	DECLARE @DataModifica datetime

	DECLARE @SyncCount int
	DECLARE @SyncFatti int
	DECLARE @SyncError int

	OPEN LoopPazienti
	FETCH NEXT FROM LoopPazienti INTO @Id, @DataModifica
	
	SET @SyncCount = @@CURSOR_ROWS 
	SET @SyncFatti = 0
	SET @SyncError = 0
	
	PRINT 'Trovati ' + ISNULL(CONVERT(VARCHAR(10), @SyncCount), '0') + ' pazienti!'
	
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			PRINT 'Paziente: @Id=' + CONVERT(VARCHAR(40), @Id)
						+ ' @DataModifica=' +  CONVERT(VARCHAR(20), @DataModifica, 120)

			IF @Simulazione = 1
			BEGIN
				-- Simula Change Id
				---
				SET @SyncError = @SyncError + 1
			END
			ELSE
			BEGIN
				-- sync veramente
				---
				DECLARE	@return_value int = 0

				IF NOT @Id IS NULL
				BEGIN
					--
					-- Id SAC trovato, change
					--
					EXEC @return_value = [dbo].[SyncPazienteById] @Id
					IF @return_value > 0
					BEGIN
						PRINT '--- Errore, paziente non cambiato' 
						PRINT ''
						SET @SyncError = @SyncError + 1
					END
				END
				ELSE
				BEGIN
					PRINT '--- IdSac non trovato!' 
					PRINT ''
					SET @SyncError = @SyncError + 1
				END
			END
		END
		FETCH NEXT FROM LoopPazienti INTO @Id, @DataModifica
		
		SET @SyncFatti = @SyncFatti + 1
		PRINT 'Fatti ' + CONVERT(VARCHAR(10), @SyncFatti) +
					' di ' + CONVERT(VARCHAR(10), @SyncCount)
		PRINT ''
	END

	PRINT ''
	PRINT 'Totale pazienti: ' + CONVERT(VARCHAR(10), @SyncCount)
	PRINT 'Errori rilevati: ' + CONVERT(VARCHAR(10), @SyncError)

	CLOSE LoopPazienti
	DEALLOCATE LoopPazienti
END

