-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-02-14
-- Description:	Seleziona una testata ordine
--				Usata da tutte le SP WsOrdiniTestateSelectByXxxxx
-- =============================================
CREATE VIEW [dbo].[WsOrdiniTestateSelect] AS
		SELECT 
			  T.ID
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
			, T.DataPrenotazione
			, T.StatoValidazione
			, T.Validazione
			, T.StatoTransazione
			, T.DataTransazione
			, dbo.GetWsDescrizioneStato2(T.ID) AS DescrizioneStato		
			, T.AnteprimaPrestazioni
			, dbo.IsOrdineCancellabile(T.ID) AS Cancellabile
		FROM OrdiniTestate T
			INNER JOIN Sistemi SR ON T.IDSistemaRichiedente = SR.ID
			INNER JOIN Aziende ASR ON SR.CodiceAzienda = ASR.Codice
			
			INNER JOIN UnitaOperative UO ON T.IDUnitaOperativaRichiedente = UO.ID
			INNER JOIN Aziende AUO ON UO.CodiceAzienda = AUO.Codice
			
			LEFT JOIN Priorita P ON P.Codice = dbo.IsNullOrEmpty(CAST(T.Priorita.query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:PrioritaType/s:Codice/text()') as varchar(16)),CAST(T.Priorita.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') as varchar(16)))
			LEFT JOIN Regimi R ON R.Codice = dbo.IsNullOrEmpty(CAST(T.Regime.query('declare namespace s="http://schemas.progel.it/OE/Types/1.1";/s:RegimeType/s:Codice/text()') as varchar(16)),CAST(T.Regime.query('declare namespace s="http://schemas.progel.it/BT/OE/QueueTypes/1.1";/s:CodiceDescrizioneType/s:Codice/text()') as varchar(16)))
