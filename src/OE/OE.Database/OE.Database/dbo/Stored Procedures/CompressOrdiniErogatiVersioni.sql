
-- =============================================
-- Author:		Sandro
-- Create date: 2014-03-10
-- Description:	Comprime dati XML dello storico
-- =============================================
CREATE PROCEDURE[dbo].[CompressOrdiniErogatiVersioni]
	@BatchSize INT = 1000
AS
BEGIN

	SET NOCOUNT ON;
	SET ROWCOUNT @BatchSize

	-- Comprime

	UPDATE dbo.OrdiniErogatiVersioni
	SET DatiVersioneXmlCompresso = dbo.compress(CONVERT(VARBINARY(MAX), DatiVersione))
		, StatoCompressione = 1
	WHERE StatoCompressione = 0

	-- Verifica e  libera spazio
	SET ROWCOUNT 0
				
	UPDATE dbo.OrdiniErogatiVersioni
	SET DatiVersioneXmlCompresso = NULL
		, StatoCompressione = 3
	WHERE StatoCompressione = 1
		AND DATALENGTH(DatiVersione) <= DATALENGTH(DatiVersioneXmlCompresso)

	UPDATE dbo.OrdiniErogatiVersioni
	SET DatiVersione = '<Root />'
		, StatoCompressione = 2
	WHERE StatoCompressione = 1
		AND CONVERT(VARBINARY(MAX), DatiVersione) = dbo.decompress(DatiVersioneXmlCompresso)

	SET ROWCOUNT 0
END
