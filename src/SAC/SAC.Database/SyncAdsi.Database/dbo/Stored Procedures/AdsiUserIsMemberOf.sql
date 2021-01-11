

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
--
-- Description:	Ritorna se l'utente è membro di un gruppo (non recursivo)
-- =============================================
CREATE PROCEDURE [dbo].[AdsiUserIsMemberOf]
         @GroupSamAccountName nvarchar(256),
         @UserSamAccountName nvarchar(256),
         @RetValue int OUTPUT 
AS
BEGIN
	DECLARE @LDAP nvarchar(256)
	DECLARE @QUERY nvarchar(4000)
	DECLARE @EXEC_QUERY nvarchar(4000)
	DECLARE @GROUP_DN nvarchar(512)

	-- Cerco il DN dal nome dell'account
	EXEC dbo.AdsiGetDnBySamAccountName @GroupSamAccountName, @GROUP_DN OUTPUT

	--- Cerco nome LDAP
	SET @LDAP = dbo.ConfigLdapSource()

	--
	-- Encoding dei caratteri speciali
	--
	DECLARE @FilterUser nvarchar(1024) = [dbo].[EncodingLdapFilter](@UserSamAccountName)
	--
	-- Raddopio l'apice per la composizione della query
	--
	SET @FilterUser = REPLACE(@FilterUser, '''', '''''')
	SET @GROUP_DN = REPLACE(@GROUP_DN, '''', '''''')

	--- Compongo la query ADSI e SQL
	SET @QUERY = @LDAP + ';(&(objectClass=user)(memberOf=' + @GROUP_DN + ')(sAMAccountName=' + @FilterUser + '));sAMAccountName;subtree'
	SET @EXEC_QUERY = 'SELECT @RET= COUNT(*) FROM  OPENQUERY(ADSI,''' + @QUERY + ''') AS OrganizationalGroups'

	EXEC sp_executesql @EXEC_QUERY, N'@RET INT OUTPUT', @RetValue OUTPUT
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiUserIsMemberOf] TO [adsi_dataaccess]
    AS [dbo];

