
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-11-06
--
-- Description:	Ritorna i gruppi con uno spazio in fondo al nome
--				Il sincronizzatore li scarta
-- =============================================
CREATE PROCEDURE [dbo].[DebugGetGroupsWithSpaceInName] 
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @LDAP nvarchar(256)
	DECLARE @NOT_EMPTY nvarchar(1024) = ''
	DECLARE @QUERY nvarchar(4000)
	DECLARE @EXEC_QUERY nvarchar(4000)

	-- Filtro da config
	DECLARE @FilterGroup VARCHAR(1024) = ISNULL([dbo].[ConfigFilterGroup](), '')

	--- Cerco nome LDAP
	SET @LDAP = dbo.ConfigLdapSource()

	--- Compongo la query ADSI e SQL
	SET @QUERY = @LDAP + ';(&(objectClass=group)(sAMAccountName=* )' + @FilterGroup + ');'
	SET @QUERY = @QUERY + 'objectGUID, cn, distinguishedName, sAMAccountName, sAMAccountType, displayName, name, mail, whenChanged;subtree'

	SET @EXEC_QUERY = 'SELECT objectGUID, cn, distinguishedName, sAMAccountName, sAMAccountType,'
						+	' COALESCE(displayName, name) AS displayName,'
						+	' mail, whenChanged'
						+ ' FROM  OPENQUERY(ADSI,''' + @QUERY + ''') AS OrganizationalGroups'
						--+ ' WHERE LEN(REPLACE(sAMAccountName, '' '', ''#'')) <> LEN(REPLACE(RTRIM(sAMAccountName), '' '', ''#''))'
	
	EXEC sp_executesql @EXEC_QUERY
END