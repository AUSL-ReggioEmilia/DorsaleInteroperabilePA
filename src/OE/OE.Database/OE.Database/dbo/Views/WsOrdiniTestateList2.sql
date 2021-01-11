
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-02-14
-- Modify date: 2014-10-27 Ritorna la descrizione dei sistemi eroganti anziche il codice
-- Modify date: 2020-03-09 Nuovo metodo ricerca data pianificazione e nuovi dati per tutti gli altri
-- Modify date: 2020-04-09 Dalla tabella RicercaOrdini deve tornare solo 1 record
--
-- Description:	Seleziona una lista di testate ordine
--				Usata da tutte le SP WsOrdiniTestateListByXxxxx
-- =============================================
CREATE VIEW [dbo].[WsOrdiniTestateList2] AS
		SELECT T.ID
			, T.DataInserimento
			, T.DataModifica
			, T.Anno
			, T.Numero
			, T.IDUnitaOperativaRichiedente
			, UO.Codice AS CodiceUnitaOperativaRichiedente
			, UO.Descrizione AS DescrizioneUnitaOperativaRichiedente
			, AUO.Codice AS CodiceAziendaUnitaOperativaRichiedente
			, AUO.Descrizione AS DescrizioneAziendaUnitaOperativaRichiedente
			, T.IDSistemaRichiedente
			, SR.Codice AS CodiceSistemaRichiedente
			, SR.Descrizione AS DescrizioneSistemaRichiedente
			, ASR.Codice AS CodiceAziendaSistemaRichiedente
			, ASR.Descrizione AS DescrizioneAziendaSistemaRichiedente
			, T.NumeroNosologico
			, T.IDRichiestaRichiedente
			, T.DataRichiesta
			, T.StatoOrderEntry
			, T.SottoStatoOrderEntry
			, T.StatoRisposta
			, T.DataModificaStato
			, T.StatoRichiedente
			, T.Data
			, T.Operatore
			, P.Codice AS PrioritaCodice
			, P.Descrizione AS PrioritaDescrizione
			, T.TipoEpisodio
			, T.AnagraficaCodice
			, T.AnagraficaNome
			, T.PazienteIdRichiedente
			, T.PazienteIdSac
			, T.PazienteRegime
			, T.PazienteCognome
			, T.PazienteNome
			, T.PazienteDataNascita
			, T.PazienteSesso
			, T.PazienteCodiceFiscale
			, T.Paziente
			, T.Consensi
			, T.Note
			, R.Codice AS RegimeCodice
			, R.Descrizione AS RegimeDescrizione
			--DataPrenotazione oppure dalle righe erogate
			, ISNULL((SELECT MIN(OET.DataPrenotazione) 
						FROM dbo.OrdiniErogatiTestate OET WITH(NOLOCK)
						WHERE OET.IDOrdineTestata = T.ID AND NOT OET.DataPrenotazione IS NULL)
				, T.DataPrenotazione) AS DataPrenotazione
						
			, T.StatoValidazione
			, T.Validazione
			, T.StatoTransazione
			, T.DataTransazione
			, dbo.GetWsDescrizioneStato2(T.ID) AS DescrizioneStato
			, dbo.GetWsAggregazioneSistemiErogantiDescrizione(T.ID) AS SistemiEroganti
			, (SELECT COUNT(*) FROM dbo.OrdiniRigheRichieste WITH(NOLOCK)
				 WHERE IDOrdineTestata = T.ID) AS TotaleRighe
			, T.AnteprimaPrestazioni	
			, dbo.IsOrdineCancellabile(T.ID) AS Cancellabile

			-- 2020-03-09 Nuovo metodo ricerca data pianificazione
			--
			,ricerca.DataPrenotazioneRichiesta
			,ricerca.DataPrenotazioneErogante
			,ricerca.DataPianificazioneErogante
			,ricerca.DataModificaPianificazione

		FROM 
			OrdiniTestate T
			
			INNER JOIN Sistemi SR ON T.IDSistemaRichiedente = SR.ID
			INNER JOIN Aziende ASR ON SR.CodiceAzienda = ASR.Codice
			
			INNER JOIN UnitaOperative UO ON T.IDUnitaOperativaRichiedente = UO.ID
			INNER JOIN Aziende AUO ON UO.CodiceAzienda = AUO.Codice
			
			LEFT JOIN Priorita P ON P.Codice = CAST(T.Priorita.query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:PrioritaType/s:Codice/text()') as varchar(16))
			LEFT JOIN Regimi R ON R.Codice = CAST(T.Regime.query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:RegimeType/s:Codice/text()') as varchar(16))

			OUTER APPLY (
						-- Solo 1 record
						-- Prendo MIN per gli eroganti e MAX per Ultima modifica
						--
						SELECT MIN(ro.DataPrenotazioneRichiesta) DataPrenotazioneRichiesta
								, MIN(ro.DataPrenotazioneErogante) DataPrenotazioneErogante
								, MIN(ro.DataPianificazioneErogante) DataPianificazioneErogante
								, MAX(ro.DataModificaPianificazione) DataModificaPianificazione
						FROM [dbo].[RicercaOrdini] ro WITH(NOLOCK)
						WHERE ro.IdOrdineTestata = T.ID
						) ricerca

