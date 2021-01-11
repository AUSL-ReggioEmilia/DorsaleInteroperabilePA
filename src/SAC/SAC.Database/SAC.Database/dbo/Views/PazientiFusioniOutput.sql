

CREATE VIEW [dbo].[PazientiFusioniOutput]
AS
--
--2016-05-26 SANDRO Rimosso WHERE LeggePazientiPermessiLettura()=1
--
SELECT    Id
		, IdPaziente
		, IdPazienteFuso
		, ProgressivoFusione
		, Abilitato
		, DataInserimento
		, Motivo

FROM
	PazientiFusioni with(nolock)










GO
GRANT SELECT
    ON OBJECT::[dbo].[PazientiFusioniOutput] TO [DataAccessSql]
    AS [dbo];

