-- =============================================
-- Author:		Sandro
-- Create date: 2012-07-12
-- Description:	Comprime dati XML dello storico
-- =============================================
CREATE PROCEDURE[dbo].[CompressMessaggiStati]
	@BatchSize INT = 1000
AS
BEGIN

	SET NOCOUNT ON;
	SET ROWCOUNT @BatchSize

	-- Comprime

	UPDATE dbo.compress_MessaggiStati
	SET MessaggioXmlCompresso = dbo.compress(CONVERT(VARBINARY(MAX), Messaggio))
		, StatoCompressione = 1
	WHERE StatoCompressione = 0

	-- Verifica e  libera spazio
	SET ROWCOUNT 0
	
	UPDATE dbo.compress_MessaggiStati
	SET MessaggioXmlCompresso = NULL
		, StatoCompressione = 3
	WHERE StatoCompressione = 1
		AND DATALENGTH(Messaggio) <= DATALENGTH(MessaggioXmlCompresso)

	UPDATE dbo.compress_MessaggiStati
	SET Messaggio = NULL
		, StatoCompressione = 2
	WHERE StatoCompressione = 1
		AND CONVERT(VARBINARY(MAX), Messaggio) = dbo.decompress(MessaggioXmlCompresso)
END
