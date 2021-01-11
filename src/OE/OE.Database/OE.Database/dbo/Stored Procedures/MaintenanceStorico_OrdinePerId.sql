
CREATE PROCEDURE [dbo].[MaintenanceStorico_OrdinePerId]
  @IdOrdine UNIQUEIDENTIFIER
, @DEBUG INT=0
, @LOG BIT=0
AS
BEGIN
--MODIFICHE:
-- 2014-11-24 Sandro: 
-- 2020-04-22 Sandro: Comprime subito i Meggaggi di richiesta e stato durante l'archiviazione

	SET NOCOUNT ON

	BEGIN TRY
				
		-- Inizio la transazione
		BEGIN TRANSACTION
				
		-- Sync OrdiniTestate - ok sandro
		INSERT INTO dbo.OrdiniTestate_Storico (ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, Anno, Numero, IDUnitaOperativaRichiedente, IDSistemaRichiedente, NumeroNosologico, IDRichiestaRichiedente, DataRichiesta, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, DataModificaStato, StatoRichiedente, Data, Operatore, Priorita, TipoEpisodio, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteRegime, PazienteCognome, PazienteNome, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note, DatiRollback, Regime, DataPrenotazione, StatoValidazione, Validazione, StatoTransazione, DataTransazione)
			SELECT ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, Anno, Numero, IDUnitaOperativaRichiedente, IDSistemaRichiedente, NumeroNosologico, IDRichiestaRichiedente, DataRichiesta, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, DataModificaStato, StatoRichiedente, Data, Operatore, Priorita, TipoEpisodio, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteRegime, PazienteCognome, PazienteNome, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note, DatiRollback, Regime, DataPrenotazione, StatoValidazione, Validazione, StatoTransazione, DataTransazione
			FROM OrdiniTestate 
			WHERE ID = @IdOrdine
					
		-- Sync OrdiniTestateDatiAggiuntivi - ok sandro
		INSERT INTO OrdiniTestateDatiAggiuntivi_Storico (ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente)
			SELECT ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente
			FROM OrdiniTestateDatiAggiuntivi 
			WHERE IDOrdineTestata = @IdOrdine
			
		-- Sync OrdiniVersioni - ok sandro
		INSERT INTO OrdiniVersioni_Storico (ID, DataInserimento, IDTicketInserimento, IDOrdineTestata, Tipo, StatoOrderEntry, DatiVersione, Data, DatiVersioneXmlCompresso, StatoCompressione)
			SELECT ID, DataInserimento, IDTicketInserimento, IDOrdineTestata, Tipo, StatoOrderEntry, DatiVersione, Data, DatiVersioneXmlCompresso, StatoCompressione
			FROM OrdiniVersioni 
			WHERE IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniRigheRichieste - ok sandro
		INSERT INTO OrdiniRigheRichieste_Storico (ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, StatoOrderEntry, DataModificaStato, IDPrestazione, IDSistemaErogante, IDRigaOrderEntry, IDRigaRichiedente, IDRigaErogante, IDRichiestaErogante, StatoRichiedente, Consensi)
			SELECT ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, StatoOrderEntry, DataModificaStato, IDPrestazione, IDSistemaErogante, IDRigaOrderEntry, IDRigaRichiedente, IDRigaErogante, IDRichiestaErogante, StatoRichiedente, Consensi
			FROM OrdiniRigheRichieste 
			WHERE IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniRigheRichiesteDatiAggiuntivi - ok sandro
		INSERT INTO OrdiniRigheRichiesteDatiAggiuntivi_Storico (ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDRigaRichiesta, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente)
			SELECT DA.ID, DA.DataInserimento, DA.DataModifica, DA.IDTicketInserimento, DA.IDTicketModifica, DA.IDRigaRichiesta, DA.IDDatoAggiuntivo, DA.Nome, DA.TipoDato, DA.TipoContenuto, DA.ValoreDato, DA.ValoreDatoVarchar, DA.ValoreDatoXml, DA.ParametroSpecifico, DA.Persistente
			FROM OrdiniRigheRichiesteDatiAggiuntivi DA INNER JOIN OrdiniRigheRichieste R
				ON DA.IDRigaRichiesta = R.ID
			WHERE R.IDOrdineTestata = @IdOrdine
									
		-- Sync OrdiniErogatiTestate - ok sandro
		INSERT INTO OrdiniErogatiTestate_Storico (ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, IDSistemaRichiedente, IDRichiestaRichiedente, IDSistemaErogante, IDRichiestaErogante, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, StatoOrderEntryAggregato, DataModificaStato, StatoErogante, Data, Operatore, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteCognome, PazienteNome, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note, DataPrenotazione, IDSplit)
			SELECT ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, IDSistemaRichiedente, IDRichiestaRichiedente, IDSistemaErogante, IDRichiestaErogante, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, StatoOrderEntryAggregato, DataModificaStato, StatoErogante, Data, Operatore, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteCognome, PazienteNome, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note, DataPrenotazione, IDSplit
			FROM OrdiniErogatiTestate 
			WHERE IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniErogatiTestateDatiAggiuntivi - ok sandro
		INSERT INTO OrdiniErogatiTestateDatiAggiuntivi_Storico (ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineErogatoTestata, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente)
			SELECT DA.ID, DA.DataInserimento, DA.DataModifica, DA.IDTicketInserimento, DA.IDTicketModifica, DA.IDOrdineErogatoTestata, DA.IDDatoAggiuntivo, DA.Nome, DA.TipoDato, DA.TipoContenuto, DA.ValoreDato, DA.ValoreDatoVarchar, DA.ValoreDatoXml, DA.ParametroSpecifico, DA.Persistente
			FROM OrdiniErogatiTestateDatiAggiuntivi DA INNER JOIN OrdiniErogatiTestate O
				ON DA.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniErogatiVersioni - ok sandro
		INSERT INTO OrdiniErogatiVersioni_Storico (ID, DataInserimento, IDTicketInserimento, IDOrdineErogatoTestata, StatoOrderEntry, DatiVersione, DatiVersioneXmlCompresso, StatoCompressione)
			SELECT OV.ID, OV.DataInserimento, OV.IDTicketInserimento, OV.IDOrdineErogatoTestata, OV.StatoOrderEntry, OV.DatiVersione, OV.DatiVersioneXmlCompresso, OV.StatoCompressione
			FROM OrdiniErogatiVersioni OV INNER JOIN OrdiniErogatiTestate O
				ON OV.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniRigheErogate - ok sandro
		INSERT INTO OrdiniRigheErogate_Storico (ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineErogatoTestata, StatoOrderEntry, DataModificaStato, IDPrestazione, IDRigaRichiedente, IDRigaErogante, StatoErogante, Data, Operatore, Consensi)
			SELECT R.ID, R.DataInserimento, R.DataModifica, R.IDTicketInserimento, R.IDTicketModifica, R.IDOrdineErogatoTestata, R.StatoOrderEntry, R.DataModificaStato, R.IDPrestazione, R.IDRigaRichiedente, R.IDRigaErogante, R.StatoErogante, R.Data, R.Operatore, R.Consensi
			FROM OrdiniRigheErogate R INNER JOIN OrdiniErogatiTestate O
				ON R.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniRigheErogateDatiAggiuntivi - ok sandro
		INSERT INTO OrdiniRigheErogateDatiAggiuntivi_Storico (ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDRigaErogata, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente)
			SELECT DA.ID, DA.DataInserimento, DA.DataModifica, DA.IDTicketInserimento, DA.IDTicketModifica, DA.IDRigaErogata, DA.IDDatoAggiuntivo, DA.Nome, DA.TipoDato, DA.TipoContenuto, DA.ValoreDato, DA.ValoreDatoVarchar, DA.ValoreDatoXml, DA.ParametroSpecifico, DA.Persistente
			FROM OrdiniRigheErogateDatiAggiuntivi DA INNER JOIN OrdiniRigheErogate R
				ON DA.IDRigaErogata = R.ID 
			INNER JOIN OrdiniErogatiTestate O
				ON R.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Sync MessaggiRichieste - ok sandro
		INSERT INTO MessaggiRichieste_Storico (ID, DataInserimento, DataModifica
						, IDTicketInserimento, IDTicketModifica, IDOrdineTestata
						, IDSistemaRichiedente, IDRichiestaRichiedente
						, Messaggio, Stato, Fault, StatoOrderEntry, DettaglioErrore
						, MessaggioXmlCompresso, StatoCompressione)

			SELECT ID, DataInserimento, DataModifica
						, IDTicketInserimento, IDTicketModifica, IDOrdineTestata
						, IDSistemaRichiedente, IDRichiestaRichiedente
						, NULL AS Messaggio
						, Stato, Fault, StatoOrderEntry, DettaglioErrore
						, dbo.compress(CONVERT(VARBINARY(MAX), Messaggio)) AS MessaggioXmlCompresso
						, 2 AS StatoCompressione
			FROM MessaggiRichieste
			WHERE IDOrdineTestata = @IdOrdine


		-- Sync MessaggiStati - ok sandro
		INSERT INTO MessaggiStati_Storico (ID, DataInserimento, DataModifica
					, IDTicketInserimento, IDTicketModifica
					, IDOrdineErogatoTestata, IDSistemaRichiedente, IDRichiestaRichiedente
					, Messaggio, Stato, Fault, StatoOrderEntry, TipoStato, DettaglioErrore
					, MessaggioXmlCompresso, StatoCompressione)
			SELECT M.ID, M.DataInserimento, M.DataInserimento
					, M.IDTicketInserimento, M.IDTicketModifica
					, M.IDOrdineErogatoTestata, M.IDSistemaRichiedente, M.IDRichiestaRichiedente
					, NULL AS Messaggio
					, M.Stato, M.Fault, M.StatoOrderEntry, M.TipoStato, M.DettaglioErrore
					, dbo.compress(CONVERT(VARBINARY(MAX), M.Messaggio)) AS MessaggioXmlCompresso
					, 2 AS StatoCompressione

			FROM MessaggiStati M INNER JOIN OrdiniErogatiTestate O
				ON M.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete MessaggiStati
		DELETE FROM MessaggiStati 
		FROM MessaggiStati M INNER JOIN OrdiniErogatiTestate O ON M.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete MessaggiRichieste
		DELETE FROM MessaggiRichieste WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniRigheErogateDatiAggiuntivi
		DELETE FROM OrdiniRigheErogateDatiAggiuntivi
		FROM OrdiniRigheErogateDatiAggiuntivi DA INNER JOIN OrdiniRigheErogate R ON DA.IDRigaErogata = R.ID INNER JOIN OrdiniErogatiTestate O ON R.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniRigheErogate
		DELETE FROM OrdiniRigheErogate
		FROM OrdiniRigheErogate R INNER JOIN OrdiniErogatiTestate O ON R.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniErogatiVersioni
		DELETE FROM OrdiniErogatiVersioni
		FROM OrdiniErogatiVersioni OV INNER JOIN OrdiniErogatiTestate O ON OV.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniErogatiTestateDatiAggiuntivi
		DELETE FROM OrdiniErogatiTestateDatiAggiuntivi
		FROM OrdiniErogatiTestateDatiAggiuntivi DA INNER JOIN OrdiniErogatiTestate O ON DA.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniErogatiTestate
		DELETE FROM OrdiniErogatiTestate WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniRigheRichiesteDatiAggiuntivi
		DELETE FROM OrdiniRigheRichiesteDatiAggiuntivi
		FROM OrdiniRigheRichiesteDatiAggiuntivi DA INNER JOIN OrdiniRigheRichieste R ON DA.IDRigaRichiesta = R.ID
		WHERE R.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniRigheRichieste
		DELETE FROM OrdiniRigheRichieste WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniVersioni
		DELETE FROM OrdiniVersioni WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniTestateDatiAggiuntivi
		DELETE FROM OrdiniTestateDatiAggiuntivi WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniTestate
		DELETE FROM OrdiniTestate WHERE ID = @IdOrdine

		COMMIT

		-- Log
		IF @LOG = 1
		BEGIN
			BEGIN TRY
				INSERT INTO Log_Storico (IDOrdineTestata) VALUES (@IdOrdine)
			END TRY
			BEGIN CATCH
			END CATCH
		END				
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0	
			ROLLBACK
				
		DECLARE @reason as varchar(max) = dbo.GetException()
		PRINT CHAR(9) + 'Errore: ' + @reason
								
		-- Log
		BEGIN TRY
			INSERT INTO Log_Storico (IDOrdineTestata, Errore) VALUES (@IdOrdine, @reason)
		END TRY
		BEGIN CATCH
		END CATCH				
	END CATCH
END
