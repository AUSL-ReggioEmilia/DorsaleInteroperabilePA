

-- =============================================
-- Author:      
-- Create date: 
-- Description: Recupera le informazioni dell'ordine, usata sia per lista che per dettaglio
-- Modify date: 2015-01-29 Stefano: aggiunto campo DescrizioneUnitaOperativaRichiedente
-- Modify date: 2016-01-08 Stefano: Ora usa la function per leggere lo stato Validazione
-- =============================================

CREATE VIEW [dbo].[OrdiniLista2]
AS

	SELECT 
	  T.ID as Id
	, T.Anno
	, T.Numero
	, CAST(T.Anno as varchar(4)) + '/' + CAST(T.Numero as varchar(16)) as NumeroOrdine
	, CAST(T.Anno as varchar(4)) + '/' + RIGHT('000000000'+ CAST(T.Numero as varchar(16)), 10) as NumeroOrdineSort
	, T.DataInserimento
	, T.DataModifica
	, T.DataRichiesta

	--DataPrenotazione
	, ISNULL((SELECT MIN(DataPrenotazione) FROM dbo.OrdiniErogatiTestate
				WHERE IDOrdineTestata = T.ID AND NOT DataPrenotazione IS NULL)
					, T.DataPrenotazione) as DataPrenotazione
					
	--TipiRichieste			
	, dbo.GetAggregazioneSistemi(T.ID,',<br />') as TipiRichieste
					
	, T.NumeroNosologico
	, T.IDRichiestaRichiedente as IdRichiestaRichiedente
	, R.Descrizione as Regime
	, P.Descrizione as Priorita
	, T.StatoOrderEntry

	--StatoOrderEntryDescrizione	
	, dbo.GetStatoCalcolato(T.ID) as StatoOrderEntryDescrizione		

	--DataAggiornamentoStato--				
	, (select max(milleDate)
		from
		(select OT.DataModificaStato as milleDate FROM OrdiniTestate OT where OT.ID = T.ID
			union all
		 select ET.DataModificaStato as milleDate FROM OrdiniErogatiTestate ET where ET.IDOrdineTestata = T.ID
			union all
		 select Max(ORE.DataModificaStato) as milleDate 
			FROM OrdiniRigheErogate ORE 
			INNER JOIN OrdiniErogatiTestate ET ON ET.ID = ORE.IDOrdineErogatoTestata 
			WHERE ET.IDOrdineTestata = T.ID) as TempTable
	  )as DataAggiornamentoStato

	, T.AnagraficaNome
	, T.AnagraficaCodice
	, ISNULL(T.AnagraficaNome + ' ' + T.AnagraficaCodice, '') as CodiceAnagrafica
	, T.PazienteIdRichiedente
	, T.PazienteIdSac
	, T.PazienteRegime
	, T.PazienteCognome
	, T.PazienteNome
	, T.PazienteDataNascita
	, T.PazienteCodiceFiscale
	, (T.PazienteCognome + ' ' + T.PazienteNome +  
		'<br />nato il ' + ISNULL(CONVERT(VARCHAR(10), T.PazienteDataNascita, 105),'-') + 
		'<br />CF:' + T.PazienteCodiceFiscale
	  ) as DatiAnagraficiPaziente		
	, T.IDSistemaRichiedente
	, (SR.CodiceAzienda + '-' + SR.Codice) as SistemaRichiedente
	, T.IDUnitaOperativaRichiedente
	, (UOR.CodiceAzienda + '-' + UOR.Codice) as UnitaOperativaRichiedente		
	, dbo.GetTotaleRigheRichiesteByIDOrdine(T.ID) AS TotaleRigheRichieste
	, VALI.Validita as ValiditaOrdine
	, ISNULL(CAST(Validazione.query('declare namespace s="http://schemas.progel.it/WCF/OE/WsTypes/1.1";/s:StatoValidazioneType/s:Descrizione/text()') as varchar(max)), '') as MessaggioValidita
	, CAST(T.[Operatore].query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:OperatoreType/s:Cognome/text()') as varchar(64)) as OperatoreCognome
	, CAST(T.[Operatore].query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:OperatoreType/s:Nome/text()') as varchar(64)) as OperatoreNome
	, CAST(T.[Operatore].query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:OperatoreType/s:ID/text()') as varchar(64)) as OperatoreId		
	, TIns.UserName as TicketInserimentoUserName
	, TMod.UserName as TicketModificaUserName
	, UOR.Descrizione as DescrizioneUnitaOperativaRichiedente

	FROM 
	dbo.OrdiniTestate T
	CROSS APPLY dbo.GetOrdineValidazione(T.Validazione) VALI
	LEFT JOIN UnitaOperative UOR ON UOR.ID = T.IDUnitaOperativaRichiedente
	LEFT JOIN Sistemi SR ON SR.ID = T.IDSistemaRichiedente
	LEFT JOIN OrdiniStati on OrdiniStati.Codice = T.StatoOrderEntry
	LEFT JOIN Priorita P ON P.Codice = dbo.IsNullOrEmpty(CAST(T.Priorita.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') as varchar(16)),
														 CAST(T.Priorita.query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:PrioritaType/s:Codice/text()') as varchar(16)))
	LEFT JOIN Regimi R ON R.Codice = dbo.IsNullOrEmpty(CAST(T.Regime.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') as varchar(16)),
													   CAST(T.Regime.query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:RegimeType/s:Codice/text()') as varchar(16)))
	LEFT JOIN Tickets TIns
		ON T.IDTicketInserimento = TIns.ID										   
	LEFT JOIN Tickets TMod
		ON T.IDTicketModifica = TMod.ID
		



