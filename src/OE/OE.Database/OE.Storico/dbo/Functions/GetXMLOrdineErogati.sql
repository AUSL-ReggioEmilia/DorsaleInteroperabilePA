
CREATE FUNCTION [dbo].[GetXMLOrdineErogati]
(@IdOrdiniTestate UNIQUEIDENTIFIER)
RETURNS XML
AS
BEGIN
--Modifica: SANDRO 2014-11-17 Tutte le testate
	DECLARE @OrdineErogatoTestate xml

	-- Testata
    SET @OrdineErogatoTestate = 
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
			
			, CONVERT(XML, (SELECT ID, DataInserimento, DataModifica
									, IDTicketInserimento, IDTicketModifica
									, IDOrdineErogatoTestata, IDDatoAggiuntivo, Nome
									, TipoDato, TipoContenuto
									, ValoreDato, ValoreDatoVarchar, ValoreDatoXml
									, ParametroSpecifico, Persistente
							FROM OrdiniErogatiTestateDatiAggiuntivi AS DatoAggiuntivo
							WHERE IDOrdineErogatoTestata = Testata.ID
							FOR XML AUTO, ELEMENTS
							)
				) AS TestataDatiAggiuntivi
			
			, CONVERT(XML, (SELECT ID, DataInserimento, DataModifica
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
							WHERE IDOrdineErogatoTestata = Testata.ID
							FOR XML AUTO, ELEMENTS
							)
					) AS RigheErogate
			
		FROM OrdiniErogatiTestate AS Testata
		WHERE IDOrdineTestata = @IdOrdiniTestate
		FOR XML AUTO, ELEMENTS, ROOT('TestateErogate')
	)

	RETURN @OrdineErogatoTestate
END
