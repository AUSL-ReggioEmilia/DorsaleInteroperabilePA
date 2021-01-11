
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2018-10-09
-- Modify date: 2019-04-29 Sandro - Esclude oggetti che hanno spazi in fondo al sAMAccountName
--
-- Description:	Ritorna i membri del gruppi per il filtro
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetMembersNativeFilter] 
	 @nativeFilter nvarchar(4000) = NULL
AS
BEGIN

	DECLARE @LDAP nvarchar(256)
	DECLARE @NOT_EMPTY nvarchar(1024) = ''
	DECLARE @QUERY nvarchar(4000)
	DECLARE @EXEC_QUERY nvarchar(4000)

	-- Filtro da config
	DECLARE @FilterGroup nvarchar(1024) = ISNULL([dbo].[ConfigFilterGroup](), '')
	DECLARE @FilterUser nvarchar(1024) = ISNULL([dbo].[ConfigFilterUser](), '')

	--- Cerco nome LDAP
	SET @LDAP = dbo.ConfigLdapSource()

	-- Filtri '' se NULL
	IF @nativeFilter IS NULL
		SET @nativeFilter = ''

	-- Filtri per il controllo dei campi compilati
	IF @FilterGroup = ''
		SET @FilterGroup = 'objectClass=group'
	ELSE
		SET @FilterGroup = '&(objectClass=group)(' + @FilterGroup + ')'

	IF @FilterUser = ''
		SET @FilterUser = 'objectClass=user'
	ELSE
		SET @FilterUser = '&(objectClass=user)(' + @FilterUser + ')'

	--- Compongo la query ADSI e SQL
	SET @QUERY = @LDAP + ';(&(|(' + @FilterUser + ')(' + @FilterGroup + '))' + @nativeFilter + ');'
	SET @QUERY = @QUERY + 'objectGUID, cn, distinguishedName, sAMAccountName, sAMAccountType, displayName, name, mail, whenChanged;subtree'

	SET @EXEC_QUERY = 'SELECT objectGUID, cn, distinguishedName, sAMAccountName, sAMAccountType,'
						+	' COALESCE(displayName, name) AS displayName,'
						+	' mail, whenChanged'
						+ ' FROM  OPENQUERY(ADSI,''' + @QUERY + ''') AS OrganizationalGroups'
						+ ' WHERE LEN(REPLACE(sAMAccountName, '' '', ''#'')) = LEN(REPLACE(RTRIM(sAMAccountName), '' '', ''#''))'

	EXEC sp_executesql @EXEC_QUERY
END

