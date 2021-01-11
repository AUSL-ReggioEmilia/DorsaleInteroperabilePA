
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2017-04-27
-- Description:	Consuma la cosa di OUTPUT delle prescrizioni simulando l'invio, processando il prarsing HL7
-- =============================================
CREATE PROCEDURE [dbo].[MntPrescrizioniProcessaOutput]
(
 @MaxLoop INTEGER = 0
,@LoopPauseMillisec INTEGER = 0
)
AS
BEGIN
--
--
--
	SET NOCOUNT ON

	DECLARE @DelayTime CHAR(12) = CONVERT(TIME, DATEADD(MILLISECOND, @LoopPauseMillisec, '00:00:00.000'))
	DECLARE @LoopCount INT = 0

	DECLARE @Found INT = 1
	DECLARE @Added INT = 0
	DECLARE @Err INT = 0

	DECLARE @tableCount TABLE (CountCoda INT)
 
	WHILE (@Found > 0) AND (@Err = 0) AND (@LoopCount < @MaxLoop OR @MaxLoop = 0)
	BEGIN
		--
		-- Reset found
		--
		SET @Found = 0
		--
		-- Conta i record pending
		--
		INSERT INTO @tableCount EXEC [dbo].[BtCodaPrescrizioniOutputConta]

		SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
		IF @Err <> 0 GOTO ERR_EXIT
		--
		-- Se trovati processo coda
		--
		SELECT @Found = CountCoda FROM @tableCount
		IF @Found > 0
		BEGIN
			--
			-- SIMULO invia notifica, per ora processa solo i dati HL7
			--
			EXEC [dbo].[BtCodaPrescrizioniOutputOttieni]
			
			SELECT @Err = @@ERROR, @Added = @@ROWCOUNT
			IF @Err <> 0 GOTO ERR_EXIT
			--
			-- Numero di loop
			--
			SET @LoopCount = @LoopCount + 1
		END
		--
		-- Inserisce una pausa
		--
		IF @LoopPauseMillisec > 0 
			WAITFOR DELAY @DelayTime

	END
	
	PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Processati ' + CONVERT(VARCHAR(10), @LoopCount) + ' messaggi in coda.'
	RETURN 0

	ERR_EXIT:
		--
		-- Errore
		--
		IF @Err > 0
			PRINT CONVERT(VARCHAR(20), GETDATE(), 120) + ': Errore ' + CONVERT(VARCHAR(10), @Err)
		
		RETURN @Err
END