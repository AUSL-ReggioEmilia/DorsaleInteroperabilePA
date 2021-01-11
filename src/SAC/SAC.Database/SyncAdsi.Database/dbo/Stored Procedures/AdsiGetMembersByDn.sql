
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modificato 2016-11-16: Sandro - Se 'displayName' è vuoto leggo 'name'
-- Modificato 2019-04-29: Sandro - Usa la SP [dbo].[AdsiGetMembersNativeFilter]
--
-- Description:	Ritorna i membri del gruppo per Dn di un gruppo
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetMembersByDn]
	@GroupDn nvarchar(512)
AS
BEGIN
	--
	-- Raddopio l'apice nel nome per la composizione della query
	--
	DECLARE @QUERY nvarchar(4000)

	IF @GroupDn IS NULL
		SET @QUERY = '(1=2)'
	ELSE
		SET @QUERY = '(memberOf=' + REPLACE(@GroupDn, '''','''''') + ')'

	EXEC [dbo].[AdsiGetMembersNativeFilter] @QUERY

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetMembersByDn] TO [adsi_dataaccess]
    AS [dbo];

