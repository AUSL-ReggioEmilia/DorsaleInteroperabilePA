



-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modify date: 2018-09-14 Sandro Esegue query filtrando per la prima lettera del sAMAccountNAme
-- Description:	Sincronizza membri dei gruppi di AD
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetAllUsers] 
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
		
	DECLARE @i INT
	DECLARE @count INT
	
	SET @i = 97
	WHILE @i <= 122
	BEGIN
		SET @Lettera = '(sAMAccountName=' + CHAR(@i) + '*)' + @FilterDataFrom
		EXEC [dbo].[AdsiGetUsersByNativeFilter] @Lettera, @displayNameNotEmpty ,@mailNotEmpty
														,@employeeIdNotEmpty,@employeeNumberNotEmpty
		SET @count = @@ROWCOUNT
		--
		--Utenti trovati
		--
		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' utenti che iniziano con ''' + CHAR(@i) +'''. Filtro: ' + @Lettera
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
		SET @LetteraDiversa = @LetteraDiversa + @FilterDataFrom

		EXEC [dbo].[AdsiGetUsersByNativeFilter] @LetteraDiversa, @displayNameNotEmpty, @mailNotEmpty
																,@employeeIdNotEmpty,@employeeNumberNotEmpty
		SET @count = @@ROWCOUNT

		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' utenti con inizo non lettera. Filtro: ' + @LetteraDiversa
		END
	END

END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetAllUsers] TO [adsi_dataaccess]
    AS [dbo];

