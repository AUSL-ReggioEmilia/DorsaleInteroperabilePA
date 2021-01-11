
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-03-19
-- Description:	Ordini erogati con date e stati
-- =============================================
CREATE VIEW [DataAccess].[OrdiniErogatiDateStati]
AS
	SELECT
		  TE.ID
		, TE.IDOrdineTestata

		--Erogante
		, TE.StatoOrderEntry AS [StatoOrderEntry]
		, TE.StatoOrderEntryAggregato AS [StatoOrderEntryAggregato]

		, TE.DataInserimento AS [DataInserimento]
		, TE.DataModifica AS [DataModifica]
		, TE.DataModificaStato AS [DataModificaStato]
		, TE.DataPrenotazione AS [DataPrenotazione]

		--Righe
		, RE.ID AS [RigaId]
		, RE.StatoOrderEntry AS [RigaStatoOrderEntry]

		, RE.DataInserimento AS [RigaDataInserimento]
		, RE.DataModifica AS [RigaDataModifica]
		, RE.DataModificaStato	 AS [RigaDataModificaStato]
				
	FROM [dbo].[OrdiniErogatiTestate] TE WITH(NOLOCK)
		LEFT JOIN [dbo].[OrdiniRigheErogate] RE WITH(NOLOCK)
		ON TE.ID = RE.IDOrdineErogatoTestata