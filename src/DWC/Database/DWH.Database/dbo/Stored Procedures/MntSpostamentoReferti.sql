
-- =============================================
-- Author:		ETTORE
-- Create date: 2015-11-20
-- Description:	Sposta i referti e gli oggetti figli nello store opportuno
-- =============================================
CREATE PROCEDURE [dbo].[MntSpostamentoReferti]
(
	@MaxNum INT = NULL
	, @Simulazione BIT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	-------------------------------------------------------------------------------------
	-- Si potrebbe provare anche la priorità di dead lock impostandola per questo task al minimo
	-------------------------------------------------------------------------------------
	--DECLARE @deadlock_intvar Integer = -10 --la minore priorità:  [-10,+10] 
	--SET DEADLOCK_PRIORITY @deadlock_intvar
	-------------------------------------------------------------------------------------
	IF @Simulazione IS NULL 
	BEGIN
		RAISERROR('Il parametro @Simulazione deve essere valorizzato: 1=Simulazione,0=Esecuzione', 16, 1)
		RETURN
	END 
	--
	-- Valorizzazione dei parametri NULL
	--
	IF @MaxNum IS NULL SET @MaxNum = 100
	--
	--
	--
	IF @Simulazione = 1 
		PRINT '-----> Modalità SIMULAZIONE'
	ELSE 
		PRINT '-----> Modalità ESECUZIONE'
	PRINT '@MaxNum=' + CAST(@MaxNum AS VARCHAR(10))
	--
	--
	--
	DECLARE @T0 AS datetime
 	SET @T0 = GETDATE()

	DECLARE @Counter INT = 0
	DECLARE @CounterSuccess  INT = 0
	DECLARE @CounterError  INT = 0
	
	DECLARE @RowNumber INT = 0
	DECLARE @LenRowNumber AS VARCHAR(10)=''
	DECLARE @Padding AS VARCHAR(10)=''

	DECLARE TheCursor CURSOR STATIC READ_ONLY FOR 
	SELECT 
		Id AS IdReferto
		, DataPartizione AS DataPartizione_Old
		, DataReferto  
	FROM	
		dbo.PartizionamentoOttieniRefertiFuoriStore (@MaxNum)
	WHERE
		DataReferto between '1900-01-01' and  '2079-06-06'
	
	--
	-- Dichiarazione delle variabili del cursore
	--
	DECLARE @IdReferto UNIQUEIDENTIFIER
	DECLARE @AziendaErogante AS VARCHAR(16) 
	DECLARE @SistemaErogante  AS VARCHAR(16) 
	DECLARE @IdEsterno AS VARCHAR(64)
	DECLARE @DataPartizione_Old SMALLDATETIME
	DECLARE @DataReferto DATETIME
	DECLARE @DataPartizione_New AS SMALLDATETIME
	
	DECLARE @tblRefertiBase AS TABLE
		(Id uniqueidentifier, DataPartizione smalldatetime ,IdEsterno varchar(64) ,IdPaziente uniqueidentifier ,DataInserimento datetime ,DataModifica datetime ,AziendaErogante varchar(16)
		 ,SistemaErogante varchar(16) ,RepartoErogante varchar(64) ,DataReferto datetime ,NumeroReferto varchar(16) ,NumeroNosologico varchar(64) ,Cancellato bit ,NumeroPrenotazione varchar(32)
		 ,DataModificaEsterno datetime ,StatoRichiestaCodice tinyint ,RepartoRichiedenteCodice varchar(16) ,RepartoRichiedenteDescr varchar(128) ,IdOrderEntry varchar(64) ,DataEvento datetime
		 ,Firmato bit)
	DECLARE @tblRefertiBaseRiferimenti AS TABLE
		(Id uniqueidentifier, DataPartizione smalldatetime ,IdRefertiBase uniqueidentifier ,IdEsterno varchar(64) ,DataInserimento datetime ,DataModificaEsterno datetime)
	DECLARE @tblRefertiAttributi AS TABLE
		(IdRefertiBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)
	DECLARE @tblPrestazioniBase AS TABLE
		(ID uniqueidentifier, IdRefertiBase uniqueidentifier, IdEsterno varchar(64), DataInserimento datetime, DataModifica datetime, DataErogazione datetime, PrestazioneCodice varchar(12), PrestazioneDescrizione varchar(150)
		, SoundexPrestazione varchar(4), SezioneCodice varchar(12), SezioneDescrizione varchar(255), SoundexSezione varchar(4), DataPartizione smalldatetime)
	DECLARE @tblPrestazioniAttributi AS TABLE
		(IdPrestazioniBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)
	DECLARE @tblAllegatiBase AS TABLE
		(ID uniqueidentifier, IdRefertiBase uniqueidentifier, IdEsterno varchar(64), DataInserimento datetime, DataModifica datetime, DataFile datetime
		, MimeType varchar(50), MimeData image, DataPartizione smalldatetime, MimeDataCompresso varbinary(max), MimeStatoCompressione tinyint, MimeDataOriginale varbinary(max))	
	DECLARE @tblAllegatiAttributi AS TABLE
		(IdAllegatiBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)
	--
	-- APERTURA del cursore
	-- 
	OPEN TheCursor

	SET @RowNumber = @@CURSOR_ROWS
	SET @LenRowNumber = LEN(CAST(@RowNumber AS VARCHAR(10)))
	SET @Padding = REPLICATE('0', @LenRowNumber)
	
	FETCH NEXT FROM TheCursor INTO @IdReferto, @DataPartizione_Old, @DataReferto
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				-- Incremento contatore
				SET @Counter = @Counter + 1
							
				PRINT RIGHT(@Padding + CAST(@Counter AS VARCHAR(10)), @LenRowNumber) + '/' + CAST(@RowNumber AS VARCHAR(10)) 
						+ ' : Referto: ' + ' Id=' +  CAST(@IdReferto AS VARCHAR(40)) + ' DataReferto: ' + CONVERT(VARCHAR(40), @DataReferto, 120) + ' DataPartizione: ' + CONVERT(VARCHAR(40), @DataPartizione_Old, 120)
				--
				-- Cancellazione delle tabelle temporanee
				--
				DELETE FROM @tblRefertiBase
				DELETE FROM @tblRefertiBaseRiferimenti
				DELETE FROM @tblRefertiAttributi
				DELETE FROM @tblPrestazioniBase
				DELETE FROM @tblPrestazioniAttributi
				DELETE FROM @tblAllegatiBase
				DELETE FROM @tblAllegatiAttributi
				--
				-- Calcolo la data di partizione
				-- Il referto è già presente quindi questa operazione va sempre a buon fine
				-- 
				SET @DataPartizione_New = CAST(@DataReferto AS SMALLDATETIME)
				-----------------------------------------------------------------------------------------------------------------------------------
				-- Caricamento delle tabelle temporanee con i dati del referto corrente e impostazione della data partizione corretta 
				-----------------------------------------------------------------------------------------------------------------------------------
				--
				-- @tblRefertiBase
				--
				INSERT INTO @tblRefertiBase(
					Id,DataPartizione,IdEsterno,IdPaziente,DataInserimento,DataModifica,AziendaErogante,SistemaErogante,RepartoErogante
				   ,DataReferto,NumeroReferto,NumeroNosologico,Cancellato,NumeroPrenotazione,DataModificaEsterno,StatoRichiestaCodice,RepartoRichiedenteCodice
				   ,RepartoRichiedenteDescr,IdOrderEntry,DataEvento,Firmato)
				SELECT            
					Id,
					@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
					,IdEsterno,IdPaziente,DataInserimento,DataModifica,AziendaErogante,SistemaErogante,RepartoErogante
				   ,DataReferto,NumeroReferto,NumeroNosologico,Cancellato,NumeroPrenotazione,DataModificaEsterno,StatoRichiestaCodice,RepartoRichiedenteCodice
				   ,RepartoRichiedenteDescr,IdOrderEntry,DataEvento,Firmato
				FROM store.RefertiBase WHERE Id = @IdReferto
				--
				-- @tblRefertiBaseRiferimenti
				--
				INSERT INTO @tblRefertiBaseRiferimenti
					(Id,DataPartizione,IdRefertiBase,IdEsterno,DataInserimento,DataModificaEsterno)
				SELECT 
					Id
					,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
					,IdRefertiBase,IdEsterno,DataInserimento,DataModificaEsterno
				FROM store.RefertiBaseRiferimenti
				WHERE IdRefertiBase = @IdReferto
				--
				-- @tblRefertiAttributi
				--
				INSERT INTO @tblRefertiAttributi(IdRefertiBase,Nome,Valore,DataPartizione)
				SELECT IdRefertiBase,Nome,Valore
						,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.RefertiAttributi WHERE IdRefertiBase = @IdReferto
				--
				-- @tblPrestazioniBase
				--
				INSERT INTO @tblPrestazioniBase
					(ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataErogazione,PrestazioneCodice,PrestazioneDescrizione
					,SoundexPrestazione,SezioneCodice,SezioneDescrizione,SoundexSezione,DataPartizione)
				SELECT 
					ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataErogazione,PrestazioneCodice,PrestazioneDescrizione
					,SoundexPrestazione,SezioneCodice,SezioneDescrizione,SoundexSezione
					,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.PrestazioniBase WHERE IdRefertiBase = @IdReferto
				--
				-- @tblPrestazioniAttributi
				--
				INSERT INTO @tblPrestazioniAttributi
					(IdPrestazioniBase,Nome,Valore,DataPartizione)
				SELECT 	
					IdPrestazioniBase,Nome,Valore
					,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.PrestazioniAttributi WHERE IdPrestazioniBase IN (
					--Leggo dalla tabella temporanea appena caricata
					SELECT Id FROM @tblPrestazioniBase 
				)
				--
				-- @tblAllegatiBase
				--
				INSERT INTO @tblAllegatiBase
					(ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataFile,MimeType,MimeData,DataPartizione,MimeDataCompresso,MimeStatoCompressione, MimeDataOriginale)
				SELECT            
					ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataFile,MimeType,MimeData
					,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
					,MimeDataCompresso, MimeStatoCompressione, MimeDataOriginale
				FROM store.AllegatiBase WHERE IdRefertiBase = @IdReferto
				--
				-- @tblAllegatiAttributi
				--
				INSERT INTO @tblAllegatiAttributi
					(IdAllegatiBase,Nome,Valore,DataPartizione)
				SELECT 	
					IdAllegatiBase,Nome,Valore
					,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.AllegatiAttributi WHERE IdAllegatiBase IN (
					--Leggo dalla tabella temporanea appena caricata
					SELECT Id FROM @tblAllegatiBase
				)
				-----------------------------------------------------------------------------------------------------------------------------------
				-- Fine caricamento delle tabelle temporanee
				-----------------------------------------------------------------------------------------------------------------------------------
				--
				-- Aggiornamento del database
				--
				IF @Simulazione = 0
				BEGIN
					--
					-- Cancellazione del referto attuale: questo ordine deve essere l'inverso di quello usato nella data access per inserire
					--
					DELETE FROM store.AllegatiAttributi WHERE IdAllegatiBase IN (
						--Leggo dalla tabella temporanea
						SELECT Id FROM @tblAllegatiBase 
					)					
					DELETE FROM store.AllegatiBase WHERE IdRefertiBase = @IdReferto					
					DELETE FROM store.PrestazioniAttributi WHERE IdPrestazioniBase IN (
						--Leggo dalla tabella temporanea
						SELECT Id FROM @tblPrestazioniBase
					)
					DELETE FROM store.PrestazioniBase WHERE IdRefertiBase = @IdReferto					
					DELETE FROM store.RefertiAttributi WHERE IdRefertiBase = @IdReferto					
					DELETE FROM store.RefertiBaseRiferimenti WHERE IdRefertiBase = @IdReferto
					DELETE FROM store.RefertiBase WHERE Id = @IdReferto
					--
					-- Inserimento dei dati del referto con data di partizione corretta (SQL trova da solo in quale store inserire i dati)
					--
					--
					-- RefertiBase
					--
					INSERT INTO store.RefertiBase(
						Id,DataPartizione,IdEsterno,IdPaziente,DataInserimento,DataModifica,AziendaErogante,SistemaErogante,RepartoErogante
						,DataReferto,NumeroReferto,NumeroNosologico,Cancellato,NumeroPrenotazione,DataModificaEsterno,StatoRichiestaCodice,RepartoRichiedenteCodice
						,RepartoRichiedenteDescr,IdOrderEntry,DataEvento,Firmato)
					SELECT            
						Id,DataPartizione,IdEsterno,IdPaziente,DataInserimento,DataModifica,AziendaErogante,SistemaErogante,RepartoErogante
						,DataReferto,NumeroReferto,NumeroNosologico,Cancellato,NumeroPrenotazione,DataModificaEsterno,StatoRichiestaCodice,RepartoRichiedenteCodice
						,RepartoRichiedenteDescr,IdOrderEntry,DataEvento,Firmato
					FROM @tblRefertiBase 
					--
					-- RefertiBaseRiferimenti
					--
					INSERT INTO store.RefertiBaseRiferimenti
						(Id,DataPartizione,IdRefertiBase,IdEsterno,DataInserimento,DataModificaEsterno)
					SELECT 
						Id,DataPartizione,IdRefertiBase,IdEsterno,DataInserimento,DataModificaEsterno
					FROM @tblRefertiBaseRiferimenti
					--
					-- RefertiAttributi
					--
					INSERT INTO store.RefertiAttributi(IdRefertiBase,Nome,Valore,DataPartizione)
					SELECT IdRefertiBase,Nome,Valore,DataPartizione 
					FROM @tblRefertiAttributi
					--
					-- PrestazioniBase
					--
					INSERT INTO store.PrestazioniBase
						(ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataErogazione,PrestazioneCodice,PrestazioneDescrizione
						,SoundexPrestazione,SezioneCodice,SezioneDescrizione,SoundexSezione,DataPartizione)
					SELECT 
						ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataErogazione,PrestazioneCodice,PrestazioneDescrizione
						,SoundexPrestazione,SezioneCodice,SezioneDescrizione,SoundexSezione,DataPartizione 
					FROM @tblPrestazioniBase 
					--
					-- PrestazioniAttributi
					--
					INSERT INTO store.PrestazioniAttributi
						(IdPrestazioniBase,Nome,Valore,DataPartizione)
					SELECT 	
						IdPrestazioniBase,Nome,Valore,DataPartizione
					FROM @tblPrestazioniAttributi
					--
					-- AllegatiBase
					--
					INSERT INTO store.AllegatiBase
						(ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataFile,MimeType,MimeData,DataPartizione,MimeDataCompresso,MimeStatoCompressione, MimeDataOriginale)
					SELECT            
						ID,IdRefertiBase,IdEsterno,DataInserimento,DataModifica,DataFile,MimeType,MimeData,DataPartizione,MimeDataCompresso,MimeStatoCompressione, MimeDataOriginale
					FROM @tblAllegatiBase
					--
					-- AllegatiAttributi
					--
					INSERT INTO store.AllegatiAttributi
						(IdAllegatiBase,Nome,Valore,DataPartizione)
					SELECT 	
						IdAllegatiBase,Nome,Valore,DataPartizione
					FROM @tblAllegatiAttributi					
				END
						
				SET @CounterSuccess = @CounterSuccess + 1
				--
				-- COMMIT DELLA TRANSAZIONE
				--
				COMMIT
				
			END TRY
			BEGIN CATCH
				IF @@TRANCOUNT > 0 
					ROLLBACK TRANSACTION
				
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
		FETCH NEXT FROM TheCursor INTO @IdReferto, @DataPartizione_Old, @DataReferto
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
	PRINT 'Numero referti totali elaborati=' + CAST(@Counter AS VARCHAR(10)) + ' Success=' + CAST(@CounterSuccess AS VARCHAR(10)) + ' Error=' + CAST(@CounterError AS VARCHAR(10)) 
	PRINT 'Fine'
END