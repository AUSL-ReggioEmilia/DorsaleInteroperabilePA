
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modify date: 2016-11-16 Sandro - Se 'displayName' è vuoto leggo 'name'
-- Modify date: 2018-10-02 Sandro - Aggiunto filtro da config
-- Modify date: 2019-04-29 Sandro - Esclude oggetti che hanno spazi in fondo al sAMAccountName
--
-- Description:	Ritorna gli utenti per il filtro
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetUsersByNativeFilter] 
	 @nativeFilter nvarchar(4000) = NULL
	,@displayNameNotEmpty bit = 0
	,@mailNotEmpty bit = 0
	,@employeeIdNotEmpty bit = 0
	,@employeeNumberNotEmpty bit = 0
AS
BEGIN
	DECLARE @LDAP nvarchar(256)
	DECLARE @ATTRIB_CF nvarchar(256)
	DECLARE @ATTRIB_MATRICOLA nvarchar(256)

	DECLARE @NOT_EMPTY nvarchar(4000) = ''
	DECLARE @QUERY nvarchar(4000)
	DECLARE @EXEC_QUERY nvarchar(4000)

	-- Filtro da config
	DECLARE @FilterUser nvarchar(1024) = ISNULL([dbo].[ConfigFilterUser](), '')

	--- Cerco nome LDAP e altre config
	SET @LDAP = dbo.ConfigLdapSource()
	SET @ATTRIB_CF = ISNULL(dbo.ConfigAttributoCodiceFiscale(), 'employeeId')
	SET @ATTRIB_MATRICOLA = ISNULL(dbo.ConfigAttributoMatricola(), 'employeeNumber')

	-- Filtri '' se NULL
	IF @nativeFilter IS NULL
		SET @nativeFilter = ''

	-- Filtri per il controllo dei campi compilati
	IF @displayNameNotEmpty = 1
		SET @NOT_EMPTY =@NOT_EMPTY + '(displayName=*)'

	IF @mailNotEmpty = 1
		SET @NOT_EMPTY = @NOT_EMPTY + '(mail=*)'
		
	IF @employeeIdNotEmpty = 1
		SET @NOT_EMPTY = @NOT_EMPTY + '(employeeId=*)'
		
	IF @employeeNumberNotEmpty = 1
		SET @NOT_EMPTY = @NOT_EMPTY + '(employeeNumber=*)'

	--- Compongo la query ADSI e SQL
	SET @QUERY = @LDAP + ';(&(objectClass=user)(objectCategory=person)' + @NOT_EMPTY + @nativeFilter + @FilterUser + ');'
						+ 'objectGUID, cn, distinguishedName, sAMAccountName, sAMAccountType, displayName, sn, givenName, mail'
						+ ', ' + @ATTRIB_CF + ', ' + @ATTRIB_MATRICOLA
						+ ', whenChanged, userAccountControl;subtree'

	SET @EXEC_QUERY = 'SELECT objectGUID, cn, distinguishedName, sAMAccountName, sAMAccountType, displayName, sn, givenName, mail'
							+		', ' + @ATTRIB_CF + ' AS codiceFiscale , ' + @ATTRIB_MATRICOLA + ' AS matricola'
							+		', whenChanged'
							+ ' FROM  OPENQUERY(ADSI,''' + @QUERY + ''') AS OrganizationalUsers'
							+ ' WHERE CONVERT(bit, userAccountControl & 0x0002) = 0'
							+ ' AND LEN(REPLACE(sAMAccountName, '' '', ''#'')) = LEN(REPLACE(RTRIM(sAMAccountName), '' '', ''#''))'

	EXEC sp_executesql @EXEC_QUERY
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetUsersByNativeFilter] TO [adsi_dataaccess]
    AS [dbo];

