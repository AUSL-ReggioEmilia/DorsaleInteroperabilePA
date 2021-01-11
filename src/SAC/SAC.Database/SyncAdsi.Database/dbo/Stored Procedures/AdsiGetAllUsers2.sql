﻿
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modify date: 2018-09-14 Sandro Esegue query filtrando per le due lettera del sAMAccountNAme
-- Description:	Sincronizza membri dei gruppi di AD
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetAllUsers2] 
	 @displayNameNotEmpty bit = 0
	,@mailNotEmpty bit = 0
	,@employeeIdNotEmpty bit = 0
	,@employeeNumberNotEmpty bit = 0
	,@DataFrom datetime = NULL
	,@PrintInfo bit = 0
AS
BEGIN
	SET NOCOUNT ON

	--Calcolo Data di modifica
	DECLARE @FilterDataFrom AS NVARCHAR(128)
	IF @DataFrom IS NULL
		SET @FilterDataFrom = ''
	ELSE
	    -- Il fitro non gestisce le differenze sui millisecondi
		SET @FilterDataFrom = '(whenChanged>=' + CONVERT(VARCHAR(40), @DataFrom, 112) +
				REPLACE(CONVERT(VARCHAR(8), @DataFrom, 108), ':', '') + '.0Z)'

	--Lettare 'a' ASCI 97, Lettare 'z' ASCI 122,
	DECLARE @Lettera nvarchar(4000) = NULL
	DECLARE @LetteraDiversa nvarchar(4000) = ''
	DECLARE @LetteraDiversa2 nvarchar(4000) = ''
		
	DECLARE @i INT
	DECLARE @i2 INT
	DECLARE @count INT
	DECLARE @count2 INT
	--
	-- Loop prima lettera
	--
	SET @i = 97
	WHILE @i <= 122
	BEGIN
		--
		-- Loop seconda lettera
		--
		SET @LetteraDiversa2 = ''
		SET @count = 0
		SET @i2 = 97
		WHILE @i2 <= 122
		BEGIN
			--
			-- Filtro per le prime 2 lettere
			--
			SET @Lettera = '(sAMAccountName=' + CHAR(@i) + CHAR(@i2) + '*)' + @FilterDataFrom

			EXEC [dbo].[AdsiGetUsersByNativeFilter] @Lettera, @displayNameNotEmpty ,@mailNotEmpty
															,@employeeIdNotEmpty,@employeeNumberNotEmpty
			SET @count2 = @@ROWCOUNT
			SET @count = @count + @count2
			--
			--Utenti trovati
			--
			IF @PrintInfo = 1
			BEGIN
				PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count2) + ' utenti che iniziano con ''' + CHAR(@i) + CHAR(@i2) +''' filtro:' + @Lettera
			END
			--
			-- Per ricerca sucessiva a fine loop
			--
			IF @count2 > 0
			BEGIN
				SET @LetteraDiversa2 = @LetteraDiversa2 + '(!sAMAccountName=' + CHAR(@i) + CHAR(@i2) + '*)'
			END
			--
			-- Prossima lettera
			--
			SET @i2 = @i2 + 1
		END
		--
		-- Cerco utenti che iniziano con caratteri non a-z
		--
		IF @LetteraDiversa2 <> ''
		BEGIN
			SET @LetteraDiversa2 = '(sAMAccountName=' + CHAR(@i) + '*)' + @LetteraDiversa2
			SET @LetteraDiversa2 = @LetteraDiversa2 + @FilterDataFrom

			EXEC [dbo].[AdsiGetUsersByNativeFilter] @LetteraDiversa2, @displayNameNotEmpty, @mailNotEmpty
																	,@employeeIdNotEmpty,@employeeNumberNotEmpty
			SET @count2 = @@ROWCOUNT

			IF @PrintInfo = 1
			BEGIN
				PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count2) + ' utenti che iniziano non lettere. Filtro: ' + @LetteraDiversa2
			END
		END
		--
		-- Per ricerca sucessiva a fine loop
		--
		IF @count > 0
		BEGIN
			SET @LetteraDiversa = @LetteraDiversa + '(!sAMAccountName=' + CHAR(@i) + '*)'
		END
		--
		-- Prossima lettera
		--
		SET @i = @i + 1
	END
	--
	-- Cerco utenti che iniziano con caratteri non a-z
	--
	IF @LetteraDiversa <> ''
	BEGIN
		SET @LetteraDiversa = @LetteraDiversa + @FilterDataFrom

		EXEC [dbo].[AdsiGetUsersByNativeFilter] @LetteraDiversa, @displayNameNotEmpty, @mailNotEmpty
																,@employeeIdNotEmpty,@employeeNumberNotEmpty
		SET @count = @@ROWCOUNT

		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' utenti che iniziano non lettere. Filtro: ' + @LetteraDiversa
		END
	END

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetAllUsers2] TO [adsi_dataaccess]
    AS [dbo];

