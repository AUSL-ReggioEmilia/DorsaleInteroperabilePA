

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modificato 2016-11-16: Sandro - Se 'displayName' è vuoto leggo 'name'
-- Modificato 2018-10-09: Sandro - Usa la nuova [dbo].[AdsiGetMembersNativeFilter]
-- Modificato 2019-04-29: Sandro - Controlla se @GroupDn è NULL
--
-- Description:	Ritorna i membri del gruppo per Dn di un gruppo
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetMembersByDn2]
 @GroupDn nvarchar(512)
,@PrintInfo bit = 0
AS
BEGIN

	DECLARE @FilterMemberOfDnGroup nvarchar(4000)

	IF @GroupDn IS NULL
		SET @FilterMemberOfDnGroup = '(1=2)'
	ELSE
		SET @FilterMemberOfDnGroup = '(memberOf=' + REPLACE(@GroupDn, '''','''''') + ')'

--Lettare 'a' ASCI 97, Lettare 'z' ASCI 122,
	DECLARE @Lettera nvarchar(4000) = NULL
	DECLARE @LetteraDiversa nvarchar(4000) = ''
		
	DECLARE @i INT
	DECLARE @count INT
	
	SET @i = 97
	WHILE @i <= 122
	BEGIN
		SET @Lettera = '(sAMAccountName=' + CHAR(@i) + '*)' + @FilterMemberOfDnGroup
		EXEC [dbo].[AdsiGetMembersNativeFilter] @Lettera

		SET @count = @@ROWCOUNT
		--
		--Utenti trovati
		--
		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' membri che iniziano con ''' + CHAR(@i) +'''. Filtro: ' + @Lettera
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
		SET @LetteraDiversa = @LetteraDiversa + @FilterMemberOfDnGroup
		EXEC [dbo].[AdsiGetMembersNativeFilter] @LetteraDiversa

		SET @count = @@ROWCOUNT

		IF @PrintInfo = 1
		BEGIN
			PRINT 'Trovati ' + CONVERT(VARCHAR(10), @count) + ' membri con inizo non lettera. Filtro: ' + @LetteraDiversa
		END
	END

END

