CREATE PROCEDURE [dbo].[MntPazientiIncoerenzaIstat]
(
	@DelayCancellazioneInGiorni INT = 7
)
AS
BEGIN
	DECLARE @DataInserimentoLogSoglia DATETIME	
	DECLARE @T0 AS DATETIME
	--
	-- Ricavo la @DataInserimentoLogSoglia oltre la quale non cancellare
	--
	IF @DelayCancellazioneInGiorni IS NULL 
		SET @DelayCancellazioneInGiorni = 7
	SET @DataInserimentoLogSoglia = DATEADD(day, -@DelayCancellazioneInGiorni, GETDATE())
	--
	-- 
	--
	PRINT 'Cancellazione incoerenze istat già risolte con data di inserimento minore del '
			+ CONVERT(VARCHAR(40) , @DataInserimentoLogSoglia , 120)
	--
	-- Imposto time start
	--
	SET @T0 = GETDATE()
	--
	-- Cancellazione
	--
	DELETE FROM PazientiIncoerenzaIstat  
	WHERE Id IN (
		SELECT TOP 1000
			PII.Id
		FROM 
			PazientiIncoerenzaIstat AS PII WITH(NOLOCK)
			INNER JOIN Pazienti AS P WITH(NOLOCK)
			ON PII.Provenienza = P.Provenienza
				AND PII.IdProvenienza = P.IdProvenienza
				AND PII.DataInserimento < P.DataModifica
		WHERE 
			--Cancello i record di log di incoerenza ISTAT la cui data di inserimento è minore di N giorni fa
			PII.DataInserimento < @DataInserimentoLogSoglia
		ORDER BY 
			PII.DataInserimento ASC --cancello prima le più vecchie
	) 
	--
	-- Scrivo la durata dell'esecuzione
	--
	PRINT 'Durata totale esecuzione MntPazientiIncoerenzaIstat: ' + CAST(DATEDIFF(ms, @T0, GETDATE()) AS VARCHAR(50)) + ' millisec' 
END
