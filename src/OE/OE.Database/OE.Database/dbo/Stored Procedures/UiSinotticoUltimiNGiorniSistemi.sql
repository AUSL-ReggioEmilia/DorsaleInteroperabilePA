

-- =============================================
-- Author:      ETTORE
-- Create date: 2019-03-25
-- Description: Restituisce i dati con dettaglio per sistema Richiedente per la pagina sinottico (nel caso di dropdown = 'Ultima settimana' e 'Ultimo mese')
-- =============================================
CREATE PROCEDURE [dbo].[UiSinotticoUltimiNGiorniSistemi]
	@Tipo as varchar(50),
	@dataDa date,
	@dataA date
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
		FROM SinotticoUltimoMese S (nolock)
		WHERE (S.Giorno >= @dataDa AND S.Giorno <= @dataA)	
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
	DECLARE @CodiceSistema varchar(max)

	DECLARE cursoreDati CURSOR FAST_FORWARD READ_ONLY
	FOR SELECT (SR.CodiceAzienda + '-'+ SR.Codice) as Codice,
			   Sum(S.NumeroOrdini) as NumeroOrdini,
			   S.Stato		
		FROM SinotticoUltimoMese AS S (nolock) 
		LEFT JOIN Sistemi (nolock) SR on SR.ID = S.IdSistemaRichiedente
		LEFT JOIN Sistemi (nolock) SE on SE.ID = S.IdSistemaErogante
		WHERE (SE.CodiceAzienda + '-' + SE.Codice) = @Tipo
		  AND (S.Giorno >= @dataDa AND S.Giorno <= @dataA)
		GROUP BY (SR.CodiceAzienda + '-' + SR.Codice), S.Stato
		ORDER BY (SR.CodiceAzienda + '-' + SR.Codice) DESC
	  			
	OPEN cursoreDati
	FETCH cursoreDati INTO @CodiceSistema, @NumeroRichieste, @Stato 
	WHILE @@Fetch_Status = 0 
	BEGIN 

		IF (select count([Tipo]) from #TempTable where [Tipo] = @CodiceSistema) = 0
			SET @Sql = 'INSERT INTO #TempTable([Tipo], ['+ @Stato + ']) values('''+ @CodiceSistema + ''', '+ CAST(@NumeroRichieste as varchar(10)) + ')'
		ELSE
			SET @Sql = 'UPDATE #TempTable SET [' + @Stato + '] = ' + CAST(@NumeroRichieste as varchar(10)) + ' where [Tipo] = ''' + @CodiceSistema +''''
		PRINT @Sql
		EXEC(@Sql)	    
		FETCH cursoreDati INTO @CodiceSistema, @NumeroRichieste, @Stato --next
	END
	 
	CLOSE cursoreDati
	DEALLOCATE cursoreDati

	SELECT * FROM #TempTable AS Sinottico

	SET NOCOUNT OFF
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSinotticoUltimiNGiorniSistemi] TO [DataAccessUi]
    AS [dbo];

