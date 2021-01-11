CREATE PROCEDURE [dbo].[MntPazientiAnteprimaCalcolaAnteprimaReferti]
(
	@MaxNumAnteprimaDaProcessare INTEGER = 1000
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @DateStart DATETIME
	SET @DateStart = GETDATE()	
	--
	-- Cursore 
	--
	DECLARE curAnteprime CURSOR STATIC READ_ONLY
	FOR
	SELECT TOP(@MaxNumAnteprimaDaProcessare)
		IdPaziente
	FROM PazientiAnteprima 
	WHERE NOT CalcolaAnteprimaReferti IS NULL
	ORDER BY CalcolaAnteprimaReferti ASC

	DECLARE @AnteprimeProcessate int
	DECLARE @AnteprimaCorrente int
	DECLARE @AnteprimeDaProcessare int
	DECLARE @Anteprima VARCHAR(2048)
	DECLARE @AnteprimeInErrore int
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	--
	-- Apro il cursore
	--
	OPEN curAnteprime

	SET @AnteprimeProcessate = 0
	SET @AnteprimaCorrente = 0
	SET @AnteprimeInErrore = 0	
	SET @AnteprimeDaProcessare = @@CURSOR_ROWS

	PRINT 'Inizio calcolo anteprima referti: ' + CONVERT(VARCHAR(20) , @DateStart, 120)
	PRINT 'Anteprime da processare: ' + CONVERT(VARCHAR(10), @AnteprimeDaProcessare)

	FETCH NEXT FROM curAnteprime 
	INTO @IdPaziente

	WHILE (@@fetch_status <> -1)
	BEGIN
		SET @AnteprimaCorrente = @AnteprimaCorrente + 1
		IF (@@fetch_status <> -2)
		BEGIN
			BEGIN TRY
				--PRINT CAST(@AnteprimaCorrente AS VARCHAR(10)) + '/' + CAST(@AnteprimeDaProcessare AS VARCHAR(10)) + ' @IdPaziente:' + CAST(@IdPaziente AS VARCHAR(40))
				--
				-- Calcolo l'anteprima
				--
				SELECT @Anteprima = dbo.GetPazientiAnteprimaReferti(@IdPaziente)
				--
				-- Eseguo l'update dell'anteprima
				--
				UPDATE PazientiAnteprima 
					SET CalcolaAnteprimaReferti = NULL
						, AnteprimaReferti = @Anteprima
						, DataModificaAnteprimaReferti = GETDATE()
				WHERE 
					IdPaziente = @IdPaziente
				--
				-- Aggiorno il numero di anteprime processate
				--			
				SET @AnteprimeProcessate = @AnteprimeProcessate + 1
			END TRY
			BEGIN CATCH
				SET @AnteprimeInErrore = @AnteprimeInErrore  + 1
				DECLARE @xact_state INT
				DECLARE @msg NVARCHAR(4000)
				SELECT @xact_state = XACT_STATE(), @msg = ERROR_MESSAGE()
				PRINT ''
				PRINT 'Errore durante calcolo anteprima referti per @IdPaziente: ' + CAST(@IdPaziente AS VARCHAR(40))
				PRINT 'xact_state: ' + CAST(@xact_state AS VARCHAR(10))
				PRINT 'Errore: ' + @msg 
				PRINT 'L''esecuzione prosegue...'				
			END CATCH
		END
		--
		-- Prossima riga
		--
		FETCH NEXT FROM curAnteprime 
		INTO @IdPaziente
	END
	--
	-- Fine
	--
	CLOSE curAnteprime
	DEALLOCATE curAnteprime
	--
	-- Report
	--	
	PRINT 'Num. anteprime processate: ' + CAST(@AnteprimeProcessate AS VARCHAR(10)) + '/' + CAST(@AnteprimeDaProcessare AS VARCHAR(10))
	IF @AnteprimeInErrore > 0 
		PRINT 'Num. anteprime in errore: ' + CAST(@AnteprimeInErrore AS VARCHAR(10)) + '/' + CAST(@AnteprimeDaProcessare AS VARCHAR(10))
	PRINT 'Fine calcolo anteprima referti: durata ' + CAST(DATEDIFF(ms, @DateStart ,GETDATE()) AS VARCHAR(10)) + ' ms'
END
