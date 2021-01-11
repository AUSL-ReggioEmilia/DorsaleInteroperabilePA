
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Modify date: 2016-10-10 XML ritornato come NVARCHAR(MAX) (no query discribuite)
-- Modify date: 2019-03-20 LEFT join Ticket
-- Description:	Accesso alla richiesta
-- =============================================
CREATE VIEW [DataAccess].[OrdiniDettaglio]
AS
	SELECT 
		  T.ID as Id
		, T.Anno
		, T.Numero
		, T.DataInserimento
		, T.DataModifica
		
		--UserNameInserimento
		, ISNULL(TKI.UserName, 'SCONOSCIUTO') AS UtenteInserimento
		, ISNULL(TKM.UserName, 'SCONOSCIUTO') AS UtenteModifica
		
		, T.DataRichiesta
		
		, T.NumeroNosologico
		, T.IDRichiestaRichiedente AS IdRichiestaRichiedente
		
		, T.StatoOrderEntry
		, T.IDSistemaRichiedente
		, T.IDUnitaOperativaRichiedente

		--Anagrafica
		, T.PazienteIdSac
		, T.PazienteCognome
		, T.PazienteNome
		, T.PazienteDataNascita
		, T.PazienteCodiceFiscale
		
		, CONVERT(NVARCHAR(MAX), T.Validazione) AS Validazione
				
		--OrdineCompleto
		,  CONVERT(NVARCHAR(MAX), dbo.GetXMLOrdine(T.ID)) AS OrdineXml
	FROM 
		dbo.OrdiniTestate T  WITH(NOLOCK)
			LEFT JOIN dbo.Tickets TKI WITH(NOLOCK) ON TKI.ID =T.IDTicketInserimento
			LEFT JOIN dbo.Tickets TKM WITH(NOLOCK) ON TKM.ID =T.IDTicketModifica
