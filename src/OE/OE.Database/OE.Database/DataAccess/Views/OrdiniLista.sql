
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2013-11-21
-- Modify date: 2019-03-20 LEFT join Ticket, UnitaOperative e Sistemi
-- Description:	Accesso alla lista degli ordini
-- =============================================
CREATE VIEW [DataAccess].[OrdiniLista]
AS
SELECT 
		  T.ID as Id
		, T.Anno
		, T.Numero
		, T.DataInserimento
		, T.DataModifica
		
		--Utente
		, ISNULL(TKI.UserName, 'SCONOSCIUTO') AS UtenteInserimento
		, ISNULL(TKM.UserName, 'SCONOSCIUTO') AS UtenteModifica
		
		--DataModificaErogati				
		, (SELECT MAX(DataModifica) FROM OrdiniErogatiTestate WITH(NOLOCK) WHERE IDOrdineTestata = T.ID) AS DataModificaErogati

		, T.DataRichiesta
		
		--DataPrenotazione
		, ISNULL((SELECT MIN(DataPrenotazione) FROM dbo.OrdiniErogatiTestate WITH(NOLOCK) 
					WHERE IDOrdineTestata = T.ID AND NOT DataPrenotazione IS NULL
					) , T.DataPrenotazione) AS DataPrenotazione
		
		--SistemiEroganti
		, dbo.GetAggregazioneSistemi(T.ID,', ') AS SistemiEroganti				
		
		, T.NumeroNosologico
		, T.IDRichiestaRichiedente AS IdRichiestaRichiedente
		
		, T.StatoOrderEntry
				
		--StatoOrderEntryDescrizione	
		, dbo.GetWsDescrizioneStato2(T.ID) as StatoOrderEntryDescrizione		
		
		--DataModificaStato			
		, (SELECT MAX(DataModificaStato) FROM
				(
				SELECT OT.DataModificaStato AS DataModificaStato
							FROM OrdiniTestate OT  WITH(NOLOCK) 
							WHERE OT.ID = T.ID
				UNION ALL
				SELECT ET.DataModificaStato AS DataModificaStato
							FROM OrdiniErogatiTestate ET WITH(NOLOCK) 
							WHERE ET.IDOrdineTestata = T.ID
				UNION ALL
				SELECT MAX(ORE.DataModificaStato) AS DataModificaStato
							FROM OrdiniRigheErogate ORE WITH(NOLOCK) INNER JOIN 
								OrdiniErogatiTestate ET WITH(NOLOCK) ON ET.ID = ORE.IDOrdineErogatoTestata
							WHERE ET.IDOrdineTestata = T.ID) AS T_MAX
				) AS DataModificaStato

		--Richiedente
		, T.IDSistemaRichiedente
		, ISNULL((SR.CodiceAzienda + '-' + SR.Codice), 'SCONOSCIUTO') as SistemaRichiedente

		--Unita operativa
		, T.IDUnitaOperativaRichiedente
		, ISNULL((UOR.CodiceAzienda + '-' + UOR.Codice), 'SCONOSCIUTO') as UnitaOperativaRichiedente		
	
		--PrioritaCodice
		,dbo.IsNullOrEmpty( CAST(T.Priorita.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') AS varchar(16))
							,CAST(T.Priorita.query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:PrioritaType/s:Codice/text()') AS varchar(16))) AS PrioritaCodice
		--RegimeCodice
		,dbo.IsNullOrEmpty( CAST(T.Regime.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') AS varchar(16))
							,CAST(T.Regime.query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:RegimeType/s:Codice/text()') AS varchar(16))) AS RegimeCodice

		--Anagrafica
		, T.AnagraficaNome
		, T.AnagraficaCodice
		, T.PazienteIdSac
		, T.PazienteCognome
		, T.PazienteNome
		, T.PazienteDataNascita
		, T.PazienteCodiceFiscale
		
		--TotaleRigheRichieste
		, dbo.GetTotaleRigheRichiesteByIDOrdine(T.ID) AS NumeroRigheRichieste
		
		--ValiditaOrdine
		,(CASE WHEN ISNULL(CAST(Validazione.query('declare namespace s="http://schemas.progel.it/WCF/OE/WsTypes/1.1";/s:StatoValidazioneType/s:Stato/text()') AS varchar(16)), 'AA') = 'AA' THEN 1 ELSE 0 END) AS ValiditaOrdine
		
		--MessaggioValidita
		,NULLIF(CAST(Validazione.query('declare namespace s="http://schemas.progel.it/WCF/OE/WsTypes/1.1";/s:StatoValidazioneType/s:Descrizione/text()') AS varchar(max)), '') AS MessaggioValidita
	FROM 
		dbo.OrdiniTestate T  WITH(NOLOCK)
			LEFT JOIN dbo.Tickets TKI WITH(NOLOCK) ON TKI.ID =T.IDTicketInserimento
			LEFT JOIN dbo.Tickets TKM WITH(NOLOCK) ON TKM.ID =T.IDTicketModifica
			LEFT JOIN UnitaOperative UOR  WITH(NOLOCK) ON UOR.ID = T.IDUnitaOperativaRichiedente
			LEFT JOIN Sistemi SR WITH(NOLOCK) ON SR.ID = T.IDSistemaRichiedente
