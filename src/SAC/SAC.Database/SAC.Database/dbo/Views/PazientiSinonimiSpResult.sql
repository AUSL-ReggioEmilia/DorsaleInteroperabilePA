

CREATE VIEW [dbo].[PazientiSinonimiSpResult]
AS
SELECT    Id
		, IdPaziente
		, Provenienza
		, IdProvenienza
		, Abilitato
		, DataInserimento
		, Motivo

FROM
	PazientiSinonimi with(nolock)


