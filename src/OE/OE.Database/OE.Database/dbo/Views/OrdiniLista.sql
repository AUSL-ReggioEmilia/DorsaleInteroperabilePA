





CREATE VIEW [dbo].[OrdiniLista]
AS

SELECT 
			  T.ID as Id
			, T.Anno
			, T.Numero
			, CAST(T.Anno as varchar(4)) + '/' + CAST(T.Numero as varchar(16)) as NumeroOrdine
			, CAST(T.Anno as varchar(4)) + '/' + RIGHT('000000000'+ CAST(T.Numero as varchar(16)), 10) as NumeroOrdineSort
			, T.DataInserimento
			, (SELECT MAX(DataModifica) FROM dbo.OrdiniRigheRichieste WHERE IDOrdineTestata = T.ID) as DataModifica
			, dbo.GetAggregazioneSistemi(T.ID,', ') as TipiRichieste
			, T.IDTicketInserimento as IdTicketInserimento--Da rimuovere
			, T.IDTicketModifica as IdTicketModifica--Da rimuovere
			, T.IDUnitaOperativaRichiedente as IdUnitaOperativaRichiedente--Da rimuovere
			, T.IDSistemaRichiedente as IdSistemaRichiedente--Da rimuovere
			, T.NumeroNosologico
			, T.IDRichiestaRichiedente as IdRichiestaRichiedente
			, T.DataRichiesta
			, T.StatoOrderEntry
			, '' as SottoStatoOrderEntry--Da rimuovere: OrdiniSottoStati.Descrizione as SottoStatoOrderEntry
			, '' as StatoRisposta--Da rimuovereOrdiniStatiRisposta.Descrizione as StatoRisposta
			, dbo.GetStatoCalcolato(T.ID) as StatoOrderEntryDescrizione
			, '' as StatoRichiedente --Da rimuovere:COALESCE(CAST(T.StatoRichiedente.query('/CodiceDescrizioneType/Descrizione/text()') as varchar(max)),CAST(T.StatoRichiedente.query('/CodiceDescrizioneType/Codice/text()') as varchar(max))) as StatoRichiedente
			, (select max(milleDate)
from
(
select OT.DataModificaStato as milleDate FROM OrdiniTestate OT where OT.ID = T.ID
union all
select ET.DataModificaStato as milleDate FROM OrdiniErogatiTestate ET where ET.IDOrdineTestata = T.ID
union all
select Max(ORE.DataModificaStato) as milleDate FROM OrdiniRigheErogate ORE INNER JOIN OrdiniErogatiTestate ET ON ET.ID = ORE.IDOrdineErogatoTestata WHERE ET.IDOrdineTestata = T.ID) as TempTable
)as DataAggiornamentoStato
			, '' AS Operatore--(CAST(T.Operatore.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:OperatoreType/s:Cognome/text()') as varchar(max)) + ' ' + CAST(T.Operatore.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:OperatoreType/s:Nome/text()') as varchar(max))) as Operatore
			, T.AnagraficaNome
			, T.AnagraficaCodice
			,(T.AnagraficaNome + ' ' + T.AnagraficaCodice) as CodiceAnagrafica
			, T.PazienteIdRichiedente
			, T.PazienteIdSac
			, T.PazienteRegime
			, T.PazienteCognome
			, T.PazienteNome
			, T.PazienteDataNascita
			, T.PazienteCodiceFiscale
			, (T.PazienteCognome + ' ' + T.PazienteNome +  '<br />nato il ' + ISNULL(CONVERT(VARCHAR(10), T.PazienteDataNascita, 105),'-') + '<br />CF:' + T.PazienteCodiceFiscale) as DatiAnagraficiPaziente
			, '' as Note--Da rimuovere: T.Note
			, '' as CodiceAziendaUnitaOperativaRichiedente--da rimuovere: UOR.CodiceAzienda AS CodiceAziendaUnitaOperativaRichiedente
			, '' as CodiceUnitaOperativaRichiedente--da rimuovere: UOR.Codice AS CodiceUnitaOperativaRichiedente
			, SR.CodiceAzienda
			, SR.Codice
			, (SR.CodiceAzienda + ' ' + SR.Codice) as SistemaRichiedente		
			, dbo.GetTotaleRigheRichiesteByIDOrdine(T.ID) AS TotaleRigheRichieste
			, 1 as ValiditaOrdine

		FROM 
			dbo.OrdiniTestate T
			LEFT JOIN dbo.UnitaOperative UOR ON UOR.ID = T.IDUnitaOperativaRichiedente
			LEFT JOIN dbo.Sistemi SR ON SR.ID = T.IDSistemaRichiedente
			left join dbo.OrdiniStati on OrdiniStati.Codice = T.StatoOrderEntry
			--left join OrdiniSottoStati on OrdiniSottoStati.Codice = T.SottoStatoOrderEntry
			--left join OrdiniStatiRisposta on OrdiniStatiRisposta.Codice = T.StatoRisposta







