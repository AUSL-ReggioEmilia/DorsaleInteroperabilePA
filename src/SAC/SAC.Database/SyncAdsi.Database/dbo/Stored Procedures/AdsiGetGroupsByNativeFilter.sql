

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modify date: 2016-11-16 Sandro - Se 'displayName' è vuoto leggo 'name'
-- Modify date: 2018-10-02 Sandro - Aggiunto filtro da config
-- Modify date: 2019-04-29 Sandro - Esclude oggetti che hanno spazi in fondo al sAMAccountName
--
-- Description:	Ritorna i gruppi per il filtro
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetGroupsByNativeFilter] 
	 @nativeFilter nvarchar(4000) = NULL
	,@displayNameNotEmpty bit = 0
	,@mailNotEmpty bit = 0
AS
BEGIN

	DECLARE @LDAP nvarchar(256)
	DECLARE @NOT_EMPTY nvarchar(1024) = ''
	DECLARE @QUERY nvarchar(4000)
	DECLARE @EXEC_QUERY nvarchar(4000)

	-- Filtro da config
	DECLARE @FilterGroup VARCHAR(1024) = ISNULL([dbo].[ConfigFilterGroup](), '')

	--- Cerco nome LDAP
	SET @LDAP = dbo.ConfigLdapSource()

	-- Filtri '' se NULL
	IF @nativeFilter IS NULL
		SET @nativeFilter = ''

	-- Filtri per il controllo dei campi compilati
	IF @displayNameNotEmpty = 1
		SET @NOT_EMPTY = @NOT_EMPTY + '(|(displayName=*)(name=*))'

	IF @mailNotEmpty = 1
		SET @NOT_EMPTY = @NOT_EMPTY + '(mail=*)'

	--- Compongo la query ADSI e SQL
	SET @QUERY = @LDAP + ';(&(objectClass=group)' + @NOT_EMPTY + @nativeFilter + @FilterGroup + ');'
	SET @QUERY = @QUERY + 'objectGUID, cn, distinguishedName, sAMAccountName, sAMAccountType, displayName, name, mail, whenChanged;subtree'

	SET @EXEC_QUERY = 'SELECT objectGUID, cn, distinguishedName, sAMAccountName, sAMAccountType,'
						+	' COALESCE(displayName, name) AS displayName,'
						+	' mail, whenChanged'
						+ ' FROM  OPENQUERY(ADSI,''' + @QUERY + ''') AS OrganizationalGroups'
						+ ' WHERE LEN(REPLACE(sAMAccountName, '' '', ''#'')) = LEN(REPLACE(RTRIM(sAMAccountName), '' '', ''#''))'
	
	EXEC sp_executesql @EXEC_QUERY
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetGroupsByNativeFilter] TO [adsi_dataaccess]
    AS [dbo];

