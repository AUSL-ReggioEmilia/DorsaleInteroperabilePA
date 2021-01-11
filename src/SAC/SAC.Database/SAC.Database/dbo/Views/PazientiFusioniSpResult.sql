

CREATE VIEW [dbo].[PazientiFusioniSpResult]
AS
SELECT    Id
		, IdPaziente
		, IdPazienteFuso
		, ProgressivoFusione
		, Abilitato
		, DataInserimento
		, Motivo

FROM
	PazientiFusioni with(nolock)
