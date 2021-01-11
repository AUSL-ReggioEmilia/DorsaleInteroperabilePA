
CREATE VIEW [dbo].[PazientiSinonimiOutput]
AS
--
--2016-05-26 SANDRO Rimosso WHERE LeggePazientiPermessiLettura()=1
--
SELECT    Id
		, IdPaziente
		, Provenienza
		, IdProvenienza
		, Abilitato
		, DataInserimento
		, Motivo

FROM
	PazientiSinonimi with(nolock)









GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiSinonimiOutput] TO [DataAccessSql]
    AS [dbo];

