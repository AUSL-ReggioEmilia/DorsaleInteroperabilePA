
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Modify date: 2019-03-19 DataStato ora legge da DataModificaStato e non da Data
-- Modify date: 2019-03-20 LEFT join Ticket e Stati
-- Description:	Accesso alla lista degli ordini erogati
-- =============================================

CREATE VIEW [DataAccess].[OrdiniErogatiLista]
AS
	SELECT
		  T.ID
		, T.IDOrdineTestata
		, T.IDRichiestaRichiedente
		, T.IDRichiestaErogante
	
		--SistemaErogante
		, T.IDSistemaErogante
		, ISNULL(SE.CodiceAzienda, 'UKN')  AS CodiceAziendaSistemaErogante
		, ISNULL(SE.Codice, 'UKN')  AS CodiceSistemaErogante
		, ISNULL(SE.Descrizione, 'SCONOSCIUTO')  AS DescrizioneSistemaErogante
		
		--Stato
		, T.DataModificaStato AS DataStato
		, T.StatoOrderEntry
		, ISNULL(OS.Descrizione, 'SCONOSCIUTO') AS DescrizioneStatoOrderEntry

	FROM 
		OrdiniErogatiTestate T WITH(NOLOCK)
			LEFT JOIN Sistemi SE WITH(NOLOCK) ON T.IDSistemaErogante = SE.ID
			LEFT JOIN OrdiniErogatiStati OS WITH(NOLOCK) ON T.StatoOrderEntry = OS.Codice
