
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2019-03-19
-- Description:	Ordini con date e stati
-- =============================================
CREATE VIEW [DataAccess].[OrdiniDateStati]
AS
	SELECT
		  T.ID
		, T.StatoOrderEntry AS [StatoOrderEntry]

		, T.DataInserimento AS [DataInserimento]
		, T.DataModifica AS [DataModifica]
		, T.DataModificaStato AS [DataModificaStato]
		, T.DataPrenotazione AS [DataPrenotazione]
		, T.DataRichiesta AS [DataRichiesta]

		--Righe
		, R.ID AS [RigaId]
		, R.StatoOrderEntry AS [RigaStatoOrderEntry]

		, R.DataInserimento AS [RigaDataInserimento]
		, R.DataModifica AS [RigaDataModifica]
		, R.DataModificaStato	 AS [RigaDataModificaStato]
				
	FROM [dbo].[OrdiniTestate] T WITH(NOLOCK)
		LEFT JOIN [dbo].[OrdiniRigheRichieste] R WITH(NOLOCK)
		ON T.ID = R.IDOrdineTestata
