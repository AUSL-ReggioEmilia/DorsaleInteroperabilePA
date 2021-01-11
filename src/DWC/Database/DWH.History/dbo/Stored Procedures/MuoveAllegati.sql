
-- =============================================
-- Author:		Sandro
-- Create date: 2015-08-19
-- Modify date: 2016-09-20 Ritorna il count dei mossi
-- Description:	Muove dati degli allegati nel nuovo campo 
-- =============================================
CREATE PROCEDURE[dbo].[MuoveAllegati]
	@BatchSize INT = 1000
	,@ShowStatistic BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	--Set da muovere
	DECLARE @Muove AS TABLE( ID UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME)
	INSERT INTO @Muove
	SELECT TOP(@BatchSize) Id , [DataPartizione]
		FROM dbo.AllegatiBase
		WHERE MimeStatoCompressione = 0
			AND MimeType IN ('application/pdf', 'application/pkcs7-mime')
			AND MimeData IS NOT NULL
			AND MimeDataOriginale IS NULL

	-- Muove
	UPDATE dbo.AllegatiBase
	SET MimeDataOriginale = CONVERT(VARBINARY(MAX), MimeData)
		, MimeData = NULL
		, MimeStatoCompressione = 3
	WHERE [Id] IN (SELECT Id FROM @Muove)

	--Report di move
	IF @ShowStatistic = 1
		SELECT * FROM @Muove

	RETURN (SELECT COUNT(*) FROM @Muove)
END
