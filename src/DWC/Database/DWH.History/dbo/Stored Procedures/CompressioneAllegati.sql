
-- =============================================
-- Author:		Sandro
-- Create date: 2015-08-19
-- Modify date: 2015-09-29 Salva il Ratio della compressione
-- Modify date: 2015-10-02 Muove nel nuovo campo
-- Modify date: 2015-10-06 Legge da ISNULL(MimeDataOriginale, MimeData) e comprime
--                         Se maggiore, muove nel nuovo MimeDataOriginale
-- Modify date: 2015-10-12 Riscritta per problemi di prestazione in comparazione
--
-- Description:	Comprime dati degli allegati
-- =============================================
CREATE PROCEDURE[dbo].[CompressioneAllegati]
	@BatchSize INT = 1000
	,@ShowStatistic BIT = 0
	,@ExcludePdf BIT = 1
AS
BEGIN
	SET NOCOUNT ON;

	--SET da comprimere
	DECLARE @Compressi AS TABLE( ID UNIQUEIDENTIFIER, DataPartizione SMALLDATETIME
								, MimeDataLength REAL, MimeCompressoLength REAL
								, MimeDataChecksum INT,  MimeDecompressoChecksum INT
								, MimeDataCompresso VARBINARY(MAX))

	INSERT INTO @Compressi ([Id] , [DataPartizione], [MimeDataLength], [MimeDataChecksum], [MimeDataCompresso])
	SELECT TOP(@BatchSize) [Id] , [DataPartizione]
			,CONVERT(REAL, DATALENGTH(ISNULL(MimeDataOriginale, MimeData))) AS MimeDataLength
			,CHECKSUM(CONVERT(VARBINARY(MAX), ISNULL(MimeDataOriginale, MimeData))) AS MimeDataChecksum
			,dbo.compress(ISNULL(AllegatiBase.MimeDataOriginale, CONVERT(VARBINARY(MAX), AllegatiBase.MimeData)))
	FROM dbo.AllegatiBase WITH (INDEX(IX_MimeStatoComp_MimeType))
	WHERE MimeStatoCompressione = 0
		AND (NOT MimeType IN ('application/pdf', 'application/pkcs7-mime') OR @ExcludePdf = 0)

	-- Aggiorna per comparazione
	UPDATE @Compressi
		SET MimeCompressoLength = CONVERT(REAL, DATALENGTH(MimeDataCompresso))
			, MimeDecompressoChecksum = CHECKSUM(dbo.decompress(MimeDataCompresso))

	--Report da comprimere
	IF @ShowStatistic = 1
		SELECT ID, DataPartizione
			, MimeDataLength, MimeCompressoLength
			, MimeDataChecksum, MimeDecompressoChecksum
		FROM @Compressi

	-- Salva dati compressi se minori e se checksum ok
	UPDATE dbo.AllegatiBase
	SET MimeDataCompresso = Compressi.MimeDataCompresso
		, MimeData = NULL
		, MimeDataOriginale = NULL
		, MimeStatoCompressione = 2
	FROM @Compressi Compressi INNER JOIN dbo.AllegatiBase
		ON Compressi.[Id] = AllegatiBase.[Id]
	WHERE Compressi.MimeDataChecksum = Compressi.MimeDecompressoChecksum
		AND Compressi.MimeCompressoLength < Compressi.MimeDataLength

	-- Altrimenti sposta originale nel nuovo campo
	UPDATE dbo.AllegatiBase
	SET MimeDataOriginale = ISNULL(AllegatiBase.MimeDataOriginale, CONVERT(VARBINARY(MAX), AllegatiBase.MimeData))
		, MimeData = NULL
		, MimeDataCompresso = NULL
		, MimeStatoCompressione = CASE WHEN Compressi.MimeDataChecksum != Compressi.MimeDecompressoChecksum THEN 1 ELSE 3 END
	FROM @Compressi Compressi INNER JOIN dbo.AllegatiBase
		ON Compressi.[Id] = AllegatiBase.[Id]
	WHERE Compressi.MimeCompressoLength >= Compressi.MimeDataLength
		OR Compressi.MimeDataChecksum != Compressi.MimeDecompressoChecksum
		OR (Compressi.MimeCompressoLength IS NULL AND Compressi.MimeDataLength IS NULL)

	--Aggiungo agli attributi statistiche di compressione
	DELETE FROM [dbo].[AllegatiAttributi]
	WHERE [IdAllegatiBase] IN (SELECT Id FROM @Compressi)
		AND [Nome] IN ('CompressionRatio', 'MimeDataLength')
	
	INSERT INTO [dbo].[AllegatiAttributi] ([IdAllegatiBase] ,[DataPartizione],[Nome],[Valore])
	SELECT Compressi.ID, Compressi.DataPartizione
		, 'CompressionRatio' AS Nome
		, Compressi.MimeDataLength / Compressi.MimeCompressoLength AS Valore
	FROM @Compressi AS Compressi 
	WHERE Compressi.MimeDataChecksum = Compressi.MimeDecompressoChecksum
		AND Compressi.MimeCompressoLength < Compressi.MimeDataLength

	INSERT INTO [dbo].[AllegatiAttributi] ([IdAllegatiBase] ,[DataPartizione],[Nome],[Valore])
	SELECT Compressi.ID, Compressi.DataPartizione
		, 'MimeDataLength' AS Nome
		, Compressi.MimeDataLength AS Valore
	FROM @Compressi AS Compressi
	WHERE Compressi.MimeDataChecksum = Compressi.MimeDecompressoChecksum
		AND Compressi.MimeCompressoLength < Compressi.MimeDataLength
		
	RETURN (SELECT COUNT(*) FROM @Compressi)
END
