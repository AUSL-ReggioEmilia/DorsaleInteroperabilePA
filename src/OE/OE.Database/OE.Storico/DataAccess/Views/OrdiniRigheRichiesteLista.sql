
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Modify date: 2019-03-20 LEFT join Prestazioni e Sistemi
-- Description:	Accesso alla lista delle righe dei degli ordini
-- =============================================
CREATE VIEW [DataAccess].[OrdiniRigheRichiesteLista]
AS
	SELECT 
		  T.ID
		, T.IDOrdineTestata
		
		--Prestazione
		, T.IDPrestazione
		, ISNULL(P.Codice, 'UKN') AS CodicePrestazione
		, ISNULL(P.Descrizione, 'SCONOSCIUTO') AS DescrizionePrestazione
		, ISNULL(P.Tipo, 0) AS TipoPrestazione
		
		--SistemaErogante
		, T.IDSistemaErogante
		, ISNULL(S.CodiceAzienda, 'UKN') AS CodiceAziendaSistemaErogante
		, ISNULL(S.Codice, 'UKN') AS CodiceSistemaErogante
		, ISNULL(S.Descrizione, 'SCONOSCIUTO') AS DescrizioneSistemaErogante	
	FROM 
		dbo.OrdiniRigheRichieste T WITH(NOLOCK)
			LEFT JOIN dbo.Prestazioni P  WITH(NOLOCK) ON T.IDPrestazione = P.ID
			LEFT JOIN dbo.Sistemi S  WITH(NOLOCK) ON T.IDSistemaErogante = S.ID
