
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2016-03-20
-- Description:	Split string in string
-- =============================================
CREATE FUNCTION [dbo].[StringSplit]
(
	@String AS VARCHAR(MAX), 
	@Separatore AS VARCHAR(16),
	@IgnoraVuoti BIT = 0
)
RETURNS 
@SplitTable TABLE 
(
	Progressivo INT IDENTITY(1,1),
	String VARCHAR(MAX) NULL
)
AS
BEGIN
	DECLARE @SepLen INT = LEN(@Separatore)
	DECLARE @StringLen INT = DATALENGTH(@String)

	DECLARE @Value AS VARCHAR(MAX)

	DECLARE @PosStart INT = 1
	DECLARE @PosNextSep INT = 1
		
	SET @PosNextSep = CHARINDEX(@Separatore, @String, 1)
	IF @PosNextSep = 0
	BEGIN
			-- Aggingo tutto alla tabella, non trovato separatore
			INSERT INTO @SplitTable (String)
			VALUES (@String)

	END	ELSE BEGIN

		WHILE @PosNextSep > 0
		BEGIN
			SET @Value = SUBSTRING(@String, @PosStart, @PosNextSep - @PosStart)
				
			IF @IgnoraVuoti = 0 OR LTRIM(RTRIM(@Value)) <> '' OR @Value IS NULL
			BEGIN
				-- Aggingo all atabella
				INSERT INTO @SplitTable (String)
				VALUES (@Value)
			END

			SET @PosStart = @PosNextSep + @SepLen
			SET @PosNextSep = CHARINDEX(@Separatore, @String, @PosStart)

			IF @PosNextSep = 0 AND @PosStart <= @StringLen
				-- Separatore finale finto se c'è ancora dei dati
				SET @PosNextSep = @StringLen + 1
		END

		-- Come .NET, torna anche l'ultimo vuoto
		IF @IgnoraVuoti = 0 AND RIGHT(@String, @SepLen) = @Separatore
			BEGIN
				-- Aggingo alla tabella
				INSERT INTO @SplitTable (String)
				VALUES ('')
			END
	END

	RETURN 
END