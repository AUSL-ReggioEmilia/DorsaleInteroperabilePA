




-- =============================================
-- Author:		ETTORE
-- Create date: 2015-11-25
-- Modify date: 2016-08-11 : Nuova struttura Base + Attributi invece di campo XML
-- Modify date: 2017-11-23 : ETTORE Cancellazione di tutte le tabelle temporanee
-- Description:	Sposta le prescrizioni e gli oggetti figli nello store opportuno
-- =============================================
CREATE PROCEDURE [dbo].[MntSpostamentoPrescrizioni]
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
		, DataPrescrizione
	FROM	
		dbo.PartizionamentoOttieniPrescrizioniFuoriStore (@MaxNum)
	WHERE
		DataPrescrizione between '1900-01-01' and  '2079-06-06'
	--
	-- Dichiarazione delle variabili del cursore
	--
	DECLARE @IdPrescrizione UNIQUEIDENTIFIER
	DECLARE @DataPartizione_Old SMALLDATETIME
	DECLARE @DataPrescrizione DATETIME
	DECLARE @DataPartizione_New AS SMALLDATETIME
	
	DECLARE @tblPrescrizioni AS TABLE (
		Id uniqueidentifier, DataPartizione smalldatetime, IdEsterno varchar(64), IdPaziente uniqueidentifier, DataInserimento datetime, DataModifica datetime,
		DataModificaEsterno datetime, StatoCodice tinyint, TipoPrescrizione varchar(32), DataPrescrizione datetime, NumeroPrescrizione varchar(16),
		MedicoPrescrittoreCodiceFiscale varchar(16), QuesitoDiagnostico VARCHAR(2048)
		)

	DECLARE @tblPrescrizioniAttributi AS TABLE
		(IdPrescrizioniBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)

	DECLARE @tblPrescrizioniAllegati AS TABLE(
		ID uniqueidentifier, DataPartizione smalldatetime, IdPrescrizioniBase uniqueidentifier, IdEsterno varchar(64), DataInserimento datetime, DataModifica datetime,
		TipoContenuto varchar(64), ContenutoCompresso varbinary(max)
		)

	DECLARE @tblPrescrizioniAllegatiAttributi AS TABLE
		(IdPrescrizioniAllegatiBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)
	--
	-- APERTURA del cursore
	-- 
	OPEN TheCursor

	SET @RowNumber = @@CURSOR_ROWS
	SET @LenRowNumber = LEN(CAST(@RowNumber AS VARCHAR(10)))
	SET @Padding = REPLICATE('0', @LenRowNumber)
	
	FETCH NEXT FROM TheCursor INTO @IdPrescrizione, @DataPartizione_Old, @DataPrescrizione
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				-- Incremento contatore
				SET @Counter = @Counter + 1
							
				PRINT RIGHT(@Padding + CAST(@Counter AS VARCHAR(10)), @LenRowNumber) + '/' + CAST(@RowNumber AS VARCHAR(10)) 
						+ ' : Prescrizione: ' + ' Id=' +  CAST(@IdPrescrizione AS VARCHAR(40)) + ' DataPrescrizione: ' + CONVERT(VARCHAR(40), @DataPrescrizione, 120) + ' DataPartizione: ' + CONVERT(VARCHAR(40), @DataPartizione_Old, 120)
				--
				-- Cancellazione delle tabelle temporanee
				--
				DELETE FROM @tblPrescrizioni
				DELETE FROM @tblPrescrizioniAttributi --2017-11-23 : ETTORE Cancellazione di tutte le tabelle temporanee
				DELETE FROM @tblPrescrizioniAllegati
				DELETE FROM @tblPrescrizioniAllegatiAttributi  --2017-11-23 : ETTORE Cancellazione di tutte le tabelle temporanee
				--
				-- Calcolo la data di partizione
				-- Il referto è già presente quindi questa operazione va sempre a buon fine
				-- 
				SET @DataPartizione_New = CAST(@DataPrescrizione AS SMALLDATETIME)
				-----------------------------------------------------------------------------------------------------------------------------------
				-- Caricamento delle tabelle temporanee con i dati del referto corrente e impostazione della data partizione corretta 
				-----------------------------------------------------------------------------------------------------------------------------------
				--
				-- @tblPrescrizioni
				--
				INSERT INTO @tblPrescrizioni(
					Id, DataPartizione
					, IdEsterno, IdPaziente, DataInserimento, DataModifica
					, DataModificaEsterno, StatoCodice, TipoPrescrizione, DataPrescrizione, NumeroPrescrizione
					, MedicoPrescrittoreCodiceFiscale, QuesitoDiagnostico)
				SELECT            
					Id, @DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
					, IdEsterno, IdPaziente, DataInserimento, DataModifica
					, DataModificaEsterno, StatoCodice, TipoPrescrizione, DataPrescrizione, NumeroPrescrizione
					, MedicoPrescrittoreCodiceFiscale, QuesitoDiagnostico
				FROM store.PrescrizioniBase WHERE Id = @IdPrescrizione
				--
				-- @tblPrescrizioniAttributi
				--
				INSERT INTO @tblPrescrizioniAttributi(IdPrescrizioniBase,Nome,Valore,DataPartizione)
				SELECT IdPrescrizioniBase,Nome,Valore
						,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.PrescrizioniAttributi WHERE IdPrescrizioniBase = @IdPrescrizione
				--
				-- @tblPrescrizioniAllegati
				--
				INSERT INTO @tblPrescrizioniAllegati
					(ID, DataPartizione
					, IdPrescrizioniBase, IdEsterno, DataInserimento, DataModifica
					, TipoContenuto, ContenutoCompresso)
				SELECT            
					ID, @DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
					, IdPrescrizioniBase, IdEsterno, DataInserimento, DataModifica
					, TipoContenuto, ContenutoCompresso				
				FROM store.PrescrizioniAllegatiBase
				WHERE IdPrescrizioniBase = @IdPrescrizione
				--
				-- @tblPrescrizioniAllegatiAttributi
				--
				INSERT INTO @tblPrescrizioniAllegatiAttributi(IdPrescrizioniAllegatiBase,Nome,Valore,DataPartizione)
				SELECT IdPrescrizioniAllegatiBase,Nome,Valore
						,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.PrescrizioniAllegatiAttributi
					INNER JOIN store.PrescrizioniAllegatiBase
						ON PrescrizioniAllegatiAttributi.IdPrescrizioniAllegatiBase = PrescrizioniAllegatiBase.ID
				 WHERE PrescrizioniAllegatiBase.IdPrescrizioniBase = @IdPrescrizione

				-----------------------------------------------------------------------------------------------------------------------------------
				-- Fine caricamento delle tabelle temporanee
				-----------------------------------------------------------------------------------------------------------------------------------
				--
				-- Aggiornamento del database
				--
				IF @Simulazione = 0
				BEGIN
					PRINT 'Aggiornamento del database'
						
					DELETE store.PrescrizioniAllegatiAttributi
						FROM store.PrescrizioniAllegatiAttributi
						INNER JOIN store.PrescrizioniAllegatiBase
							ON PrescrizioniAllegatiAttributi.IdPrescrizioniAllegatiBase = PrescrizioniAllegatiBase.ID
					WHERE PrescrizioniAllegatiBase.IdPrescrizioniBase = @IdPrescrizione

					DELETE FROM store.PrescrizioniAllegatiBase WHERE IdPrescrizioniBase = @IdPrescrizione					
					DELETE FROM store.PrescrizioniAttributi WHERE IdPrescrizioniBase = @IdPrescrizione					
					DELETE FROM store.PrescrizioniBase WHERE Id = @IdPrescrizione
					--
					-- Inserimento dei dati della prescrizione con data di partizione corretta (SQL trova da solo in quale store inserire i dati)
					--
					--
					-- Tabella Prescrizioni
					--
					INSERT INTO store.PrescrizioniBase(
						Id, DataPartizione
						, IdEsterno, IdPaziente, DataInserimento, DataModifica
						, DataModificaEsterno, StatoCodice, TipoPrescrizione, DataPrescrizione, NumeroPrescrizione
						, MedicoPrescrittoreCodiceFiscale, QuesitoDiagnostico)
					SELECT            
						Id, DataPartizione
						, IdEsterno, IdPaziente, DataInserimento, DataModifica
						, DataModificaEsterno, StatoCodice, TipoPrescrizione, DataPrescrizione, NumeroPrescrizione
						, MedicoPrescrittoreCodiceFiscale, QuesitoDiagnostico
					FROM @tblPrescrizioni 
					
					INSERT INTO store.PrescrizioniAttributi(IdPrescrizioniBase,Nome,Valore,DataPartizione)
					SELECT IdPrescrizioniBase,Nome,Valore, DataPartizione
					FROM @tblPrescrizioniAttributi
					--
					-- Tabella PrescrizioniAllegati
					--
					INSERT INTO store.PrescrizioniAllegatiBase
						(ID, DataPartizione
						, IdPrescrizioniBase, IdEsterno, DataInserimento, DataModifica
						, TipoContenuto, ContenutoCompresso)
					SELECT            
						ID, DataPartizione
						, IdPrescrizioniBase, IdEsterno, DataInserimento, DataModifica
						, TipoContenuto, ContenutoCompresso
					FROM @tblPrescrizioniAllegati

					INSERT INTO store.PrescrizioniAllegatiAttributi(IdPrescrizioniAllegatiBase,Nome,Valore,DataPartizione)
					SELECT IdPrescrizioniAllegatiBase,Nome,Valore, DataPartizione
					FROM @tblPrescrizioniAllegatiAttributi
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
		FETCH NEXT FROM TheCursor INTO @IdPrescrizione, @DataPartizione_Old, @DataPrescrizione
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
	PRINT 'Numero prescrizioni totali elaborate=' + CAST(@Counter AS VARCHAR(10)) + ' Success=' + CAST(@CounterSuccess AS VARCHAR(10)) + ' Error=' + CAST(@CounterError AS VARCHAR(10)) 
	PRINT 'Fine'
END