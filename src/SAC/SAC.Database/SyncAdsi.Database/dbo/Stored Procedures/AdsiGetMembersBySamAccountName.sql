

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modificato 2016-11-16: Sandro - Se 'displayName' è vuoto leggo 'name'
-- Modificato 2018-10-02: Sandro - Usa SP AdsiGetMembersByDn
--
-- Description:	Ritorna i membri del gruppo per SamAccountName del gruppo
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetMembersBySamAccountName]
	@GroupSamAccountName nvarchar(256)
AS
BEGIN
	DECLARE @GROUP_DN nvarchar(4000)

	-- Cerco il DN dal nome dell'account
	EXEC dbo.AdsiGetDnBySamAccountName @GroupSamAccountName, @GROUP_DN OUTPUT
	EXEC [dbo].[AdsiGetMembersByDn] @GROUP_DN
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetMembersBySamAccountName] TO [adsi_dataaccess]
    AS [dbo];

