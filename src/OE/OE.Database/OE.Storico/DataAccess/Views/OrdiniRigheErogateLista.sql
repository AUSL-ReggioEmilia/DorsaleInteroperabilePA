

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Modify date: 2019-03-19 DataStato ora legge da DataModificaStato e non da Data
-- Modify date: 2019-03-20 LEFT join Prestazioni, Stati e Sistemi
-- Description:	Accesso alla lista delle righe dei degli ordini erogati
-- =============================================
CREATE VIEW [DataAccess].[OrdiniRigheErogateLista]
AS
	SELECT 
		  TRE.ID AS Id
		, TE.IDOrdineTestata AS IdOrdineTestata
		, TRE.IDOrdineErogatoTestata AS IdOrdineErogatoTestata
		
		--Prestazione
		, TRE.IDPrestazione
		, ISNULL(P.Codice, 'UKN') AS CodicePrestazione
		, ISNULL(P.Descrizione, 'SCONOSCIUTO') AS DescrizionePrestazione
			
		--SistemaErogante
		, TE.IDSistemaErogante AS IdSistemaErogante
		, ISNULL(SE.CodiceAzienda, 'UKN') AS CodiceAziendaSistemaErogante
		, ISNULL(SE.Codice, 'UKN') AS CodiceSistemaErogante
		, ISNULL(SE.Descrizione, 'SCONOSCIUTO') AS DescrizioneSistemaErogante
		
		--Stato
		, TRE.DataModificaStato AS DataStato
		, TRE.StatoOrderEntry
		, ISNULL(OS.Descrizione, 'SCONOSCIUTO') AS DescrizioneStatoOrderEntry		

	FROM OrdiniErogatiTestate TE WITH(NOLOCK)
			INNER JOIN dbo.OrdiniRigheErogate TRE  WITH(NOLOCK) ON TRE.IDOrdineErogatoTestata = TE.ID
			LEFT JOIN Sistemi SE WITH(NOLOCK) ON TE.IDSistemaErogante = SE.ID
			LEFT JOIN OrdiniErogatiStati OS WITH(NOLOCK) ON TRE.StatoOrderEntry = OS.Codice
			LEFT JOIN dbo.Prestazioni P WITH(NOLOCK) ON TRE.IDPrestazione = P.ID
