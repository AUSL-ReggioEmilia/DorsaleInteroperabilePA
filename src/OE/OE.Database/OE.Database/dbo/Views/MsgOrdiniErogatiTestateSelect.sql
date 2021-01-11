

-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2018-11-08
-- Description:	Seleziona una testata erogata ordine
--				Usata da tutte le SP MsgOrdiniErogatiTestateSelect-xxx
-- =============================================
CREATE VIEW [dbo].[MsgOrdiniErogatiTestateSelect] AS

	SELECT TE.ID
		--
		-- Usati come filtro all'esterno della view, non modificare in campi calcolati
		--
		, T.ID AS IDOrdineTestata
		, T.Anno
		, T.Numero
			
		, COALESCE(TE.IDSistemaRichiedente, T.IDSistemaRichiedente) AS IDSistemaRichiedente
		, COALESCE(TE.IDRichiestaRichiedente, T.IDRichiestaRichiedente) AS IDRichiestaRichiedente
		, SR.CodiceAzienda AS CodiceAziendaSistemaRichiedente
		, ASR.Descrizione AS DescrizioneAziendaSistemaRichiedente
		, SR.Codice AS CodiceSistemaRichiedente
		, SR.Descrizione AS DescrizioneSistemaRichiedente

		, TE.IDSistemaErogante
		, TE.IDRichiestaErogante
		, SE.CodiceAzienda AS CodiceAziendaSistemaErogante
		, ASE.Descrizione AS DescrizioneAziendaSistemaErogante
		, SE.Codice AS CodiceSistemaErogante
		, SE.Descrizione AS DescrizioneSistemaErogante

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
		, TE.IDSplit
		--
		-- Per ordinamento
		--
		, TE.TS
		--
		-- Stato calcolato
		--
		, STATO_R.Codice AS StatoCalcolatoCodice
		, STATO_R.Descrizione AS StatoCalcolatoDescrizione
	
		, STATO_T.Codice AS StatoCalcolatoEroganteCodice
		, STATO_T.Descrizione AS StatoCalcolatoEroganteDescrizione
			
	FROM OrdiniErogatiTestate TE
		
		INNER JOIN Sistemi SE ON TE.IDSistemaErogante = SE.ID
		INNER JOIN Aziende ASE ON SE.CodiceAzienda = ASE.Codice

		LEFT JOIN OrdiniTestate T ON T.ID = TE.IDOrdineTestata

		LEFT JOIN Sistemi SR ON SR.ID = COALESCE(TE.IDSistemaRichiedente, T.IDSistemaRichiedente)
		LEFT JOIN Aziende ASR ON SR.CodiceAzienda = ASR.Codice

		OUTER APPLY [dbo].[GetMsgDescrizioneStatoRichiesta](T.ID) STATO_R
		OUTER APPLY [dbo].[GetMsgDescrizioneStatoErogato](T.ID, TE.ID) STATO_T