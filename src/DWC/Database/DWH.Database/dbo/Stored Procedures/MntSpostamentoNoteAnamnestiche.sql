




-- =============================================
-- Author:		ETTORE
-- Create date: 2017-11-22
-- Description:	Sposta le note anamnestiche e gli oggetti figli (attributi) nello store opportuno
-- =============================================
CREATE PROCEDURE [dbo].[MntSpostamentoNoteAnamnestiche]
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
		Id AS IdNotaAnamnestica
		, DataPartizione AS DataPartizione_Old
		, DataNota
	FROM	
		dbo.PartizionamentoOttieniNoteAnamnesticheFuoriStore (@MaxNum)
	WHERE
		DataNota between '1900-01-01' and  '2079-06-06'
	--
	-- Dichiarazione delle variabili del cursore
	--
	DECLARE @IdNotaAnamnestica UNIQUEIDENTIFIER
	DECLARE @DataPartizione_Old SMALLDATETIME
	DECLARE @DataNota DATETIME
	DECLARE @DataPartizione_New AS SMALLDATETIME
	
	DECLARE @tblNoteAnamnesticheBase AS TABLE (
						Id uniqueidentifier,
						DataPartizione smalldatetime,
						IdEsterno varchar(64),
						IdPaziente uniqueidentifier,
						DataInserimento datetime,
						DataModifica datetime,
						DataModificaEsterno datetime,
						StatoCodice tinyint,
						AziendaErogante varchar(16),
						SistemaErogante varchar(16),
						DataNota datetime,
						DataFineValidita datetime,
						TipoCodice varchar(16),
						TipoDescrizione varchar(256),
						Contenuto varbinary(max),
						TipoContenuto varchar(64),
						ContenutoHtml varchar(max),
						ContenutoText varchar(max)
		)

	DECLARE @tblNoteAnamnesticheAttributi AS TABLE
		(IdNoteAnamnesticheBase uniqueidentifier, Nome varchar(64), Valore sql_variant, DataPartizione smalldatetime)

	--
	-- APERTURA del cursore
	-- 
	OPEN TheCursor

	SET @RowNumber = @@CURSOR_ROWS
	SET @LenRowNumber = LEN(CAST(@RowNumber AS VARCHAR(10)))
	SET @Padding = REPLICATE('0', @LenRowNumber)
	
	FETCH NEXT FROM TheCursor INTO @IdNotaAnamnestica, @DataPartizione_Old, @DataNota
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			BEGIN TRANSACTION
			BEGIN TRY
				-- Incremento contatore
				SET @Counter = @Counter + 1
							
				PRINT RIGHT(@Padding + CAST(@Counter AS VARCHAR(10)), @LenRowNumber) + '/' + CAST(@RowNumber AS VARCHAR(10)) 
						+ ' : Nota anamnestica: ' + ' Id=' +  CAST(@IdNotaAnamnestica AS VARCHAR(40)) + ' DataNota: ' + CONVERT(VARCHAR(40), @DataNota, 120) + ' DataPartizione: ' + CONVERT(VARCHAR(40), @DataPartizione_Old, 120)
				--
				-- Cancellazione delle tabelle temporanee
				--
				DELETE FROM @tblNoteAnamnesticheBase
				DELETE FROM @tblNoteAnamnesticheAttributi
				--
				-- Calcolo la data di partizione
				-- La nota anamnestica è già presente quindi questa operazione va sempre a buon fine
				-- 
				SET @DataPartizione_New = CAST(@DataNota AS SMALLDATETIME)
				-----------------------------------------------------------------------------------------------------------------------------------
				-- Caricamento delle tabelle temporanee con i dati della nota anamnestica corrente e impostazione della data partizione corretta 
				-----------------------------------------------------------------------------------------------------------------------------------
				--
				-- @tblNoteAnamnesticheBase
				--
				INSERT INTO @tblNoteAnamnesticheBase(
					Id, DataPartizione, IdEsterno, IdPaziente, DataInserimento, DataModifica
					, DataModificaEsterno, StatoCodice, AziendaErogante, SistemaErogante, DataNota
					, DataFineValidita, TipoCodice, TipoDescrizione
					, Contenuto, TipoContenuto, ContenutoHtml, ContenutoText )
				SELECT            
					Id, @DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
					, IdEsterno, IdPaziente, DataInserimento, DataModifica
					, DataModificaEsterno, StatoCodice, AziendaErogante, SistemaErogante, DataNota
					, DataFineValidita, TipoCodice, TipoDescrizione
					, Contenuto, TipoContenuto, ContenutoHtml, ContenutoText
				FROM store.NoteAnamnesticheBase WHERE Id = @IdNotaAnamnestica
				--
				-- @tblNoteAnamnesticheAttributi
				--
				INSERT INTO @tblNoteAnamnesticheAttributi(IdNoteAnamnesticheBase,Nome,Valore,DataPartizione)
				SELECT IdNoteAnamnesticheBase,Nome,Valore
						,@DataPartizione_New AS DataPartizione --Uso la nuova data di partizione
				FROM store.NoteAnamnesticheAttributi WHERE IdNoteAnamnesticheBase = @IdNotaAnamnestica

				-----------------------------------------------------------------------------------------------------------------------------------
				-- Fine caricamento delle tabelle temporanee
				-----------------------------------------------------------------------------------------------------------------------------------
				--
				-- Aggiornamento del database
				--
				IF @Simulazione = 0
				BEGIN
					PRINT 'Aggiornamento del database'

					DELETE FROM store.NoteAnamnesticheAttributi WHERE IdNoteAnamnesticheBase = @IdNotaAnamnestica
					DELETE FROM store.NoteAnamnesticheBase WHERE Id = @IdNotaAnamnestica
					--
					-- Inserimento dei dati della Nota Anamnestica con data di partizione corretta (SQL trova da solo in quale store inserire i dati)
					--
					--
					-- Tabella NoteAnamnesticheBase
					--
					INSERT INTO store.NoteAnamnesticheBase(
						Id, DataPartizione, IdEsterno, IdPaziente, DataInserimento, DataModifica
						, DataModificaEsterno, StatoCodice, AziendaErogante, SistemaErogante, DataNota
						, DataFineValidita, TipoCodice, TipoDescrizione
						, Contenuto, TipoContenuto, ContenutoHtml, ContenutoText )
					SELECT            
						Id, DataPartizione, IdEsterno, IdPaziente, DataInserimento, DataModifica
						, DataModificaEsterno, StatoCodice, AziendaErogante, SistemaErogante, DataNota
						, DataFineValidita, TipoCodice, TipoDescrizione
						, Contenuto, TipoContenuto, ContenutoHtml, ContenutoText 
					FROM @tblNoteAnamnesticheBase
					
					INSERT INTO store.NoteAnamnesticheAttributi(IdNoteAnamnesticheBase,Nome,Valore,DataPartizione)
					SELECT IdNoteAnamnesticheBase,Nome,Valore, DataPartizione
					FROM @tblNoteAnamnesticheAttributi
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
		FETCH NEXT FROM TheCursor INTO @IdNotaAnamnestica, @DataPartizione_Old, @DataNota
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
	PRINT 'Numero note anamnestiche totali elaborate=' + CAST(@Counter AS VARCHAR(10)) + ' Success=' + CAST(@CounterSuccess AS VARCHAR(10)) + ' Error=' + CAST(@CounterError AS VARCHAR(10)) 
	PRINT 'Fine'
END