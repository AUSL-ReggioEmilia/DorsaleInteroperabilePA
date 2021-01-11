

-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2014-02-14
-- Description:	Seleziona una testata erogata
--				Usata da tutte le SP WsOrdiniErogatiTestateSelectByXxxxx
-- =============================================
CREATE VIEW [dbo].[WsOrdiniErogatiTestateSelect] AS
	SELECT   TE.ID
			, TE.IDSplit
			, T.ID AS IDOrdineTestata
			, T.Anno
			, T.Numero
			, T.IDSistemaRichiedente
			, SR.Codice AS CodiceSistemaRichiedente
			, SR.Descrizione AS DescrizioneSistemaRichiedente			
			, ASR.Codice AS CodiceAziendaSistemaRichiedente
			, ASR.Descrizione AS DescrizioneAziendaSistemaRichiedente			
			, T.IDRichiestaRichiedente
			, TE.IDSistemaErogante
			, SE.Codice AS CodiceSistemaErogante
			, SE.Descrizione AS DescrizioneSistemaErogante
			, ASE.Codice AS CodiceAziendaSistemaErogante
			, ASE.Descrizione AS DescrizioneAziendaSistemaErogante			
			, TE.IDRichiestaErogante
			, TE.StatoOrderEntry
			, TE.SottoStatoOrderEntry
			, TE.StatoRisposta			
			, TE.StatoOrderEntryAggregato
			, TE.DataModificaStato
			, TE.StatoErogante
			, TE.Data
			, TE.Operatore
			, TE.AnagraficaCodice
			, TE.AnagraficaNome
			, TE.PazienteIdRichiedente
			, TE.PazienteIdSac
			, TE.PazienteCognome
			, TE.PazienteNome
			, TE.PazienteDataNascita
			, TE.PazienteSesso
			, TE.PazienteCodiceFiscale
			, TE.Paziente
			, TE.Consensi
			, TE.Note
			, TE.DataPrenotazione
		FROM OrdiniErogatiTestate TE
			INNER JOIN OrdiniTestate T ON T.ID = TE.IDOrdineTestata

			LEFT JOIN Sistemi SR ON TE.IDSistemaRichiedente = SR.ID
			LEFT JOIN Aziende ASR ON SR.CodiceAzienda = ASR.Codice
			
			LEFT JOIN Sistemi SE ON TE.IDSistemaErogante = SE.ID
			LEFT JOIN Aziende ASE ON SE.CodiceAzienda = ASE.Codice

