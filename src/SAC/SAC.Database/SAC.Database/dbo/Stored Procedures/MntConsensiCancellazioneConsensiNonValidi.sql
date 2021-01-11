-- =============================================
-- Author:		Ettore
-- Create date: 2015-09-09
-- Description:	Cancella i consensi di tipo 1,2 3 di pazienti maggiorenni che avevano acuisito uno o più consensi in minore età
-- =============================================
CREATE PROCEDURE [dbo].[MntConsensiCancellazioneConsensiNonValidi]
(
	@MaxPazienti INT = 100 
	, @Simulazione BIT = NULL
)
AS
BEGIN
/*
	1) Esegue un cursore che trova i pazienti attivi maggiorenni ai quali sono associati consensi acquisiti in minore età di tipo 1=GENERICO, 2=DOSSIER, 3=STORICO
	2) Per ogni paziente trovato verifica se fra i CONSENSI VALIDI (quelli aggregati) è presente almeno un consenso preso in minore età e in questo caso cancella tutti i consensi del paziente di tipo 1=GENERICO, 2=DOSSIER, 3=STORICO
	3) Se fra i CONSENSI VALIDI non vi sono consensi presi in minore età allora vengono cancellati solo i consensi presi in minore età (tanto non sono più validi e non fanno parte dei CONSENSI VALIDI) di tipo 1=GENERICO, 2=DOSSIER, 3=STORICO
*/
	SET NOCOUNT ON;
	IF @MaxPazienti IS NULL SET @MaxPazienti = 100
	IF @Simulazione IS NULL 
	BEGIN
		RAISERROR('Il parametro @Simulazione deve essere valorizzato: 1=Simulazione,0=Esecuzione', 16, 1)
		RETURN
	END 
	
	IF @Simulazione = 1
		PRINT '-----> Esecuzione in modalità SIMULAZIONE'
	
	DECLARE @T0 AS datetime
 	SET @T0 = GETDATE()

	DECLARE @UtenteOperazione	AS VARCHAR(128) = suser_sname()
	DECLARE @MotivoOperazione AS VARCHAR(1024) = 'Cancellazione consensi acquisiti in minore età'
	DECLARE @Counter INT = 0
	DECLARE @CounterSuccess  INT = 0
	DECLARE @CounterError  INT = 0
	
	DECLARE @RowNumber INT = 0
	DECLARE @LenRowNumber AS VARCHAR(10)=''
	DECLARE @Padding AS VARCHAR(10)=''

	DECLARE TheCursor CURSOR STATIC READ_ONLY FOR 
	SELECT DISTINCT TOP (@MaxPazienti)
		P.Id AS IdPazientePadre
		, P.DataNascita
		, P.Cognome AS PazienteCognome, P.Nome AS PazienteNome, P.CodiceFiscale AS PazienteCodiceFiscale
	FROM 
		ConsensiPazienti AS C
		INNER JOIN Pazienti AS P
			ON C.IdPaziente = P.Id
	WHERE P.Disattivato = 0
		AND P.DataNascita > '1900-01-01'
		AND C.IdTipo IN (1,2,3)									--Solo consensi DWH: GENERICO, DOSSIER, STORICO
		AND dbo.GetEta(P.DataNascita ,GETDATE()) > 18			--che sono maggiorenni		
		AND dbo.GetEta(P.DataNascita ,C.DataStato) > 0			--Età di acquisizione del consenso positiva (ci sono date di acquisizione consenso < 1900-01-01)
		AND dbo.GetEta(P.DataNascita, C.DataStato) < 18			--consenso acquisito prima dei 18 anni	
		AND P.Id <> '00000000-0000-0000-0000-000000000000'
		AND C.Disattivato = 0
	--
	-- Dichiarazione delle variabili del cursore
	--
	DECLARE @IdPazientePadre AS UNIQUEIDENTIFIER
	DECLARE @DataNascita AS DATETIME
	DECLARE @DataStato AS DATETIME
	DECLARE @PazienteCognome AS VARCHAR(64)
	DECLARE @PazienteNome AS VARCHAR(64)
	DECLARE @PazienteCodiceFiscale AS VARCHAR(64)
	DECLARE @TableConsensiAggregati AS TABLE(Id UNIQUEIDENTIFIER, IdPaziente UNIQUEIDENTIFIER, IdPazienteFuso UNIQUEIDENTIFIER, PazienteCognome VARCHAR(64), PazienteNome VARCHAR(64), PazienteCodiceFiscale VARCHAR(16), PazienteDataNascita DATETIME, IdTipo TINYINT, DataStato DATETIME, Stato Bit, Disattivato BIT)
	DECLARE @TableConsensiPazienti AS TABLE 
		(
		 Id UNIQUEIDENTIFIER, DataInserimento datetime, DataDisattivazione datetime, Disattivato tinyint, Provenienza varchar(16), IdProvenienza varchar(64), IdPaziente uniqueidentifier
		 , IdPazienteFuso uniqueidentifier, IdTipo tinyint, DataStato datetime, Stato bit, OperatoreId varchar(64), OperatoreCognome varchar(64), OperatoreNome varchar(64), OperatoreComputer varchar(64)
		 , PazienteProvenienza varchar(16), PazienteIdProvenienza varchar(64), PazienteCognome varchar(64), PazienteNome varchar(64), PazienteCodiceFiscale varchar(16)
		 , PazienteDataNascita datetime, PazienteComuneNascitaCodice varchar(6), PazienteNazionalitaCodice varchar(3), PazienteTessera varchar(16), MetodoAssociazione varchar(32)
		 )
	--
	-- APERTURA del cursore
	-- 
	OPEN TheCursor

	SET @RowNumber = @@CURSOR_ROWS
	SET @LenRowNumber = LEN(CAST(@RowNumber AS VARCHAR(10)))
	SET @Padding = REPLICATE('0', @LenRowNumber)
	
	FETCH NEXT FROM TheCursor INTO @IdPazientePadre, @DataNascita, @PazienteCognome, @PazienteNome, @PazienteCodiceFiscale
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				-- Incremento contatore
				SET @Counter = @Counter + 1
							
				PRINT RIGHT(@Padding + CAST(@Counter AS VARCHAR(10)), @LenRowNumber) + '/' + CAST(@RowNumber AS VARCHAR(10)) 
						+ ' : Anagrafica: ' + ' IdPaziente=' +  CAST(@IdPazientePadre AS VARCHAR(40)) +' Cognome=' + @PazienteCognome + ' Nome=' + @PazienteNome + ' CodiceFiscale=' + @PazienteCodiceFiscale + ' Data nascita=' + CONVERT(VARCHAR(10), @DataNascita , 120)
				--
				-- Svuoto le tabelle temporanee
				--
				DELETE FROM @TableConsensiAggregati
				DELETE FROM @TableConsensiPazienti				
				--
				-- Se sono qui per il paziente @IdPazientePadre allora ci sono consensi presi in minore età 
				-- Eseguo query per ottenere i "CONSENSI AGGREGATI" (=gli ultimi validi) di tipo 1,2,3 e verifico se fra questi consensi ve ne sono di presi in minore età:
				--	1) se ve ne sono leggo TUTTI i consensi del paziente di tipo 1,2,3 e li salvo in tabella di LOG e li cancello
				--  2) se fra i consensi aggregati di tipo 1,2,3 NON ve ne sono di presi in minore età allora significa che quelli presi in minore età sono stati "sovrascritti"
				--	   da consensi acquisiti successivamente e quindi seleziono tutti i consensi non aggregati di tipo 1,2,3 presi in minore età, li salvo in tabella di log e li cancello 
				--
				INSERT INTO @TableConsensiAggregati(Id, IdPaziente, IdPazienteFuso, PazienteCognome, PazienteNome, PazienteCodiceFiscale, PazienteDataNascita, IdTipo, DataStato, Stato, Disattivato)
				SELECT Id, IdPaziente, IdPazienteFuso, PazienteCognome, PazienteNome, PazienteCodiceFiscale, PazienteDataNascita, IdTipo, DataStato, Stato, Disattivato
				FROM ConsensiPazientiAggregati 
				WHERE IdPaziente = @IdPazientePadre
					AND IdTipo IN (1,2,3)	--Solo consensi DWH: GENERICO, DOSSIER, STORICO
				
				--
				-- Se esiste un consenso preso in minore età fra i consensi validi (consensi aggregati)
				--
				IF EXISTS(SELECT * FROM @TableConsensiAggregati AS C 
							WHERE 
								C.Disattivato = 0
								AND dbo.GetEta(@DataNascita,C.DataStato) < 18					--consenso acquisito prima dei 18 anni	
						)
				BEGIN
					PRINT 'Cancello TUTTI i consensi di tipo 1,2,3'
					--Se sono qui ci sono consensi fra i consensi validi (aggregati) che sono stati presi in minore età quindi devo cancellare TUTTI i consensi:
					--1) Leggo TUTTI i consensi del paziente di tipo 1,2,3 (a prescindere se sono attivi o no)
					--2) Li salvo nella tabella di LOG
					--3) Li cancello per IdConsenso
					INSERT INTO @TableConsensiPazienti (Id, DataInserimento,DataDisattivazione,Disattivato,Provenienza,IdProvenienza,IdPaziente,IdPazienteFuso
					,IdTipo,DataStato,Stato,OperatoreId,OperatoreCognome,OperatoreNome,OperatoreComputer,PazienteProvenienza,PazienteIdProvenienza
					,PazienteCognome,PazienteNome,PazienteCodiceFiscale,PazienteDataNascita,PazienteComuneNascitaCodice,PazienteNazionalitaCodice,PazienteTessera,MetodoAssociazione)
					SELECT 
						Id, DataInserimento,DataDisattivazione,Disattivato,Provenienza,IdProvenienza,IdPaziente,IdPazienteFuso
					   ,IdTipo,DataStato,Stato,OperatoreId,OperatoreCognome,OperatoreNome,OperatoreComputer,PazienteProvenienza,PazienteIdProvenienza
					   ,PazienteCognome,PazienteNome,PazienteCodiceFiscale,PazienteDataNascita,PazienteComuneNascitaCodice,PazienteNazionalitaCodice,PazienteTessera,MetodoAssociazione
					 FROM ConsensiPazienti
					 WHERE 
						[IdPaziente] = @IdPazientePadre
						AND IdTipo IN (1,2,3)	--Solo consensi DWH: GENERICO, DOSSIER, STORICO						
						

					IF @Simulazione = 0
					BEGIN					
						--
						-- Li salvo TUTTI in tabella di LOG
						--
						INSERT INTO ConsensiLog
							(DataOperazione, UtenteOperazione, MotivoOperazione
							, DataInserimento, DataDisattivazione, Disattivato, Provenienza,IdProvenienza
							, IdPaziente
							, IdTipo, DataStato, Stato, OperatoreId, OperatoreCognome, OperatoreNome, OperatoreComputer, PazienteProvenienza,PazienteIdProvenienza
							, PazienteCognome, PazienteNome, PazienteCodiceFiscale, PazienteDataNascita, PazienteComuneNascitaCodice, PazienteNazionalitaCodice, PazienteTessera, MetodoAssociazione)
						SELECT 
							GETDATE() AS DataOperazione, @UtenteOperazione AS UtenteOperazione, @MotivoOperazione AS MotivoOperazione 
							, DataInserimento, DataDisattivazione, Disattivato, Provenienza, IdProvenienza
							--Se IdPazienteFuso è valorizzato uso IdPazienteFuso altrimenti IdPaziente
							, ISNULL(IdPazienteFuso, IdPaziente) AS IdPaziente
							, IdTipo, DataStato, Stato, OperatoreId, OperatoreCognome, OperatoreNome, OperatoreComputer, PazienteProvenienza, PazienteIdProvenienza
							, PazienteCognome, PazienteNome, PazienteCodiceFiscale, PazienteDataNascita, PazienteComuneNascitaCodice, PazienteNazionalitaCodice, PazienteTessera, MetodoAssociazione						
						FROM 
							@TableConsensiPazienti AS TAB
						--
						-- Li cancello TUTTI
						--
						DELETE FROM ConsensiNotificheUtenti WHERE IdConsensiNotifica IN (
							SELECT Id FROM ConsensiNotifiche WHERE IdConsenso IN (
								SELECT Id FROM @TableConsensiPazienti
							)
						)
						DELETE FROM ConsensiNotifiche WHERE IdConsenso IN (
							SELECT Id FROM @TableConsensiPazienti
						)
						DELETE FROM Consensi WHERE Id IN (
							SELECT Id FROM @TableConsensiPazienti
						)
					END
				END 
				ELSE
				BEGIN
					PRINT 'Cancello SOLO i consensi di tipo 1,2,3 acquisiti in minore età'
					--
					-- I consensi validi (aggregati) NON contengono consensi acquisiti in minore età
					-- Loggo e cancello solo i consensi presi in minore età (anche quelli Disattivati)
					--
					INSERT INTO @TableConsensiPazienti (Id, DataInserimento,DataDisattivazione,Disattivato,Provenienza,IdProvenienza,IdPaziente,IdPazienteFuso
					,IdTipo,DataStato,Stato,OperatoreId,OperatoreCognome,OperatoreNome,OperatoreComputer,PazienteProvenienza,PazienteIdProvenienza
					,PazienteCognome,PazienteNome,PazienteCodiceFiscale,PazienteDataNascita,PazienteComuneNascitaCodice,PazienteNazionalitaCodice,PazienteTessera,MetodoAssociazione)
					SELECT 
						Id, DataInserimento,DataDisattivazione,Disattivato,Provenienza,IdProvenienza,IdPaziente,IdPazienteFuso
					   ,IdTipo,DataStato,Stato,OperatoreId,OperatoreCognome,OperatoreNome,OperatoreComputer,PazienteProvenienza,PazienteIdProvenienza
					   ,PazienteCognome,PazienteNome,PazienteCodiceFiscale,PazienteDataNascita,PazienteComuneNascitaCodice,PazienteNazionalitaCodice,PazienteTessera,MetodoAssociazione
					 FROM ConsensiPazienti
					 WHERE 
						[IdPaziente] = @IdPazientePadre
						AND IdTipo IN (1,2,3)								--Solo consensi DWH: GENERICO, DOSSIER, STORICO
						AND dbo.GetEta(@DataNascita, DataStato) < 18		--consenso acquisito prima dei 18 anni	


					IF @Simulazione = 0 
					BEGIN						
						--
						-- Li salvo in tabella di LOG
						--			
						INSERT INTO ConsensiLog
							(DataOperazione, UtenteOperazione, MotivoOperazione
							, DataInserimento, DataDisattivazione, Disattivato, Provenienza,IdProvenienza
							, IdPaziente
							, IdTipo, DataStato, Stato, OperatoreId, OperatoreCognome, OperatoreNome, OperatoreComputer, PazienteProvenienza,PazienteIdProvenienza
							, PazienteCognome, PazienteNome, PazienteCodiceFiscale, PazienteDataNascita, PazienteComuneNascitaCodice, PazienteNazionalitaCodice, PazienteTessera, MetodoAssociazione)
						SELECT 
							GETDATE() AS DataOperazione, @UtenteOperazione AS UtenteOperazione, @MotivoOperazione AS MotivoOperazione 
							, DataInserimento, DataDisattivazione, Disattivato, Provenienza, IdProvenienza
							--Se IdPazienteFuso è valorizzato uso IdPazienteFuso altrimenti IdPaziente
							, ISNULL(IdPazienteFuso, IdPaziente) AS IdPaziente
							, IdTipo, DataStato, Stato, OperatoreId, OperatoreCognome, OperatoreNome, OperatoreComputer, PazienteProvenienza, PazienteIdProvenienza
							, PazienteCognome, PazienteNome, PazienteCodiceFiscale, PazienteDataNascita, PazienteComuneNascitaCodice, PazienteNazionalitaCodice, PazienteTessera, MetodoAssociazione						
						FROM 
							@TableConsensiPazienti AS TAB
						--
						-- Li cancello 
						-- Cancello eventualmente ConsensiNotificheUtenti e ConsensiNotifiche
						--
						DELETE FROM ConsensiNotificheUtenti WHERE IdConsensiNotifica IN (
							SELECT Id FROM ConsensiNotifiche WHERE IdConsenso IN (
								SELECT Id FROM @TableConsensiPazienti
							)
						)
						DELETE FROM ConsensiNotifiche WHERE IdConsenso IN (
							SELECT Id FROM @TableConsensiPazienti
						)
						DELETE FROM Consensi WHERE Id IN (
							SELECT Id FROM @TableConsensiPazienti
						)
					END
				END
				
				SET @CounterSuccess = @CounterSuccess + 1
				--
				-- COMMIT DELLA TRANSAZIONE
				--
				COMMIT
				
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
				
				SET @CounterError = @CounterError  + 1

				DECLARE @xact_state INT
				DECLARE @msg NVARCHAR(2000)
				SELECT @xact_state = xact_state(), @msg = error_message()

				DECLARE @report NVARCHAR(4000);
				SELECT @report = N'Errore: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
				PRINT '---------------------------'
				PRINT @report;						
				PRINT '---------------------------'
			END CATCH
		END
		FETCH NEXT FROM TheCursor INTO @IdPazientePadre, @DataNascita, @PazienteCognome, @PazienteNome, @PazienteCodiceFiscale--, @IdConsenso, @IdTipoConsenso
	END
	--
	-- Chiusura del cursore
	--
	CLOSE TheCursor
	DEALLOCATE TheCursor
	--
	-- Report
	--	
	PRINT 'Durata=' + CAST(DATEDIFF(ms, @T0, GETDATE()) AS VARCHAR(10)) + ' ms'
	PRINT 'Pazienti totali elaborati=' + CAST(@Counter AS VARCHAR(10)) + ' Success=' + CAST(@CounterSuccess AS VARCHAR(10)) + ' Error=' + CAST(@CounterError AS VARCHAR(10)) 
	PRINT 'Fine'

END
