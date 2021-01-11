
-- =============================================
-- Author:		Ettore
-- Create date: 2013-05-21
-- Description:	Sposta i log degli accessi nella tabella di storico
-- Modify date: 2015-10-29 Stefano P: aggiunto campo note
-- Modify Date: 2018-04-20 Simone B: Aggiunti cammpi NumeroRecord,ConsensoPaziente e IdNotaAnamnestica
-- =============================================
CREATE PROCEDURE [dbo].[MntTracciaAccessiStoricizza]
(
	@DataDal DATETIME = NULL
	, @DataAl DATETIME = NULL
	, @NumMaxRecord INT = 100
)
AS 
BEGIN
/*
	MODIFICA ETTORE 2014-10-24: gestione nuovi campi della tabella TracciaAccessi (IdRicoveri, IdEventi, IdEsterno, RuoloUtenteCodice, RuoloUtenteDescrizione)
*/
	SET NOCOUNT ON;
	-- Tabella temporanea in cui memorizzo gli Id della tabella TracciaAccessi da cancellare
	DECLARE @TempTab AS TABLE (Id UNIQUEIDENTIFIER)
	DECLARE @TempTabNumRow INTEGER
	DECLARE @CounterStoricizzati INT
	SET @CounterStoricizzati = 0
	SET @TempTabNumRow = 0
	
	IF @NumMaxRecord < 100 
		SET @NumMaxRecord = 100
	
	IF @DataDal IS NULL 
		SET @DataDal = '1900-01-01'
	IF @DataAl IS NULL 
		SET @DataAl = DATEADD(year,  - 3, GETDATE())
		
	PRINT 'Max num record max da cancellare per batch=' + CAST(@NumMaxRecord AS VARCHAR(10))
	PRINT 'Storicizzazione dei record compresi fra [@DataDal, @DataAl]=' + 
			'[' +  CONVERT(VARCHAR(20),@DataDal, 120) + ',' +  CONVERT(VARCHAR(20),@DataAl, 120) + ']' 
	
	-- Loop infinito
	WHILE 1 = 1
	BEGIN
		-- Inizio transazione
		BEGIN TRANSACTION
		BEGIN TRY
			-- Inizializzo la tabella temporanea
			DELETE FROM @TempTab 
			-- Memorizzo gli Id da storicizzare in una tabella temporanea
			INSERT INTO @TempTab(Id)
			SELECT TOP (@NumMaxRecord) Id  FROM TracciaAccessi 
			WHERE Data between @DataDal AND @DataAl
			ORDER BY Data
			-- Memorizzo numero record trovati
			SELECT @TempTabNumRow = COUNT(*) FROM @TempTab
			-- Verifico se si deve proseguire con la cancellazione
			IF @TempTabNumRow = 0 
			BEGIN
				COMMIT --FONDAMENTALE
				BREAK
			END 
			-- Li scrivo nella tabella TracciaAccessi_Storico
			INSERT INTO TracciaAccessi_Storico(Id, Data, UtenteRichiedente, NomeRichiedente, IdUtenteRichiedente
				   , IdPazienti, Operazione, NomeHostRichiedente, IndirizzoIPHostRichiedente, IdReferti
				   , IdRicoveri, IdEventi, IdEsterno, RuoloUtenteCodice, RuoloUtenteDescrizione, MotivoAccesso, Note,NumeroRecord,ConsensoPaziente,IdNotaAnamnestica)
			SELECT TA.Id, TA.Data, TA.UtenteRichiedente, TA.NomeRichiedente, TA.IdUtenteRichiedente
				   , TA.IdPazienti, TA.Operazione, TA.NomeHostRichiedente, TA.IndirizzoIPHostRichiedente, TA.IdReferti
				   , TA.IdRicoveri, TA.IdEventi, TA.IdEsterno, TA.RuoloUtenteCodice, TA.RuoloUtenteDescrizione, TA.MotivoAccesso, TA.Note,TA.NumeroRecord,TA.ConsensoPaziente,TA.IdNotaAnamnestica
			FROM TracciaAccessi AS TA
				INNER JOIN @TempTab AS TEMP_TAB
					ON TA.Id = TEMP_TAB.Id
			-- Li cancello dalla tabella TracciaAccessi
			DELETE FROM TA
			FROM TracciaAccessi AS TA
				INNER JOIN @TempTab AS TEMP_TAB
					ON TA.Id = TEMP_TAB.Id
			-- Commit della transazione
			COMMIT
			SET @CounterStoricizzati = @CounterStoricizzati + @TempTabNumRow
		END TRY
		BEGIN CATCH
			-- Prelevo info sull'errore
			DECLARE @xact_state INT;DECLARE @msg NVARCHAR(4000)
			SELECT @xact_state = xact_state(), @msg = error_message()
			-- ROLLBACK
			IF @@TRANCOUNT > 0
				ROLLBACK
			-- Scrivo l'errore
			DECLARE @report NVARCHAR(4000);
			SELECT @report = N'MntTracciaAccessiStoricizza. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
			PRINT @report;
			--Esco dal WHILE
			BREAK;
		END CATCH
	END --END WHILE
	-- Scrivo il numero di record storicizzati
	PRINT 'Numero record storicizzati=' + CAST(@CounterStoricizzati AS VARCHAR(10))
END --END STORED PROCEDURE
