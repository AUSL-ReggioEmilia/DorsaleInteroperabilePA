
-- =============================================
-- Author:		AlessandroNostini
-- Created date: 2014-01-27
-- Description:	Seleziona una testata ordine by anno/numero con anche i dati dei sistemi e UO
-- =============================================
CREATE PROCEDURE [dbo].[MsgOrdiniTestateSelectByProtocollo2]
	  @Anno int
	, @Numero int
AS
BEGIN
--Modificata: SANDRO 2013-03-19 Nuovi campi ritornati (StatoValidazione, Validazione, StatoTransazione, DataTransazione)
--Modificata: SANDRO 2014-01-27 Nuova versione: campi ritornati (SistemaRichiedente, UnitaOperativaRichiedente)
--Modificata: SANDRO 2014-09-24 Nuovi campi ritornati (AnteprimaPrestazioni)

	SET NOCOUNT ON;

	BEGIN TRY
		------------------------------
		-- SELECT
		------------------------------		
		SELECT 
			  ot.ID
			, ot.Anno
			, ot.Numero
			
			, ot.IDUnitaOperativaRichiedente
			, uo.CodiceAzienda AS CodiceAziendaUnitaOperativaRichiedente
			, auo.Descrizione AS DescrizioneAziendaUnitaOperativaRichiedente
			, uo.Codice AS CodiceUnitaOperativaRichiedente
			, uo.Descrizione AS DescrizioneUnitaOperativaRichiedente

			, ot.IDSistemaRichiedente
			, sr.CodiceAzienda AS CodiceAziendaSistemaRichiedente
			, asr.Descrizione AS DescrizioneAziendaSistemaRichiedente
			, sr.Codice AS CodiceSistemaRichiedente
			, sr.Descrizione AS DescrizioneSistemaRichiedente

			, ot.NumeroNosologico
			, ot.IDRichiestaRichiedente
			, ot.DataRichiesta
			, ot.StatoOrderEntry
			, ot.SottoStatoOrderEntry
			, ot.StatoRisposta
			, ot.DataModificaStato
			, ot.StatoRichiedente
			, ot.Data
			, ot.Operatore
			, ot.Priorita
			, ot.TipoEpisodio
			
			, ot.AnagraficaCodice
			, ot.AnagraficaNome
			
			, ot.PazienteIdRichiedente
			, ot.PazienteIdSac
			, ot.PazienteRegime
			, ot.PazienteCognome
			, ot.PazienteNome
			, ot.PazienteDataNascita
			, ot.PazienteSesso
			, ot.PazienteCodiceFiscale
			, ot.Paziente
			
			, ot.Consensi
			, ot.Note
			, ot.DatiRollback
			, ot.Regime
			, ot.DataPrenotazione
			
			, ot.StatoValidazione
			, ot.Validazione
			, ot.StatoTransazione
			, ot.DataTransazione
			, ot.AnteprimaPrestazioni

		FROM OrdiniTestate ot
			
			INNER JOIN Sistemi sr ON ot.IDSistemaRichiedente = sr.ID
			INNER JOIN Aziende asr ON sr.CodiceAzienda = asr.Codice

			INNER JOIN UnitaOperative uo ON ot.IDUnitaOperativaRichiedente = uo.ID
			INNER JOIN Aziende auo ON uo.CodiceAzienda = auo.Codice

		WHERE Anno = @Anno 
			AND Numero = @Numero
			
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = dbo.GetException()		
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[MsgOrdiniTestateSelectByProtocollo2] TO [DataAccessMsg]
    AS [dbo];

