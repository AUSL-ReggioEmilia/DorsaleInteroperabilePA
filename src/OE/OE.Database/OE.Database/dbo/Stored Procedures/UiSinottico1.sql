


-- =============================================
-- Author:      
-- Create date: 
-- Description: Restituisce i dati per la pagina sinottico
-- Modify date: 2015-10-21 Stefano P : ora usa la GetStatoSenzaSottostato2
-- Modify date: 2020-01-17 ETTORE: Correzione: 
--									Poichè ho due query separate per trovare gli stati e per trovare i valori per ogni stato e sistema può accadere 
--									che la seconda query trovi degli stati non restituiti dalla prima.
--									Quindi la tabella #TempTable manca di alcune colonne su cui la seconda query tenta di fare insert/update.
--									Memorizzato nella tabella temporanea @TabStati gli stati possibili e fatto insert/update in #TempTable solo se lo stato è
--									presente in @TabStati.
-- =============================================
CREATE PROCEDURE [dbo].[UiSinottico1]
(
	@dataDa DATETIME2(0),
	@dataA DATETIME2(0)
)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Codice as varchar(100), @Stato as varchar(256), @NumeroRichieste as int, @Sql varchar(max)

	CREATE TABLE #TempTable([Tipo] varchar(100))
	DECLARE @TabStati AS TABLE (Stato varchar(256))
	--
	-- STEP 1: Creazione struttura
	--
	DECLARE cursore CURSOR FAST_FORWARD READ_ONLY
	FOR 
	SELECT 
		DISTINCT 
			dbo.GetStatoSenzaSottostato2(T.ID, T.StatoOrderEntry) as Stato
		FROM 
			OrdiniTestate T (NOLOCK)
		WHERE 
			(T.DataRichiesta >= @dataDa AND T.DataRichiesta <= @dataA)

	OPEN cursore
	FETCH cursore INTO @Stato
	WHILE @@Fetch_Status = 0 
	BEGIN 	
		SET @Sql = 'alter table #TempTable add [' + @Stato + '] int NULL'
		EXEC(@Sql)     
		--MODIFICA ETTORE 2020-01-17: memorizzo gli stati trovati
		IF NOT EXISTS(SELECT * FROM @TabStati WHERE Stato = @Stato)
		BEGIN 
			INSERT INTO @TabStati (Stato) VALUES (@Stato)
		END
		FETCH cursore INTO  @Stato   --next
	END
	 
	CLOSE cursore
	DEALLOCATE cursore
			   
	--
	--STEP 2: Inserimento dati
	--
	DECLARE @CodiceSistema VARCHAR(max), @Sistema AS VARCHAR(max)

	DECLARE cursoreDati CURSOR FAST_FORWARD READ_ONLY
	FOR 
	SELECT 
		Sistemi.Codice,	      
		Count(Sistemi.Codice) as NumeroRichieste,
		dbo.GetStatoSenzaSottostato2(OrdiniTestate.ID, OrdiniTestate.StatoOrderEntry) as Stato
	FROM 
		OrdiniTestate (NOLOCK) 
		LEFT JOIN OrdiniRigheRichieste (NOLOCK) 
			on OrdiniRigheRichieste.IDOrdineTestata = OrdiniTestate.ID
		LEFT JOIN Sistemi (NOLOCK) 
			on Sistemi.ID = OrdiniRigheRichieste.IDSistemaErogante					   
	WHERE 
		(OrdiniTestate.DataRichiesta >= @dataDa AND OrdiniTestate.DataRichiesta <= @dataA)
	GROUP BY 
		Sistemi.Codice
		, dbo.GetStatoSenzaSottostato2(OrdiniTestate.ID, OrdiniTestate.StatoOrderEntry)
	ORDER BY 
		Sistemi.Codice DESC	   
	  			
	OPEN cursoreDati
	FETCH cursoreDati INTO @CodiceSistema, @NumeroRichieste, @Stato 
	WHILE @@Fetch_Status = 0 
	BEGIN 
		--MODIFICA ETTORE: 2020-01-17: inserisco/aggiorno #TempTable solo se lo stato è presente nella tabella @TabStati
		IF EXISTS(SELECT * FROM @TabStati WHERE Stato = @Stato)
		BEGIN 
			IF (SELECT count([Tipo]) FROM #TempTable WHERE [Tipo] = @CodiceSistema) = 0
				SET @Sql = 'INSERT INTO #TempTable([Tipo], ['+ @Stato + ']) values('''+ @CodiceSistema + ''', '+ CAST(@NumeroRichieste AS VARCHAR(10)) + ')'
			ELSE
				SET @Sql = 'UPDATE #TempTable SET [' + @Stato + '] = ' + CAST(@NumeroRichieste AS VARCHAR(10)) + ' where [Tipo] = ''' + @CodiceSistema +''''

			PRINT @Sql
			EXEC(@Sql)
		END
	    
		FETCH cursoreDati INTO @CodiceSistema, @NumeroRichieste, @Stato --next
	END
	 
	CLOSE cursoreDati
	DEALLOCATE cursoreDati

	--
	-- STEP 3: restituzione dati
	--
	SELECT * FROM #TempTable AS Sinottico

	SET NOCOUNT OFF
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiSinottico1] TO [DataAccessUi]
    AS [dbo];

