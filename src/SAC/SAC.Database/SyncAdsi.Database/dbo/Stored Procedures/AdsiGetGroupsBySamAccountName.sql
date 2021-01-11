

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modificato 2016-11-16: Sandro - Se 'displayName' è vuoto leggo 'name'
-- Modificato 2018-10-02: Sandro - Usa SP AdsiGetGroupsByDn
--
-- Description:	Ritorna i gruppo dell'utente per SamAccountName (utente o gruppo)
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetGroupsBySamAccountName]
	@UserSamAccountName nvarchar(256)
AS
BEGIN

	DECLARE @USER_DN nvarchar(4000)

	-- Cerco il DN dal nome dell'account
	EXEC dbo.AdsiGetDnBySamAccountName @UserSamAccountName, @USER_DN OUTPUT
	EXEC dbo.AdsiGetGroupsByDn @USER_DN
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetGroupsBySamAccountName] TO [adsi_dataaccess]
    AS [dbo];

