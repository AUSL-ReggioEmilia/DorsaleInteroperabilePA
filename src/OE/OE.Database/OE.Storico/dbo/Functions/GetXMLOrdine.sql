

-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-10
-- Modify date: 2011-03-02
-- Description:	Ritorna un xml relativo ad un ordine
-- =============================================
CREATE FUNCTION [dbo].[GetXMLOrdine](
	@IDOrderEntry uniqueidentifier
)
RETURNS xml
AS
BEGIN
--
-- Modificata: Sandro 2013-03-19 - Ritorna solo i dati, no TS e xml di rollback
--
	DECLARE @OrdineTestata xml
	DECLARE @OrdineTestataDatiAggiuntivi xml
	DECLARE @OrdineRigheRichieste xml
	
	-- Righe Richieste
    SET @OrdineRigheRichieste = 
    (
		SELECT ID, DataInserimento, DataModifica
			, IDTicketInserimento, IDTicketModifica
			, IDOrdineTestata, StatoOrderEntry, DataModificaStato, IDPrestazione
			, IDSistemaErogante, IDRigaOrderEntry
			, IDRigaRichiedente, IDRigaErogante, IDRichiestaErogante
			, StatoRichiedente, Consensi
		 
			, CAST((SELECT ID, DataInserimento, DataModifica
							, IDTicketInserimento, IDTicketModifica
							, IDRigaRichiesta, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto
							, ValoreDato, ValoreDatoVarchar, ValoreDatoXml
							, ParametroSpecifico, Persistente
					FROM  OrdiniRigheRichiesteDatiAggiuntivi AS DatoAggiuntivo
					WHERE DatoAggiuntivo.IDRigaRichiesta = RigaRichiesta.ID
					FOR XML AUTO, ELEMENTS) AS XML) AS RigaRichiestaDatiAggiuntivi
					
		FROM OrdiniRigheRichieste AS RigaRichiesta
		WHERE IDOrdineTestata = @IDOrderEntry
		FOR XML AUTO, ELEMENTS
	)

	-- Testata Dati aggiuntivi
	SET @OrdineTestataDatiAggiuntivi =
	(
		SELECT ID, DataInserimento, DataModifica
  				, IDTicketInserimento, IDTicketModifica
  				, IDOrdineTestata, IDDatoAggiuntivo
  				, Nome, TipoDato, TipoContenuto
  				, ValoreDato, ValoreDatoVarchar, ValoreDatoXml
  				, ParametroSpecifico, Persistente
		FROM OrdiniTestateDatiAggiuntivi AS DatoAggiuntivo
		WHERE IDOrdineTestata = @IDOrderEntry
		FOR XML AUTO, ELEMENTS
	)
	
	-- Testata
    SET @OrdineTestata = 
	(
		SELECT Testata.ID, Testata.DataInserimento, Testata.DataModifica
			, Testata.IDTicketInserimento, Testata.IDTicketModifica
			--, Testata.TS
			, Testata.Anno, Testata.Numero
			, Testata.IDUnitaOperativaRichiedente, Testata.IDSistemaRichiedente
			, Testata.NumeroNosologico, Testata.IDRichiestaRichiedente
			, Testata.DataRichiesta, Testata.StatoOrderEntry, Testata.SottoStatoOrderEntry
			, Testata.StatoRisposta, Testata.DataModificaStato, Testata.StatoRichiedente
			, Testata.Data, Testata.Operatore, Testata.Priorita, Testata.TipoEpisodio
			, Testata.AnagraficaCodice, Testata.AnagraficaNome
			, Testata.PazienteIdRichiedente, Testata.PazienteIdSac
			, Testata.PazienteRegime, Testata.PazienteCognome
			, Testata.PazienteNome, Testata.PazienteDataNascita
			, Testata.PazienteSesso, Testata.PazienteCodiceFiscale
			, Testata.Paziente, Testata.Consensi, Testata.Note
			, Testata.Regime, Testata.DataPrenotazione, Testata.StatoValidazione
			, Testata.Validazione, Testata.StatoTransazione, Testata.DataTransazione
				
			, @OrdineTestataDatiAggiuntivi AS TestataDatiAggiuntivi
			, @OrdineRigheRichieste AS RigheRichieste
		FROM OrdiniTestate AS Testata
		WHERE ID = @IDOrderEntry
		FOR XML AUTO, ELEMENTS
	)
	
	-- Return	
	RETURN @OrdineTestata

END

