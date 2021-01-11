
-- =============================================
-- Author:		Ettore
-- Create date: 2016-05-16
-- Description:	Esegue parsing della stringa AnteprimaReferti per ottenere i dati: Numeroreferti, Sistema e data dell'ultimo referto
-- Modify date: 2017-06-29 ETTORE: aumentata la dimensione del campo UltimoRefertoSistemaErogante - ora si usa la descrizione del sistema erogante
-- =============================================
CREATE FUNCTION [dbo].[ParseAnteprimaReferti]
(
	@Anteprima VARCHAR(2048)
)
RETURNS @RetTable TABLE (NumeroReferti INT, UltimoRefertoSistemaErogante VARCHAR(128), UltimoRefertoData DATETIME)
AS
BEGIN
	DECLARE @TempTable TABLE (Progressivo INT, String VARCHAR(MAX))
	-----------------------------------
	DECLARE @NumeroReferti INT = 0
	DECLARE @UltimoRefertoData DATETIME
	DECLARE @UltimoRefertoSistemaErogante VARCHAR(128)
	-----------------------------------
	IF NOT @Anteprima IS NULL
	BEGIN
		INSERT INTO @TempTable (Progressivo, String)
		SELECT Progressivo, String FROM dbo.StringSplit(@Anteprima , '<br/>', 0) 

		DECLARE @Stringa VARCHAR(2048)
		DECLARE @PosStart AS INT 
		DECLARE @PosEnd AS INT 
		SELECT @Stringa = [String] FROM @TempTable  WHERE [String] like '%Numero referti:%'
		IF ISNULL(@Stringa , '') <> ''
		BEGIN
			--
			-- Prelevo il count dei referti
			-- Esempio: 'Numero referti: 3'
			--
			SET @PosStart = CHARINDEX(':', @Stringa) 
			SET @PosEnd = LEN(@Stringa) - 1
			IF @PosEnd <> 0 AND @PosStart <> 0
				SET @NumeroReferti = SUBSTRING(@Stringa, @PosStart + 1, @PosEnd-@PosStart + 1)
			--
			-- Ora leggo per trovare Sistema ultimo referto e data ultimo referto
			--
			SELECT @Stringa = [String] FROM @TempTable  WHERE [String] like '%Ultimo referto:%'	
			IF ISNULL(@Stringa , '') <> ''
			BEGIN
				--
				-- Prelevo il sistema
				--
				SET @PosStart = CHARINDEX(':', @Stringa) 
				SET @PosEnd = CHARINDEX('(', @Stringa, @PosStart + 1) 
				IF @PosEnd <> 0 AND @PosStart <> 0
					SET @UltimoRefertoSistemaErogante = RTRIM(LTRIM(SUBSTRING(@Stringa, @PosStart + 1, @PosEnd-@PosStart -1)))
				--
				-- Prelevo data ultimo referto
				--
				DECLARE @DataStringa AS VARCHAR(10)
				SET @PosStart = CHARINDEX('(', @Stringa) 
				SET @PosEnd = CHARINDEX(')', @Stringa, @PosStart + 1) 
				--
				-- Se ho trovato '(' e ')'
				-- 
				IF @PosEnd <> 0 AND @PosStart <> 0
				BEGIN 
					SET @DataStringa = SUBSTRING(@Stringa, @PosStart + 1, @PosEnd-@PosStart -1)
					--
					-- La data è scritta nel formato gg/MM/AAAA (format=103)
					--
					DECLARE @Day VARCHAR(2) = SUBSTRING(@DataStringa, 1, 2)
					DECLARE @Month VARCHAR(2) = SUBSTRING(@DataStringa, 4, 2)
					DECLARE @Year VARCHAR(4) = SUBSTRING(@DataStringa, 7, 4) 
					DECLARE @DateODBCFormat AS VARCHAR(10) = @Year + '-' + @Month + '-' + @Day
					--Verifico se è una data:
					IF ISDATE(@DateODBCFormat) = 1
						SET @UltimoRefertoData = CONVERT(datetime, @DataStringa , 103) 
				END 
			END
		END
	END
	--
	-- Valorizzo tabella da restituire
	--
	INSERT INTO @RetTable(NumeroReferti, UltimoRefertoSistemaErogante , UltimoRefertoData)
	SELECT @NumeroReferti AS NumeroReferti,
		@UltimoRefertoSistemaErogante AS SistemaUltimoreferto,
		@UltimoRefertoData AS DataUltimoReferto 
	--
	-- Restituisco
	--	
	RETURN 
END