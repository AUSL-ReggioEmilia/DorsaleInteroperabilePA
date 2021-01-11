

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
--
-- Description:	Ritorna il Dn per SamAccountName
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetDnBySamAccountName] 
	@SamAccountName nvarchar(256),
	@Dn nvarchar(4000) OUTPUT
AS
BEGIN
	DECLARE @LDAP nvarchar(256)
	DECLARE @QUERY nvarchar(4000)
	DECLARE @EXEC_QUERY nvarchar(4000)
	--
	-- Encoding dei caratteri speciali
	--
	DECLARE @FilterSamAccountName nvarchar(1024) = [dbo].[EncodingLdapFilter](@SamAccountName)
	--
	-- Raddopio l'apice per la composizione della query
	--
	SET @FilterSamAccountName = REPLACE(@FilterSamAccountName, '''', '''''')

	--- Cerco nome LDAP
	SET @LDAP = dbo.ConfigLdapSource()

	--- Compongo la query ADSI e SQL
	SET @QUERY = @LDAP + ';(&(|(objectClass=group)(objectClass=user))(sAMAccountName=' + @FilterSamAccountName + '));distinguishedName;subtree'
	SET @EXEC_QUERY = 'SELECT TOP 1 @RET=distinguishedName FROM  OPENQUERY(ADSI,''' + @QUERY + ''') AS OrganizationalGroups'

	EXEC sp_executesql @EXEC_QUERY, N'@RET nvarchar(4000) OUTPUT', @Dn OUTPUT
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetDnBySamAccountName] TO [adsi_dataaccess]
    AS [dbo];

