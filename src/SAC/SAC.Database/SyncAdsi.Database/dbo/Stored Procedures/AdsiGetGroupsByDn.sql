

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-09-08
-- Modificato 2016-11-16: Sandro - Se 'displayName' è vuoto leggo 'name'
-- Modificato 2016-11-16: Sandro - Usa SP [dbo].[AdsiGetGroupsByNativeFilter]
-- Modificato 2019-04-29: Sandro - Controlla se @DistinguishedName è NULL
--
-- Description:	Ritorna i gruppo dell'utente per Dn (utente o gruppo)
-- =============================================
CREATE PROCEDURE [dbo].[AdsiGetGroupsByDn]
	@DistinguishedName nvarchar(512)
AS
BEGIN
	--
	-- Raddopio l'apice nel nome per la composizione della query
	--
	DECLARE @QUERY nvarchar(4000)

	IF @DistinguishedName IS NULL
		SET @QUERY = '(1=2)'
	ELSE
		SET @QUERY = '(member=' + REPLACE(@DistinguishedName, '''','''''') + ')'

	EXEC [dbo].[AdsiGetGroupsByNativeFilter] @QUERY
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[AdsiGetGroupsByDn] TO [adsi_dataaccess]
    AS [dbo];

