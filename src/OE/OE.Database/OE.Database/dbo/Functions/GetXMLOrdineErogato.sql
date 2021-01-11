
-- =============================================
-- Author:		Francesco Pichierri
-- Create date: 2010-12-10
-- Modify date: 2013-03-19
-- Description:	Ritorna un xml relativo ad un ordine erogato
-- =============================================
CREATE FUNCTION [dbo].[GetXMLOrdineErogato](
	@IdOrdiniErogatiTestate uniqueidentifier
)
RETURNS xml
AS
BEGIN
--Modifica: SANDRO 2013-03-19 Solo campi dati

	DECLARE @OrdineErogatoTestata xml
	DECLARE @OrdineErogatoTestataDatiAggiuntivi xml
	DECLARE @OrdineRigheErogate xml

	-- Righe Richieste
    SET @OrdineRigheErogate = 
    (
		SELECT ID, DataInserimento, DataModifica
			, IDTicketInserimento, IDTicketModifica
			, IDOrdineErogatoTestata, StatoOrderEntry, DataModificaStato
			, IDPrestazione, IDRigaRichiedente, IDRigaErogante, StatoErogante
			, Data, Operatore, Consensi
			, CAST((SELECT ID, DataInserimento, DataModifica
							, IDTicketInserimento, IDTicketModifica
							, IDRigaErogata, IDDatoAggiuntivo, Nome
							, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml
							, ParametroSpecifico, Persistente
					FROM  OrdiniRigheErogateDatiAggiuntivi AS DatoAggiuntivo
					WHERE DatoAggiuntivo.IDRigaErogata = RigaErogata.ID
					FOR XML AUTO, ELEMENTS) AS XML) AS RigaErogataDatiAggiuntivi

		FROM OrdiniRigheErogate AS RigaErogata
		WHERE IDOrdineErogatoTestata = @IdOrdiniErogatiTestate
		FOR XML AUTO, ELEMENTS
	)

	-- Testata Dati aggiuntivi
	SET @OrdineErogatoTestataDatiAggiuntivi =
	(
		SELECT ID, DataInserimento, DataModifica
				, IDTicketInserimento, IDTicketModifica
				, IDOrdineErogatoTestata, IDDatoAggiuntivo, Nome
				, TipoDato, TipoContenuto
				, ValoreDato, ValoreDatoVarchar, ValoreDatoXml
				, ParametroSpecifico, Persistente
		FROM OrdiniErogatiTestateDatiAggiuntivi AS DatoAggiuntivo
		WHERE IDOrdineErogatoTestata = @IdOrdiniErogatiTestate
		FOR XML AUTO, ELEMENTS
	)
	
	-- Testata
    SET @OrdineErogatoTestata = 
	(
		SELECT ID, DataInserimento, DataModifica
			, IDTicketInserimento, IDTicketModifica
			, IDOrdineTestata, IDSistemaRichiedente, IDRichiestaRichiedente
			, IDSistemaErogante, IDRichiestaErogante
			, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, StatoOrderEntryAggregato
			, DataModificaStato, StatoErogante
			, Data, Operatore
			, AnagraficaCodice, AnagraficaNome
			, PazienteIdRichiedente, PazienteIdSac, PazienteCognome, PazienteNome
			, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale
			, Paziente, Consensi, Note
			, DataPrenotazione, IDSplit
			
			, @OrdineErogatoTestataDatiAggiuntivi AS TestataDatiAggiuntivi
			, @OrdineRigheErogate AS RigheErogate
			
		FROM OrdiniErogatiTestate AS Testata
		WHERE ID = @IdOrdiniErogatiTestate
		FOR XML AUTO, ELEMENTS
	)
	
	RETURN @OrdineErogatoTestata
END
