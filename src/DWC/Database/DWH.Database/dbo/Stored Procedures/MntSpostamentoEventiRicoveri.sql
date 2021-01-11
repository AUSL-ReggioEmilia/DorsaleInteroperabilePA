
-- =============================================
-- Author:		ETTORE
-- Create date: 2015-11-20
-- Description:	Spostamento eventi e ricoveri nello store opportuno
-- =============================================
CREATE PROCEDURE [dbo].[MntSpostamentoEventiRicoveri]
(
	@MaxNum INT = NULL
	, @Simulazione BIT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	-------------------------------------------------------------------
	-- Si potrebbe provare anche la priorità di dead lock
	-------------------------------------------------------------------
	--DECLARE @deadlock_intvar Integer = -10 --la minore priorità:  [-10,+10] 
	--SET DEADLOCK_PRIORITY @deadlock_intvar
	-------------------------------------------------------------------
	SET NOCOUNT ON;
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
		DataPartizione AS DataPartizione_Old
		, DataAccettazione --la data da cui derivare la data di partizione
		, AziendaErogante
		, NumeroNosologico
	FROM 
		dbo.PartizionamentoOttieniNosologiciFuoriStore(@MaxNum)	
	WHERE
		DataAccettazione between '1900-01-01' and  '2079-06-06' --il range del tipo SMALLDATETIME 

	--
	-- Dichiarazione delle variabili del cursore
	--
	DECLARE @IdEvento UNIQUEIDENTIFIER
	DECLARE @SistemaErogante  AS VARCHAR(16) 
	DECLARE @IdEsterno AS VARCHAR(64)
	DECLARE @DataPartizione_Old SMALLDATETIME
	DECLARE @DataAccettazione DATETIME
	DECLARE @DataPartizione_New AS SMALLDATETIME
	DECLARE @AziendaErogante AS VARCHAR(16) 	
	DECLARE @NumeroNosologico AS VARCHAR(64)
	
	DECLARE @tblEventiBase AS TABLE
       (Id uniqueidentifier,IdEsterno varchar(64),DataModificaEsterno datetime,IdPaziente uniqueidentifier,DataInserimento datetime,DataModifica datetime
       ,AziendaErogante varchar(16),SistemaErogante varchar(16),RepartoErogante varchar(64),DataEvento datetime,StatoCodice int
       ,TipoEventoCodice varchar(16),TipoEventoDescr varchar(64),NumeroNosologico varchar(64),TipoEpisodio varchar(16)
       ,RepartoCodice varchar(16),RepartoDescr varchar(128),Diagnosi varchar(1024),DataPartizione smalldatetime)
	DECLARE @tblEventiAttributi AS TABLE
		(IdEventiBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)
	DECLARE @tblRicoveriBase AS TABLE		
           (Id uniqueidentifier ,IdEsterno varchar(64) ,DataModificaEsterno datetime ,DataInserimento datetime ,DataModifica datetime
           ,StatoCodice tinyint ,Cancellato bit ,NumeroNosologico varchar(64) ,AziendaErogante varchar(16) ,SistemaErogante varchar(16)
           ,RepartoErogante varchar(64), IdPaziente uniqueidentifier,OspedaleCodice varchar(16),OspedaleDescr varchar(128)
           ,TipoRicoveroCodice varchar(16),TipoRicoveroDescr varchar(128),Diagnosi varchar(1024),DataAccettazione datetime
           ,RepartoAccettazioneCodice varchar(16),RepartoAccettazioneDescr varchar(128),DataTrasferimento datetime
           ,RepartoCodice varchar(16),RepartoDescr varchar(128),SettoreCodice varchar(16),SettoreDescr varchar(128)
           ,LettoCodice varchar(16),DataDimissione datetime,DataPartizione smalldatetime)
	DECLARE @tblRicoveriAttributi AS TABLE
		(IdRicoveriBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)
		
	--
	-- APERTURA del cursore
	-- 
	OPEN TheCursor

	SET @RowNumber = @@CURSOR_ROWS
	SET @LenRowNumber = LEN(CAST(@RowNumber AS VARCHAR(10)))
	SET @Padding = REPLICATE('0', @LenRowNumber)
	
	FETCH NEXT FROM TheCursor INTO @DataPartizione_Old, @DataAccettazione, @AziendaErogante, @NumeroNosologico
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				-- Incremento contatore
				SET @Counter = @Counter + 1
							
				PRINT RIGHT(@Padding + CAST(@Counter AS VARCHAR(10)), @LenRowNumber) + '/' + CAST(@RowNumber AS VARCHAR(10)) 
						+ ' : Nosologico: ' + @AziendaErogante + ' ' + @NumeroNosologico + ' DataAccettazione: ' + CONVERT(VARCHAR(40), @DataAccettazione, 120) + ' DataPartizione: ' + CONVERT(VARCHAR(40), @DataPartizione_Old, 120)
		
				--
				-- Cancellazione delle tabelle temporanee
				--
				DELETE FROM @tblEventiBase
				DELETE FROM @tblEventiAttributi
				DELETE FROM @tblRicoveriBase
				DELETE FROM @tblRicoveriAttributi
				--
				-- Calcolo la data di partizione
				--
				SET @DataPartizione_New = CAST(@DataAccettazione AS SMALLDATETIME)
				-----------------------------------------------------------------------------------------------------------------------------------
				-- Caricamento delle tabelle temporanee con i dati del referto corrente e impostazione della data partizione corretta 
				-----------------------------------------------------------------------------------------------------------------------------------
				--
				-- @tblEventiBase
				-- 
				INSERT INTO @tblEventiBase(
					Id, IdEsterno, DataModificaEsterno, IdPaziente, DataInserimento, DataModifica, AziendaErogante, SistemaErogante
				   , RepartoErogante, DataEvento, StatoCodice, TipoEventoCodice, TipoEventoDescr, NumeroNosologico, TipoEpisodio, RepartoCodice
				   , RepartoDescr, Diagnosi
				   , DataPartizione)
				SELECT            
					Id, IdEsterno, DataModificaEsterno, IdPaziente, DataInserimento, DataModifica, AziendaErogante, SistemaErogante
				   , RepartoErogante, DataEvento, StatoCodice, TipoEventoCodice, TipoEventoDescr, NumeroNosologico, TipoEpisodio, RepartoCodice
				   , RepartoDescr, Diagnosi
				   , @DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.EventiBase 
				WHERE AziendaErogante = @AziendaErogante AND NumeroNosologico = @NumeroNosologico 
				--
				-- @tblEventiAttributi
				--
				INSERT INTO @tblEventiAttributi(IdEventiBase, Nome, Valore, DataPartizione)
				SELECT 
					IdEventiBase ,Nome,Valore
					, @DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.EventiAttributi 
				WHERE IdEventiBase IN (SELECT Id FROM @tblEventiBase)
				--
				-- @tblRicoveriBase
				--
				INSERT INTO @tblRicoveriBase
					(Id, IdEsterno, DataModificaEsterno, DataInserimento, DataModifica, StatoCodice, Cancellato
					, NumeroNosologico, AziendaErogante, SistemaErogante, RepartoErogante, IdPaziente, OspedaleCodice, OspedaleDescr
					, TipoRicoveroCodice, TipoRicoveroDescr, Diagnosi, DataAccettazione, RepartoAccettazioneCodice, RepartoAccettazioneDescr
					, DataTrasferimento, RepartoCodice, RepartoDescr, SettoreCodice, SettoreDescr, LettoCodice, DataDimissione
					, DataPartizione)
				SELECT            
					Id, IdEsterno, DataModificaEsterno, DataInserimento, DataModifica, StatoCodice, Cancellato
					, NumeroNosologico, AziendaErogante, SistemaErogante, RepartoErogante, IdPaziente, OspedaleCodice, OspedaleDescr
					, TipoRicoveroCodice, TipoRicoveroDescr, Diagnosi, DataAccettazione, RepartoAccettazioneCodice, RepartoAccettazioneDescr
					, DataTrasferimento, RepartoCodice, RepartoDescr, SettoreCodice, SettoreDescr, LettoCodice, DataDimissione
					, @DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.RicoveriBase 
				WHERE 
					AziendaErogante = @AziendaErogante 
					AND NumeroNosologico = @NumeroNosologico 
				--
				-- @tblRicoveriAttributi
				--
				INSERT INTO @tblRicoveriAttributi
					(IdRicoveriBase,Nome,Valore,DataPartizione)
				SELECT 	
					IdRicoveriBase, Nome, Valore
					,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.RicoveriAttributi 
				WHERE IdRicoveriBase IN (
							SELECT Id FROM @tblRicoveriBase
						)
				-----------------------------------------------------------------------------------------------------------------------------------
				-- Fine caricamento delle tabelle temporanee
				-----------------------------------------------------------------------------------------------------------------------------------
				--
				--
				--
				IF @Simulazione = 0
				BEGIN
					--
					-- Cancellazione del referto attuale: questo ordine deve essere l'inverso di quello usato nella data access per inserire
					--
					DELETE FROM store.RicoveriAttributi 
					WHERE IdRicoveriBase IN (
						SELECT Id FROM @tblRicoveriBase 
					)					
					DELETE FROM store.RicoveriBase 
					WHERE Id IN (
						SELECT Id FROM @tblRicoveriBase 
					)
					DELETE FROM store.EventiAttributi 
					WHERE IdEventiBase IN (
						SELECT Id FROM @tblEventiBase 
					)
					DELETE FROM store.EventiBase 
					WHERE Id IN (
						SELECT Id FROM @tblEventiBase 
					)
					--
					-- Inserimento dei dati eventi/ricovero con data di partizione corretta (SQL trova da solo in quale store inserire i dati)
					--
					--
					-- EventiBase
					--
					INSERT INTO store.EventiBase(
						Id, IdEsterno, DataModificaEsterno, IdPaziente, DataInserimento, DataModifica, AziendaErogante, SistemaErogante
						, RepartoErogante, DataEvento, StatoCodice, TipoEventoCodice, TipoEventoDescr, NumeroNosologico, TipoEpisodio, RepartoCodice
						, RepartoDescr, Diagnosi, DataPartizione)
					SELECT            
						Id, IdEsterno, DataModificaEsterno, IdPaziente, DataInserimento, DataModifica, AziendaErogante, SistemaErogante
						, RepartoErogante, DataEvento, StatoCodice, TipoEventoCodice, TipoEventoDescr, NumeroNosologico, TipoEpisodio, RepartoCodice
						, RepartoDescr, Diagnosi, DataPartizione
					FROM @tblEventiBase 
					--
					-- EventiAttributi
					--
					INSERT INTO store.EventiAttributi(IdEventiBase,Nome,Valore,DataPartizione)
					SELECT IdEventiBase,Nome,Valore,DataPartizione 
					FROM @tblEventiAttributi
					--
					-- RicoveriBase
					--
					INSERT INTO store.RicoveriBase (
						Id, IdEsterno, DataModificaEsterno, DataInserimento, DataModifica, StatoCodice, Cancellato
						, NumeroNosologico, AziendaErogante, SistemaErogante, RepartoErogante, IdPaziente, OspedaleCodice, OspedaleDescr
						, TipoRicoveroCodice, TipoRicoveroDescr, Diagnosi, DataAccettazione, RepartoAccettazioneCodice, RepartoAccettazioneDescr
						, DataTrasferimento, RepartoCodice, RepartoDescr, SettoreCodice, SettoreDescr, LettoCodice, DataDimissione, DataPartizione)
					SELECT            
						Id, IdEsterno, DataModificaEsterno, DataInserimento, DataModifica, StatoCodice, Cancellato
						, NumeroNosologico, AziendaErogante, SistemaErogante, RepartoErogante, IdPaziente, OspedaleCodice, OspedaleDescr
						, TipoRicoveroCodice, TipoRicoveroDescr, Diagnosi, DataAccettazione, RepartoAccettazioneCodice, RepartoAccettazioneDescr
						, DataTrasferimento, RepartoCodice, RepartoDescr, SettoreCodice, SettoreDescr, LettoCodice, DataDimissione, DataPartizione
					FROM @tblRicoveriBase
					--
					-- RicoveriAttributi
					--
					INSERT INTO store.RicoveriAttributi
						(IdRicoveriBase,Nome,Valore,DataPartizione)
					SELECT 	
						IdRicoveriBase,Nome,Valore,DataPartizione
					FROM @tblRicoveriAttributi					
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
		FETCH NEXT FROM TheCursor INTO @DataPartizione_Old, @DataAccettazione, @AziendaErogante, @NumeroNosologico
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
	PRINT 'Numero NOSOLOGICI totali elaborati=' + CAST(@Counter AS VARCHAR(10)) + ' Success=' + CAST(@CounterSuccess AS VARCHAR(10)) + ' Error=' + CAST(@CounterError AS VARCHAR(10)) 
	PRINT 'Fine'	
END