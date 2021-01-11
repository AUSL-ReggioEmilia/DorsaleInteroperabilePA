
CREATE VIEW [DataAccess].[OrdiniErogatiDateStatiOsu]
AS
SELECT   oet.[ID]
		,oet.[IDOrdineTestata]
		,oet.[DataInserimento]

		,oet.[DataModifica]
		,oet.[DataModificaStato]

		-- Multi Erogante
		,oet.[StatoOrderEntry]
		,oet.[StatoOrderEntryAggregato]

		-- Date stati passati
		,stati.*

FROM [dbo].[OrdiniErogatiTestate] oet WITH(NOLOCK)

	OUTER APPLY ( SELECT MAX(CASE WHEN ms.[StatoOrderEntry] = 'AA' THEN  ms.[DataModifica] ELSE NULL END) [DataModificaStatoAA]
						,MAX(CASE WHEN ms.[StatoOrderEntry] = 'AR' THEN  ms.[DataModifica] ELSE NULL END) [DataModificaStatoAR]
						,MAX(CASE WHEN ms.[StatoOrderEntry] = 'AE' THEN  ms.[DataModifica] ELSE NULL END) [DataModificaStatoAE]
						,MAX(CASE WHEN ms.[StatoOrderEntry] = 'SE' THEN  ms.[DataModifica] ELSE NULL END) [DataModificaStatoSE]
						,MAX(CASE WHEN ms.[StatoOrderEntry] = 'IP' THEN  ms.[DataModifica] ELSE NULL END) [DataModificaStatoIP]
						,MAX(CASE WHEN ms.[StatoOrderEntry] = 'IC' THEN  ms.[DataModifica] ELSE NULL END) [DataModificaStatoIC]
						,MAX(CASE WHEN ms.[StatoOrderEntry] = 'CM' THEN  ms.[DataModifica] ELSE NULL END) [DataModificaStatoCM]
					FROM [dbo].[MessaggiStati] ms WITH(NOLOCK)
					WHERE ms.[IDOrdineErogatoTestata] = oet.[ID]) Stati