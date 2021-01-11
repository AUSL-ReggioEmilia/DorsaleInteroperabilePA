

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modify date: 2018-09-14 Sandro rimosso filtro DL (!sAMAccountType=268435457)
--									Ora è configurato
-- Description:	Sincronizza membri dei gruppi di AD
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetAllGroups] 
	 @displayNameNotEmpty bit = 0
	,@mailNotEmpty bit = 0
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

	DECLARE @Esclude nvarchar(4000) = '(!sAMAccountName=adb-*)(!sAMAccountName=usl-*)(!sAMAccountName=dlb-*)'
	
	DECLARE @i INT
	DECLARE @count INT
	
	SET @i = 97
	WHILE @i <= 122
	BEGIN
		SET @Lettera = '(sAMAccountName=' + CHAR(@i) + '*)' + @FilterDataFrom + @Esclude
		EXEC [dbo].[AdsiGetGroupsByNativeFilter] @Lettera, @displayNameNotEmpty ,@mailNotEmpty
		SET @count = @@ROWCOUNT

		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' gruppi che iniziano con ''' + CHAR(@i) +'''. Filtro: ' + @Lettera
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
	-- Cerco gruppi che inizian con caratteri non a-z
	--
	IF @LetteraDiversa <> ''
	BEGIN
		SET @LetteraDiversa = @LetteraDiversa + @FilterDataFrom + @Esclude

		EXEC [dbo].[AdsiGetGroupsByNativeFilter] @LetteraDiversa, @displayNameNotEmpty ,@mailNotEmpty
		SET @count = @@ROWCOUNT

		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' gruppi con inizo non lettera. Filtro: ' + @LetteraDiversa
		END
	END
	--
	-- Gruppi numerosi 'adb' e 'usl'
	--
	SET @i = 97
	WHILE @i <= 122
	BEGIN

		SET @Lettera = '(sAMAccountName=adb-' + CHAR(@i) + '*)' + @FilterDataFrom
		EXEC [dbo].[AdsiGetGroupsByNativeFilter] @Lettera, 0 , 0
		SET @count = @@ROWCOUNT

		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' gruppi con inizo ''adb-' + CHAR(@i) +'''. Filtro: ' + @Lettera
		END

		SET @Lettera = '(sAMAccountName=usl-' + CHAR(@i) + '*)' + @FilterDataFrom
		EXEC [dbo].[AdsiGetGroupsByNativeFilter] @Lettera, 0 , 0
		SET @count = @@ROWCOUNT

		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' gruppi con inizo ''usl-' + CHAR(@i) +'''. Filtro: ' + @Lettera
		END

		SET @Lettera = '(sAMAccountName=dlb-' + CHAR(@i) + '*)' + @FilterDataFrom
		EXEC [dbo].[AdsiGetGroupsByNativeFilter] @Lettera, 0 , 0
		SET @count = @@ROWCOUNT

		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' gruppi con inizo ''dlb-' + CHAR(@i) +'''. Filtro: ' + @Lettera
		END

		SET @i = @i + 1
	END
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetAllGroups] TO [adsi_dataaccess]
    AS [dbo];

