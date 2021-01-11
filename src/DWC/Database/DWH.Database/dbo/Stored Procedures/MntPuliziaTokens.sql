


-- =============================================
-- Author:		ETTORE
-- Create date: 2015-11-30
-- Description:	Cancellazione dei token obsoleti: @TTLHour = TIME TO LIVE in ore. Vengono cancellati i token più vecchi di @TTLHour
-- =============================================
CREATE PROCEDURE [dbo].[MntPuliziaTokens]
(
	@MaxNum INT = 1000
	, @TTLHour INT = 48
)
AS
BEGIN
	SET NOCOUNT ON;
 	DECLARE @TempTab TABLE(Id UNIQUEIDENTIFIER)	
 	DECLARE @NumRowDelete INT = 0
	DECLARE @T0 AS datetime
 	SET @T0 = GETDATE()
	--
	-- Sistemazione e visualizzazione dei parametri
	--
	IF @TTLHour < 24 
		SET @TTLHour = 24
	PRINT '@MaxNum=' + CAST(@MaxNum AS VARCHAR(10))
	PRINT '@TTLHour=' + CAST(@TTLHour AS VARCHAR(10))
 	--
 	-- Ricavo la data minima oltre la quale cancellare
 	--
 	DECLARE @MinValidDate DATETIME
 	SET @MinValidDate = DATEADD(HH, -@TTLHour, GETDATE())
	
 	BEGIN TRY
		--
		-- Memorizzo gli id da cancellare
		-- 	
 		INSERT INTO @TempTab (Id)
 		SELECT TOP (@MaxNum) Id FROM dbo.Tokens 
 		WHERE DataInserimento < @MinValidDate
 		ORDER BY DataInserimento 
 		SELECT @NumRowDelete = @@ROWCOUNT  		
		--
		-- Cancellazione
		-- 	
		IF @NumRowDelete > 0
 		BEGIN
 			DELETE FROM dbo.Tokens 
 			WHERE Id IN (SELECT Id FROM @TempTab)
 		END
		--
		-- Report
		--	
		PRINT 'Record cancellati=' + CAST(@NumRowDelete AS VARCHAR(10))
		PRINT 'Durata=' + CAST(DATEDIFF(ms, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'
		PRINT 'Fine'
 		
 	END TRY
 	BEGIN CATCH
		DECLARE @xact_state INT
		DECLARE @msg NVARCHAR(2000)
		SELECT @xact_state = xact_state(), @msg = error_message()
		DECLARE @report NVARCHAR(4000);
		SELECT @report = N'MntPuliziaTokens: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
		PRINT '---------------------------'
		PRINT @report;						
		PRINT '---------------------------' 	
 	END CATCH
END