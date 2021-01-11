
-- =============================================
-- Author:		Sandro
-- Create date: 2015-10-12
-- Description:	UNDU compressione dati degli allegati
-- =============================================
CREATE PROCEDURE[dbo].[CompressioneAllegatiUndo]
	@BatchSize INT = 1000
AS
BEGIN

	-- Decomprime
	UPDATE TOP(@BatchSize) dbo.AllegatiBase
	SET MimeData = CONVERT(IMAGE, dbo.decompress(MimeDataCompresso))
		, MimeStatoCompressione = 0
		, MimeDataCompresso = NULL
	WHERE MimeStatoCompressione = 2

	-- Muove
	UPDATE TOP(@BatchSize) dbo.AllegatiBase
	SET MimeData = CONVERT(IMAGE, MimeDataOriginale)
		, MimeStatoCompressione = 0
		, MimeDataOriginale = NULL
	WHERE MimeStatoCompressione = 3
		AND MimeDataOriginale IS NOT NULL

	-- Reset stato
	UPDATE TOP(@BatchSize) dbo.AllegatiBase
	SET	  MimeStatoCompressione = 0
	WHERE MimeStatoCompressione = 3
		AND MimeData IS NOT NULL

END
