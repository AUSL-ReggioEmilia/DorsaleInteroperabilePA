

-- =============================================
-- Author:      Stefano P.
-- Create date: 2016-10-26
-- Description: Vista per leggere i sinonimi del paziente
-- Modify date: 
-- =============================================
CREATE VIEW [pazienti_ws].[PazientiSinonimi]
AS
SELECT    Id
		, IdPaziente
		, Provenienza
		, IdProvenienza
		, Abilitato
		, DataInserimento
		, Motivo
FROM
	dbo.PazientiSinonimi with(nolock)