-- =============================================
-- Author:		ETTORE GARULLI
-- Create date: 2018-01-31
-- Description:	Offusca i dati anagrafici presenti nel SAC (tabella Pazienti)
-- Modify date: 2018-11-05 - ETTORE: Esclusione dei pazienti certificati
-- Modify date: 2020-04-29 - ETTORE: Sinonimo tabella PazientiCertificati con schema "_anon"
-- =============================================
CREATE PROCEDURE [_anon].[MntDatiAnagraficiOffusca]
(
	@MaxRow INTEGER = 100
	, @Simulazione BIT = 1
	, @DataModificaDal DATETIME
	, @DataModificaAl DATETIME = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	PRINT '*************************************************'
	PRINT 'OFFUSCAMENTO DEI DATI ANAGRAFICI SAC'
	PRINT 'Simulazione = ' + CAST(@Simulazione AS VARCHAR(10))
	PRINT '*************************************************'

	IF @DataModificaDal IS NULL
	BEGIN 
		RAISERROR ('@DataModificaDal è obbligatorio', 16, 1) 
		RETURN
	END 

	IF @DataModificaAl IS NULL
		SET @DataModificaAl = GETDATE()

	--
	-- Cursore
	--
	DECLARE TheCursor CURSOR STATIC READ_ONLY	FOR
	SELECT TOP (@MaxRow) 
		P.Id
		, P.Cognome
		, P.Nome 
	FROM dbo.Pazienti AS P
	WHERE 
		NOT (LEFT(P.Cognome,1) = '$' OR LEFT(P.Nome,1) = '$') --condizione per Offuscare
		AND P.DataModifica between @DataModificaDal AND @DataModificaAl 
		--Escludo i pazienti certificati
		AND P.Id NOT IN (SELECT * FROM _anon.PazientiCertificati AS PC WHERE PC.Id = P.Id)
		--AND Id IN (
		--	'2603AB81-4DCA-4167-BFBA-00112156FF88',
		--	'359A0695-67DD-464F-9EA8-0011B0ACB0F9',
		--	'6D268E1B-DF15-4199-BC0B-206D97319DF4'
		--)
	ORDER BY P.DataModifica DESC 

	------------------------------------	
	-- Variabili del cursore
	------------------------------------	
	DECLARE @Id uniqueidentifier
	DECLARE @Cognome varchar(64)
	DECLARE @Nome varchar(64)
	------------------------------------	
	DECLARE @Corrente  INTEGER = 0
	DECLARE @Trovati INTEGER = 0
	DECLARE @Processati INTEGER = 0
	DECLARE @Errati INTEGER = 0
	DECLARE @CognomeNuovo varchar(64)
	DECLARE @NomeNuovo varchar(64)
	--
	-- Apertura cursore
	--
	OPEN TheCursor
	--
	--
	--
	SET @Trovati = @@CURSOR_ROWS 
	PRINT 'Trovati ' + ISNULL(CONVERT(VARCHAR(10), @Trovati), '0') + ' record da processare.'
	--
	-- Testata report
	--
	PRINT 'Record' + CHAR(9) + 'Id' + CHAR(9) + 'Stato' + CHAR(9) + 'Cognome' + CHAR(9) + 'Nome'

	FETCH NEXT FROM TheCursor INTO @Id, @Cognome, @Nome 
	WHILE (@@fetch_status <> -1)
	BEGIN
		IF (@@fetch_status <> -2)
		BEGIN
			BEGIN TRY
				SET @Corrente = @Corrente + 1
				PRINT CAST(@Corrente AS VARCHAR(10)) + '/' + CAST(@Trovati AS VARCHAR(10)) + CHAR(9) + CONVERT(VARCHAR(40), @Id) + CHAR(9) + 'Originale' + CHAR(9) + ISNULL( @Cognome, 'NULL')  + CHAR(9) + ISNULL( @Nome, 'NULL')
				--
				-- Critto
				--
				EXEC _anon.MntDatiAnagraficiOffuscaDeOffuscaById 'Offusca', @Simulazione, @Id, @Cognome, @Nome,  @CognomeNuovo OUTPUT, @NomeNuovo OUTPUT

				PRINT CAST(@Corrente AS VARCHAR(10)) + '/' + CAST(@Trovati AS VARCHAR(10)) + CHAR(9) + CONVERT(VARCHAR(40), @Id) + CHAR(9) + 'Processato' + CHAR(9) + ISNULL( @CognomeNuovo, 'NULL')  + CHAR(9) + ISNULL( @NomeNuovo, 'NULL')

				SET @Processati = @Processati + 1 
			END TRY
			BEGIN CATCH
				SET @Errati = @Errati + 1
				PRINT ''
				PRINT CHAR(9) + '---> Inizio Errore'
				DECLARE @xact_state INT
				DECLARE @msg NVARCHAR(2000)
				SELECT @xact_state = xact_state(), @msg = error_message()

				DECLARE @report NVARCHAR(4000);
				SELECT @report = CHAR(9) + N'MntDatiAnagraficiOffusca. In catch: ' + @msg + N' xact_state:' + cast(@xact_state AS NVARCHAR(5));
				PRINT @report;	
				PRINT CHAR(9) + '---> Fine Errore'
			END CATCH
			PRINT ''
		END
		FETCH NEXT FROM TheCursor INTO @Id, @Cognome, @Nome 
	END

	CLOSE TheCursor
	DEALLOCATE TheCursor

	PRINT ''
	PRINT 'Processati: ' + CONVERT(VARCHAR(10), @Processati ) + '/' + CAST(@Trovati AS VARCHAR(10))
	PRINT 'Errati: ' + CONVERT(VARCHAR(10), @Errati ) + '/' + CAST(@Trovati AS VARCHAR(10))

END