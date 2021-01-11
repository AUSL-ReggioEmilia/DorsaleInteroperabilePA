

-- =============================================
-- Author:		ETTORE
-- Create date: 2019-03-25
-- Description: Restituisce i dati per la pagina sinottico (nel caso di dropdown = Ultime 24 ore)
--				Legge tabella contenente SOLO dati delle ultime 24 ore (nessun filtro per data)
-- =============================================
CREATE PROCEDURE [dbo].[UiSinotticoUltime24Ore]
AS
BEGIN
SET NOCOUNT ON

	DECLARE @Codice as varchar(100), 
			@Stato as varchar(256), 
			@NumeroRichieste as int, 
			@Sql varchar(max)

	CREATE TABLE #TempTable([Tipo] VARCHAR(100))

	--Creazione struttura
	DECLARE cursore CURSOR FAST_FORWARD READ_ONLY
	FOR SELECT DISTINCT Stato
		FROM SinotticoUltime24Ore S (NOLOCK)
		ORDER BY Stato
	  			
	OPEN cursore
	FETCH cursore INTO @Stato
	WHILE @@Fetch_Status = 0 
	BEGIN 		
		SET @Sql = 'ALTER TABLE #TempTable ADD [' + @Stato + '] INT NULL'
		EXEC(@Sql)
	     
		FETCH cursore INTO  @Stato   --next
	END	 
	CLOSE cursore
	DEALLOCATE cursore
			   

	--Inserimento dati
	DECLARE @CodiceSistema varchar(max), @IdErogante as uniqueidentifier

	DECLARE cursoreDati CURSOR FAST_FORWARD READ_ONLY
	FOR SELECT Sinottico.IdSistemaErogante,		   	      
			   (Sistemi.CodiceAzienda + '-' + Sistemi.Codice) as Sistema,
			   Sum(Sinottico.NumeroOrdini) as NumeroOrdini,
			   Sinottico.Stato
		
		FROM SinotticoUltime24Ore AS Sinottico (nolock) 
		LEFT JOIN Sistemi (nolock) on Sistemi.ID = Sinottico.IdSistemaErogante						   
		GROUP BY Sinottico.IdSistemaErogante, (Sistemi.CodiceAzienda + '-' + Sistemi.Codice), Sinottico.Stato
		ORDER BY (Sistemi.CodiceAzienda + '-' + Sistemi.Codice) DESC
	  			
	OPEN cursoreDati
	FETCH cursoreDati INTO @IdErogante, @CodiceSistema, @NumeroRichieste, @Stato 
	WHILE @@Fetch_Status = 0 
	BEGIN 

		IF (select count([Tipo]) from #TempTable where [Tipo] = @CodiceSistema) = 0
			SET @Sql = 'INSERT INTO #TempTable([Tipo], ['+ @Stato + ']) values('''+ @CodiceSistema + ''', '+ CAST(@NumeroRichieste as varchar(10)) + ')'

		ELSE
			SET @Sql = 'UPDATE #TempTable SET [' + @Stato + '] = ' + CAST(@NumeroRichieste as varchar(10)) + ' where [Tipo] = ''' + @CodiceSistema +''''
		PRINT @Sql
		EXEC(@Sql)
	    
		FETCH cursoreDati INTO @IdErogante, @CodiceSistema, @NumeroRichieste, @Stato --next
	END
	 
	CLOSE cursoreDati
	DEALLOCATE cursoreDati

	SELECT * FROM #TempTable AS Sinottico

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSinotticoUltime24Ore] TO [DataAccessUi]
    AS [dbo];

