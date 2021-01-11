
CREATE PROCEDURE [dbo].[MaintenanceRestore_OrdinePerId]
  @IdOrdine UNIQUEIDENTIFIER
, @LOG BIT=0
AS
BEGIN
--MODIFICHE:
-- 2015-02-09 Sandro: 

	SET NOCOUNT ON

	BEGIN TRY
				
		-- Inizio la transazione
		BEGIN TRANSACTION

		DECLARE @StartTime DATETIME = GETDATE()
				
		-- Sync OrdiniTestate - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniTestate
			(ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, Anno, Numero, IDUnitaOperativaRichiedente, IDSistemaRichiedente, NumeroNosologico, IDRichiestaRichiedente, DataRichiesta, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, DataModificaStato, StatoRichiedente, Data, Operatore, Priorita, TipoEpisodio, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteRegime, PazienteCognome, PazienteNome, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note, DatiRollback, Regime, DataPrenotazione, StatoValidazione, Validazione, StatoTransazione, DataTransazione)
		SELECT ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, Anno, Numero, IDUnitaOperativaRichiedente, IDSistemaRichiedente, NumeroNosologico, IDRichiestaRichiedente, DataRichiesta, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, DataModificaStato, StatoRichiedente, Data, Operatore, Priorita, TipoEpisodio, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteRegime, PazienteCognome, PazienteNome, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note, DatiRollback, Regime, DataPrenotazione, StatoValidazione, Validazione, StatoTransazione, DataTransazione
			FROM dbo.OrdiniTestate
			WHERE ID = @IdOrdine
					
		-- Sync OrdiniTestateDatiAggiuntivi - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniTestateDatiAggiuntivi
			(ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente)
		SELECT ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente
			FROM dbo.OrdiniTestateDatiAggiuntivi
			WHERE IDOrdineTestata = @IdOrdine
			
		-- Sync OrdiniVersioni - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniVersioni
				(ID, DataInserimento, IDTicketInserimento, IDOrdineTestata, Tipo, StatoOrderEntry, DatiVersione, Data
				, DatiVersioneXmlCompresso, StatoCompressione)
		SELECT ID, DataInserimento, IDTicketInserimento, IDOrdineTestata, Tipo, StatoOrderEntry, DatiVersione, Data
				, DatiVersioneXmlCompresso, StatoCompressione
			FROM dbo.compress_OrdiniVersioni
			WHERE IDOrdineTestata = @IdOrdine
				
		-- Sync OrdiniRigheRichieste - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniRigheRichieste
			(ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, StatoOrderEntry, DataModificaStato, IDPrestazione, IDSistemaErogante, IDRigaOrderEntry, IDRigaRichiedente, IDRigaErogante, IDRichiestaErogante, StatoRichiedente, Consensi)
		SELECT ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, StatoOrderEntry, DataModificaStato, IDPrestazione, IDSistemaErogante, IDRigaOrderEntry, IDRigaRichiedente, IDRigaErogante, IDRichiestaErogante, StatoRichiedente, Consensi
			FROM dbo.OrdiniRigheRichieste
			WHERE IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniRigheRichiesteDatiAggiuntivi - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniRigheRichiesteDatiAggiuntivi
			(ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDRigaRichiesta, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente)
		SELECT DA.ID, DA.DataInserimento, DA.DataModifica, DA.IDTicketInserimento, DA.IDTicketModifica, DA.IDRigaRichiesta, DA.IDDatoAggiuntivo, DA.Nome, DA.TipoDato, DA.TipoContenuto, DA.ValoreDato, DA.ValoreDatoVarchar, DA.ValoreDatoXml, DA.ParametroSpecifico, DA.Persistente
			FROM dbo.OrdiniRigheRichiesteDatiAggiuntivi DA
				INNER JOIN dbo.OrdiniRigheRichieste R
				ON DA.IDRigaRichiesta = R.ID
			WHERE R.IDOrdineTestata = @IdOrdine
									
		-- Sync OrdiniErogatiTestate - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniErogatiTestate
			(ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, IDSistemaRichiedente, IDRichiestaRichiedente, IDSistemaErogante, IDRichiestaErogante, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, StatoOrderEntryAggregato, DataModificaStato, StatoErogante, Data, Operatore, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteCognome, PazienteNome, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note, DataPrenotazione, IDSplit)
		SELECT ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineTestata, IDSistemaRichiedente, IDRichiestaRichiedente, IDSistemaErogante, IDRichiestaErogante, StatoOrderEntry, SottoStatoOrderEntry, StatoRisposta, StatoOrderEntryAggregato, DataModificaStato, StatoErogante, Data, Operatore, AnagraficaCodice, AnagraficaNome, PazienteIdRichiedente, PazienteIdSac, PazienteCognome, PazienteNome, PazienteDataNascita, PazienteSesso, PazienteCodiceFiscale, Paziente, Consensi, Note, DataPrenotazione, IDSplit
			FROM dbo.OrdiniErogatiTestate
			WHERE IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniErogatiTestateDatiAggiuntivi - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniErogatiTestateDatiAggiuntivi
			(ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineErogatoTestata, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente)
		SELECT DA.ID, DA.DataInserimento, DA.DataModifica, DA.IDTicketInserimento, DA.IDTicketModifica, DA.IDOrdineErogatoTestata, DA.IDDatoAggiuntivo, DA.Nome, DA.TipoDato, DA.TipoContenuto, DA.ValoreDato, DA.ValoreDatoVarchar, DA.ValoreDatoXml, DA.ParametroSpecifico, DA.Persistente
			FROM dbo.OrdiniErogatiTestateDatiAggiuntivi DA
				INNER JOIN dbo.OrdiniErogatiTestate O
				ON DA.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniErogatiVersioni - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniErogatiVersioni
					(ID, DataInserimento, IDTicketInserimento, IDOrdineErogatoTestata, StatoOrderEntry, DatiVersione
					, DatiVersioneXmlCompresso, StatoCompressione)
		SELECT OV.ID, OV.DataInserimento, OV.IDTicketInserimento, OV.IDOrdineErogatoTestata, OV.StatoOrderEntry, OV.DatiVersione
					, OV.DatiVersioneXmlCompresso, OV.StatoCompressione
			FROM dbo.compress_OrdiniErogatiVersioni OV
				INNER JOIN dbo.OrdiniErogatiTestate O
				ON OV.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniRigheErogate - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniRigheErogate
			(ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDOrdineErogatoTestata, StatoOrderEntry, DataModificaStato, IDPrestazione, IDRigaRichiedente, IDRigaErogante, StatoErogante, Data, Operatore, Consensi)
		SELECT R.ID, R.DataInserimento, R.DataModifica, R.IDTicketInserimento, R.IDTicketModifica, R.IDOrdineErogatoTestata, R.StatoOrderEntry, R.DataModificaStato, R.IDPrestazione, R.IDRigaRichiedente, R.IDRigaErogante, R.StatoErogante, R.Data, R.Operatore, R.Consensi
			FROM dbo.OrdiniRigheErogate R
				INNER JOIN dbo.OrdiniErogatiTestate O
				ON R.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine
					
		-- Sync OrdiniRigheErogateDatiAggiuntivi - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.OrdiniRigheErogateDatiAggiuntivi
			(ID, DataInserimento, DataModifica, IDTicketInserimento, IDTicketModifica, IDRigaErogata, IDDatoAggiuntivo, Nome, TipoDato, TipoContenuto, ValoreDato, ValoreDatoVarchar, ValoreDatoXml, ParametroSpecifico, Persistente)
		SELECT DA.ID, DA.DataInserimento, DA.DataModifica, DA.IDTicketInserimento, DA.IDTicketModifica, DA.IDRigaErogata, DA.IDDatoAggiuntivo, DA.Nome, DA.TipoDato, DA.TipoContenuto, DA.ValoreDato, DA.ValoreDatoVarchar, DA.ValoreDatoXml, DA.ParametroSpecifico, DA.Persistente
			FROM dbo.OrdiniRigheErogateDatiAggiuntivi DA
			INNER JOIN dbo.OrdiniRigheErogate R
				ON DA.IDRigaErogata = R.ID 
			INNER JOIN dbo.OrdiniErogatiTestate O
				ON R.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine

		PRINT 'Richiesta letta e scritta in ' + CONVERT(VARCHAR(10), DATEDIFF(MILLISECOND, @StartTime, GETDATE())) + 'millisecondi'
		SET @StartTime = GETDATE()
				
		-- Sync MessaggiRichieste - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.MessaggiRichieste
						(ID, DataInserimento, DataModifica
						, IDTicketInserimento, IDTicketModifica, IDOrdineTestata
						, IDSistemaRichiedente, IDRichiestaRichiedente
						, Messaggio, Stato, Fault, StatoOrderEntry, DettaglioErrore)
			SELECT ID, DataInserimento, DataModifica
						, IDTicketInserimento, IDTicketModifica, IDOrdineTestata
						, IDSistemaRichiedente, IDRichiestaRichiedente
						, [Messaggio], Stato, Fault, StatoOrderEntry, DettaglioErrore
			FROM dbo.MessaggiRichieste
			WHERE IDOrdineTestata = @IdOrdine
					
		-- Sync MessaggiStati - ok sandro
		INSERT INTO AuslAsmnRe_OrderEntry.dbo.MessaggiStati
					(ID, DataInserimento, DataModifica
					, IDTicketInserimento, IDTicketModifica
					, IDOrdineErogatoTestata, IDSistemaRichiedente, IDRichiestaRichiedente
					, Messaggio, Stato, Fault, StatoOrderEntry, TipoStato, DettaglioErrore)
			SELECT M.ID, M.DataInserimento, M.DataInserimento
					, M.IDTicketInserimento, M.IDTicketModifica
					, M.IDOrdineErogatoTestata, M.IDSistemaRichiedente, M.IDRichiestaRichiedente
					, M.[Messaggio], M.Stato, M.Fault, M.StatoOrderEntry, M.TipoStato, M.DettaglioErrore
			FROM dbo.MessaggiStati M INNER JOIN dbo.OrdiniErogatiTestate O
				ON M.IDOrdineErogatoTestata = O.ID
			WHERE O.IDOrdineTestata = @IdOrdine

		PRINT 'Messaggi letti e scritti in ' + CONVERT(VARCHAR(10), DATEDIFF(MILLISECOND, @StartTime, GETDATE())) + 'millisecondi'
		SET @StartTime = GETDATE()
				
		-- Delete MessaggiStati
		DELETE FROM dbo.MessaggiStati
		FROM dbo.MessaggiStati M
			INNER JOIN dbo.OrdiniErogatiTestate O
			ON M.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete MessaggiRichieste
		DELETE FROM dbo.MessaggiRichieste
		WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniRigheErogateDatiAggiuntivi
		DELETE FROM dbo.OrdiniRigheErogateDatiAggiuntivi
		FROM dbo.OrdiniRigheErogateDatiAggiuntivi DA
			INNER JOIN dbo.OrdiniRigheErogate R
				ON DA.IDRigaErogata = R.ID
			INNER JOIN dbo.OrdiniErogatiTestate O
				ON R.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniRigheErogate
		DELETE FROM dbo.OrdiniRigheErogate
		FROM dbo.OrdiniRigheErogate R
			INNER JOIN dbo.OrdiniErogatiTestate O
			ON R.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniErogatiVersioni
		DELETE FROM dbo.OrdiniErogatiVersioni
		FROM dbo.OrdiniErogatiVersioni OV
			INNER JOIN dbo.OrdiniErogatiTestate O
			ON OV.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniErogatiTestateDatiAggiuntivi
		DELETE FROM dbo.OrdiniErogatiTestateDatiAggiuntivi
		FROM dbo.OrdiniErogatiTestateDatiAggiuntivi DA
			INNER JOIN dbo.OrdiniErogatiTestate O
			ON DA.IDOrdineErogatoTestata = O.ID
		WHERE O.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniErogatiTestate
		DELETE FROM dbo.OrdiniErogatiTestate
		WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniRigheRichiesteDatiAggiuntivi
		DELETE FROM dbo.OrdiniRigheRichiesteDatiAggiuntivi
		FROM dbo.OrdiniRigheRichiesteDatiAggiuntivi DA
			INNER JOIN dbo.OrdiniRigheRichieste R
			ON DA.IDRigaRichiesta = R.ID
		WHERE R.IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniRigheRichieste
		DELETE FROM dbo.OrdiniRigheRichieste
		WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniVersioni
		DELETE FROM dbo.OrdiniVersioni
		WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniTestateDatiAggiuntivi
		DELETE FROM dbo.OrdiniTestateDatiAggiuntivi
		WHERE IDOrdineTestata = @IdOrdine
				
		-- Delete OrdiniTestate
		DELETE FROM dbo.OrdiniTestate
		WHERE ID = @IdOrdine

		PRINT 'Richiesta cancellata in ' + CONVERT(VARCHAR(10), DATEDIFF(MILLISECOND, @StartTime, GETDATE())) + 'millisecondi'

		COMMIT
				
		-- Log
		IF @LOG = 1
		BEGIN
			BEGIN TRY
				INSERT INTO dbo.[Log] (IDOrdineTestata, Errore) VALUES (@IdOrdine, 'Restore')
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
			INSERT INTO dbo.[Log] (IDOrdineTestata, Errore) VALUES (@IdOrdine, @reason)
		END TRY
		BEGIN CATCH
		END CATCH				
	END CATCH
END
