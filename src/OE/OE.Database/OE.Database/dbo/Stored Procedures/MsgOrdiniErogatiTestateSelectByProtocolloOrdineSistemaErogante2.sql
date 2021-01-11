
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2014-01-28 Nuova versione
-- Modify date: 2018-06-12 SAndro: Aggiunto ordinamento per TS
--									Serve per mantenere ordinamento dei nodi xml
-- Modify date: 2018-11-08 SAndro: Usa vista comune per tutte le SP MsgOrdiniErogatiTestateSelectBy_xxx
--
-- Description:	Seleziona una testata ordine erogato per anno/numero + IDSistemaErogante richiesta con dati sistemi
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniErogatiTestateSelectByProtocolloOrdineSistemaErogante2]
(
 @Anno int
,@Numero int
,@IDSistemaErogante uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;

	------------------------------
	-- SELECT
	------------------------------		
	SELECT ID
		, IDOrdineTestata
		, Anno
		, Numero

		, IDSistemaRichiedente
		, IDRichiestaRichiedente
		, CodiceAziendaSistemaRichiedente
		, DescrizioneAziendaSistemaRichiedente
		, CodiceSistemaRichiedente
		, DescrizioneSistemaRichiedente

		, IDSistemaErogante
		, IDRichiestaErogante
		, CodiceAziendaSistemaErogante
		, DescrizioneAziendaSistemaErogante
		, CodiceSistemaErogante
		, DescrizioneSistemaErogante

		, StatoOrderEntry
		, SottoStatoOrderEntry
		, StatoRisposta
		, StatoOrderEntryAggregato
		, DataModificaStato
		, StatoErogante
		, Data
		, Operatore

		, AnagraficaCodice
		, AnagraficaNome
		, PazienteIdRichiedente
		, PazienteIdSac
		, PazienteCognome
		, PazienteNome
		, PazienteDataNascita
		, PazienteSesso
		, PazienteCodiceFiscale
		, Paziente
		, Consensi

		, Note
		, DataPrenotazione
		, IDSplit

		, StatoCalcolatoCodice
		, StatoCalcolatoDescrizione
		, StatoCalcolatoEroganteCodice
		, StatoCalcolatoEroganteDescrizione

	FROM  [dbo].[MsgOrdiniErogatiTestateSelect] 			
	WHERE	Anno = @Anno
		AND Numero = @Numero
		AND IDSistemaErogante = @IDSistemaErogante
			
	ORDER BY TS
	
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniErogatiTestateSelectByProtocolloOrdineSistemaErogante2] TO [DataAccessMsg]
    AS [dbo];

