
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE VIEW [dbo].[CUSTOM_OlapReferti]
AS
SELECT Referti.ID,
	YEAR(Referti.DataReferto) AS DataRefertoAnno,
	MONTH(Referti.DataReferto) AS DataRefertoMese,
	DAY(Referti.DataReferto) AS DataRefertoGiorno,
	Referti.DataReferto,
	Referti.DataInserimento,
	Referti.DataModifica,

	Referti.AziendaErogante,
	Referti.SistemaErogante,
	ISNULL(Referti.RepartoErogante, 'Sconosciuto') AS RepartoErogante,
	
	Referti.StatoRichiestaCodice,
	CASE Referti.StatoRichiestaCodice
									WHEN 0 THEN 'In corso'
									WHEN 1 THEN 'Completata'
									WHEN 2 THEN 'Variata'
									WHEN 3 THEN 'Cancellata'
									ELSE 'Sconosciuto'
								END AS StatoRichiestaNome,

	ISNULL(Referti.RepartoRichiedenteCodice, 'Vuoto')  AS RepartoRichiedenteCodice,
	ISNULL(Referti.RepartoRichiedenteDescr, 'Vuoto') AS RepartoRichiedenteNome,
	Referti.Cancellato AS CancellatoLogico,
	CASE WHEN NULLIF(LTRIM(Referti.NumeroNosologico), '') IS NULL THEN 0 ELSE 1 END AS ContienteNumeroNosologico,
	CASE WHEN NULLIF(LTRIM(Referti.NumeroPrenotazione), '') IS NULL THEN 0 ELSE 1 END AS ContienteNumeroPrenotazione

FROM    store.RefertiBase Referti WITH(NOLOCK)
WHERE Referti.DataReferto BETWEEN '1990-01-01' AND CONVERT(DATETIME, CONVERT(VARCHAR(40), GETDATE(), 112),  112)


GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_OlapReferti] TO [ReadOlap]
    AS [dbo];

