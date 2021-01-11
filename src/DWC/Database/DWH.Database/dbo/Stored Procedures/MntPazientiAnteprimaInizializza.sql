

CREATE PROCEDURE [dbo].[MntPazientiAnteprimaInizializza]
(
	@MaxNumAnagraficheDaInserire INTEGER = 1000
	, @NumAnagrafichePerBatch INTEGER = 100
)
AS
BEGIN
/*
	MODIFICA ETTORE 2016-12-05: per evitare sporadici errori di chiave duplicata ho aggiunto "try catch" ed eseguo dei batch di @NumAnagrafichePerBatch
*/

	SET NOCOUNT ON;
	DECLARE @RowCount INTEGER
	DECLARE @DateStart DATETIME
	DECLARE @TotalRowCount INTEGER=0
	DECLARE @CounterCicli INTEGER
	DECLARE @NumeroCicli INTEGER

	--
	-- Inizializzo 
	--
	IF @MaxNumAnagraficheDaInserire IS NULL
		SET @MaxNumAnagraficheDaInserire = 1000
	IF @NumAnagrafichePerBatch IS NULL
		SET @NumAnagrafichePerBatch = 100

	SET @RowCount = 0
	--
	-- Calcolo il numero di cilcli
	--
	SET @NumeroCicli = @MaxNumAnagraficheDaInserire / @NumAnagrafichePerBatch 

	--
	-- Inserimento delle anagrafiche ATTIVE mancanti
	--
	SET @DateStart = GETDATE()
	PRINT 'Inserimento iniziale anagrafiche mancanti: ' + CONVERT(VARCHAR(20) , @DateStart , 120)	

	SET @CounterCicli = 0
	WHILE @CounterCicli < @NumeroCicli
	BEGIN
		BEGIN TRY
			SET @CounterCicli = @CounterCicli + 1
			--PRINT '@CounterCicli = ' + CAST(@CounterCicli AS VARCHAR(10))

			INSERT INTO PazientiAnteprima (IdPaziente, CalcolaAnteprimaReferti, DataModificaAnteprimaReferti, AnteprimaReferti , CalcolaAnteprimaRicoveri, DataModificaAnteprimaRicoveri , AnteprimaRicoveri)
			SELECT TOP(@NumAnagrafichePerBatch)
				P.Id AS IdPaziente
				, CAST(NULL AS DATETIME) AS CalcolaAnteprimaReferti
				, DataModificaAnteprimaReferti = GETDATE()
				, AnteprimaReferti = dbo.GetPazientiAnteprimaReferti(P.Id)
				, CAST(NULL AS DATETIME) AS CalcolaAnteprimaRicoveri
				, DataModificaAnteprimaRicoveri = GETDATE()
				, AnteprimaRicoveri = dbo.GetPazientiAnteprimaRicoveri(P.Id)
			FROM 
				dbo.SAC_Pazienti AS P 
				LEFT OUTER JOIN PazientiAnteprima AS PA 
					ON PA.IdPaziente = P.Id
			WHERE 
				PA.IdPaziente IS NULL AND P.Disattivato = 0
			ORDER BY P.DataModifica DESC
		
			SET @RowCount = @@ROWCOUNT
			SET @TotalRowCount = @TotalRowCount + @RowCount 
			--
			-- Se il numero di righe inserite è inferiore @NumAnagrafichePerBatch interrompo il WHILE
			--
			IF @RowCount < @NumAnagrafichePerBatch
				BREAK

		END TRY
		BEGIN CATCH
			--VADO AVANTI
		END CATCH
	END	
	
	PRINT 'Inserite ' +  CAST( @TotalRowCount AS VARCHAR(10)) + ' anagrafiche.' 
	PRINT 'Fine Inserimento iniziale anagrafiche mancanti: durata ' + CAST(DATEDIFF(ms, @DateStart ,GETDATE()) AS VARCHAR(10)) + ' ms'

END


