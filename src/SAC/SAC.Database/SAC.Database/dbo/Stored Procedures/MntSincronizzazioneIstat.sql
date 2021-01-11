CREATE PROCEDURE [dbo].[MntSincronizzazioneIstat]
AS
BEGIN
/*
	 ATTENZIONE: 
		1)	SacConnLha_DizionarioLHAComuni punta a SacConnLha.DizionariLhaComuni che è mantenuta aggiornata da un SISS;
			essendo una replica della tabella LHA contiene dei codici istat alfanumerici doppi -> i codici doppi non li sincronizzo
		
		2)	SacConnLha_DizionariLhaNazioni punta a SacConnLha.DizionariLhaNazioni che è mantenuta aggiornata da un SISS; 
			essendo una replica della tabella LHA contiene dei codici istat alfanumerici doppi -> i codici doppi non li sincronizzo
			
			
	MODIFICA ETTORE 2016-02-08: aggiornamento del codice provincia in base alla sigla della provincia 
	MODIFICA ETTORE 2016-11-08: aggiornamento delle descrizioni della tabella IstatComuni se contengono "{Codice Sconosciuto}"
								Commentato tutti i PRINT relativi alle operazioni e ai tempi

	MODIFICA ETTORE 2017-05-22: Sincronizzazione della nuova tabella dbo.DizionarioIstaAsl

*/	
	SET NOCOUNT ON
	DECLARE @T0 AS DATETIME
------------------------------------------------------------------------
--	INIZIO AGGIORNAMENTO IstatComuni
--	IstatComuni contiene sia comuni che nazioni
------------------------------------------------------------------------
	DECLARE @TempLhaComuniDoppi AS TABLE (IstatComune VARCHAR(6))
	------------------------------------------------------------------------
	-- Memorizzo in tabella temporanea i codici doppi su LHA
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()	
	--PRINT 'IstatComuni - Memorizzazione codici istat comune doppi:'
	INSERT INTO @TempLhaComuniDoppi(IstatComune)
	SELECT IstatComune FROM SacConnLha_DizionariLhaComuni GROUP BY IstatComune HAVING COUNT(*) > 1
	--PRINT 'Numero doppi: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
	
	------------------------------------------------------------------------
	-- IstatComuni: aggiornamento COMUNI
	-- Aggiorno i codici esistenti dei COMUNI in IstatComuni
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()	
	--PRINT ''
	--PRINT 'IstatComuni - Aggiornamento codici comune esistenti:'
	UPDATE SAC_C
		SET 
			-- Nome = LHA_C.DescrizioneComune -- per ora non aggiorno il nome del comune
			DataInizioValidita = LHA_C.DataInizioValidita
			, DataFineValidita = LHA_C.DataFineValidita
			, CodiceDistretto = LHA_C.CodiceDistretto
			, Cap = LHA_C.Cap
			, CodiceCatastale = LHA_C.CodiceCatastale
			, CodiceRegione = LHA_C.CodiceRegione
			, Sigla = LHA_C.CodiceProvincia
			, CodiceAsl = LHA_C.CodiceAsl
			, FlagComuneStatoEstero = LHA_C.FlagComuneStatoEstero
			, FlagStatoEsteroUE = LHA_C.FlagStatoEsteroUE
			, DataUltimaModifica = LHA_C.TimestampUltimaModifica
			, Disattivato = LHA_C.Disattivato
			, CodiceInternoLHA = LHA_C.CodiceInternoComune
	FROM
		SacConnLha_DizionariLhaComuni AS LHA_C
		INNER JOIN IstatComuni AS SAC_C
			ON LHA_C.IstatComune = SAC_C.Codice
	WHERE LHA_C.IstatComune NOT IN (
		--Escludo i doppi
		SELECT IstatComune FROM @TempLhaComuniDoppi
	) 
	AND LHA_C.FlagComuneStatoEstero = 'C' --C=Comune, E=Nazione
	--AND SAC_C.Nazione = 0
	--PRINT 'Numero aggiornamenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 	
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
	
	------------------------------------------------------------------------
	-- IstatComuni: aggiornamento NAZIONI
	-- Aggiorno i codici esistenti delle NAZIONI in IstatComuni
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatComuni - Aggiornamento codici nazioni esistenti:'
	UPDATE SAC_C
		SET 
			-- Nome = LHA_C.DescrizioneComune -- per ora non aggiorno il nome del comune			
			DataInizioValidita = LHA_C.DataInizioValidita
			, DataFineValidita = LHA_C.DataFineValidita
			, CodiceDistretto = LHA_C.CodiceDistretto
			, Cap = LHA_C.Cap
			, CodiceCatastale = LHA_C.CodiceCatastale
			, CodiceRegione = LHA_C.CodiceRegione
			, Sigla = LHA_C.CodiceProvincia
			, CodiceAsl = LHA_C.CodiceAsl
			, FlagComuneStatoEstero = LHA_C.FlagComuneStatoEstero
			, FlagStatoEsteroUE = LHA_C.FlagStatoEsteroUE
			, DataUltimaModifica = LHA_C.TimestampUltimaModifica
			, Disattivato = LHA_C.Disattivato
			, CodiceInternoLHA = LHA_C.CodiceInternoComune
	FROM
		SacConnLha_DizionariLhaComuni AS LHA_C
		INNER JOIN IstatComuni AS SAC_C
			ON LHA_C.IstatComune = SAC_C.Codice
	WHERE LHA_C.IstatComune NOT IN (
		--Escludo i doppi
		SELECT IstatComune FROM @TempLhaComuniDoppi
	) 
	AND LHA_C.FlagComuneStatoEstero = 'E' --C=Comune, E=Nazione
	----AND SAC_C.Nazione = 1
	--PRINT 'Numero aggiornamenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 		
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'

	------------------------------------------------------------------------
	-- IstatComuni: inserimento COMUNI mancanti
	-- Li leggo sempre da DizionariLhaComuni 
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatComuni - Inserimento comuni mancanti'
	INSERT INTO IstatComuni(Codice,Nome,CodiceProvincia,Nazione, DataInizioValidita,DataFineValidita
		, CodiceDistretto, Cap, CodiceCatastale, CodiceRegione, Sigla, CodiceAsl, FlagComuneStatoEstero, FlagStatoEsteroUE
		, DataUltimaModifica, Disattivato, CodiceInternoLHA)
	SELECT 
		LHA_C.IstatComune AS Codice 
		, LHA_C.DescrizioneComune AS Nome
		, ISNULL(SAC_P.Codice , '-1') AS CodiceProvincia
		, CAST(0 AS BIT) AS Nazione
		, LHA_C.DataInizioValidita AS DataInizioValidita 
		, LHA_C.DataFineValidita AS DataFineValidita
		, CodiceDistretto = LHA_C.CodiceDistretto
		, Cap = LHA_C.Cap
		, CodiceCatastale = LHA_C.CodiceCatastale
		, CodiceRegione = LHA_C.CodiceRegione
		, Sigla = LHA_C.CodiceProvincia
		, CodiceAsl = LHA_C.CodiceAsl
		, FlagComuneStatoEstero = LHA_C.FlagComuneStatoEstero
		, FlagStatoEsteroUE = LHA_C.FlagStatoEsteroUE
		, DataUltimaModifica = LHA_C.TimestampUltimaModifica
		, Disattivato = LHA_C.Disattivato
		, CodiceInternoLHA = LHA_C.CodiceInternoComune
		
	FROM 
		SacConnLha_DizionariLhaComuni AS LHA_C
		LEFT OUTER JOIN IstatComuni AS SAC_C
			ON LHA_C.IstatComune = SAC_C.Codice
		--per ora faccio JOIN con la tabella IstatProvince (LHA non ha la tabella delle province) per trovare il codice istat della provincia
		LEFT OUTER JOIN IstatProvince AS SAC_P 
			ON LHA_C.CodiceProvincia = SAC_P.Sigla
	WHERE LHA_C.IstatComune NOT IN (
		--Escludo i doppi
		SELECT IstatComune FROM @TempLhaComuniDoppi
	) 
	AND LHA_C.FlagComuneStatoEstero = 'C'
	AND SAC_C.Codice IS NULL
	----AND LHA_C.IstatComune NOT IN ( '036048', '036049', '036099') --ISCRITTO D'UFFICIO, IRREPERIBILE ALL'ANAGRAFE, NON USARE / DA SOSTITUIRE
	--PRINT 'Numero inserimenti: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 		
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
	------------------------------------------------------------------------
	-- IstatComuni: inserimento NAZIONI mancanti
	-- Li leggo sempre da DizionariLhaComuni (contiene anche le Nazioni)
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatComuni - Inserimento nazioni mancanti:'
	INSERT INTO IstatComuni(Codice,Nome,CodiceProvincia,Nazione, DataInizioValidita,DataFineValidita
			, CodiceDistretto, Cap, CodiceCatastale, CodiceRegione, Sigla, CodiceAsl, FlagComuneStatoEstero, FlagStatoEsteroUE
			, DataUltimaModifica, Disattivato, CodiceInternoLHA)
	SELECT 
		LHA_C.IstatComune AS Codice 
		, LHA_C.DescrizioneComune AS Nome
		, '-10' AS CodiceProvincia --per le nazioni ha questo valore
		, CAST(1 AS BIT) AS Nazione
		, LHA_C.DataInizioValidita AS DataInizioValidita 
		, LHA_C.DataFineValidita AS DataFineValidita
		, CodiceDistretto = LHA_C.CodiceDistretto
		, Cap = LHA_C.Cap
		, CodiceCatastale = LHA_C.CodiceCatastale
		, CodiceRegione = LHA_C.CodiceRegione
		, Sigla = LHA_C.CodiceProvincia
		, CodiceAsl = LHA_C.CodiceAsl
		, FlagComuneStatoEstero = LHA_C.FlagComuneStatoEstero
		, FlagStatoEsteroUE = LHA_C.FlagStatoEsteroUE
		, DataUltimaModifica = LHA_C.TimestampUltimaModifica
		, Disattivato = LHA_C.Disattivato
		, CodiceInternoLHA = LHA_C.CodiceInternoComune
	FROM 
		SacConnLha_DizionariLhaComuni AS LHA_C
		LEFT OUTER JOIN IstatComuni AS SAC_C
			ON LHA_C.IstatComune = SAC_C.Codice
	WHERE LHA_C.IstatComune NOT IN (
		--Escludo i doppi
		SELECT IstatComune FROM @TempLhaComuniDoppi
	) 
	AND LHA_C.FlagComuneStatoEstero = 'E'
	AND SAC_C.Codice IS NULL
	--PRINT 'Numero inserimenti: ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 		
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
	
	--
	-- Gestione dei flag FlagComuneStatoEstero
	--
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatComuni - Aggiornamento FlagComuneStatoEstero:'
	UPDATE IstatComuni 
		SET FlagComuneStatoEstero = 'E'
	WHERE Nazione = 1 and ISNULL(FlagComuneStatoEstero, '') = ''
	--PRINT 'Numero aggiornamenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 		
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
	
	------------------------------------------------------------------------
	-- MODIFICA ETTORE 2016-02-08
	-- IstatComuni: aggiorno il codice provincia dove manca
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatComuni - Aggiornamento codici provincia:'
	UPDATE SAC_C
		SET SAC_C.CodiceProvincia = SAC_P.Codice 
	FROM IstatComuni AS SAC_C
	INNER JOIN IstatProvince AS SAC_P
		on SAC_C.Sigla = SAC_P.Sigla 
	WHERE 
		SAC_C.Nazione = 0 --solo per i record che corrispondono a Comuni
		AND SAC_C.CodiceProvincia = '-1' --solo per i record che non hann il codice provincia impostato
	--PRINT 'Numero aggiornamenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 		
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
		
	
	--MODIFICA ETTORE 2016-11-08: aggiornamento delle descrizioni della tabella IstatComuni se contengono "{Codice Sconosciuto}"
	------------------------------------------------------------------------
	-- IstatComuni: aggiornamento descrizione COMUNI con descrizione che contiene '{Codice Sconosciuto}'
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()	
	--PRINT ''
	--PRINT 'IstatComuni - Aggiornamento codici comune con descrizione sconosciuta:'
	UPDATE SAC_C
		SET 
			Nome = LHA_C.DescrizioneComune 
			, Nazione = 0 --questo è un Comune per LHA
	FROM
		SacConnLha_DizionariLhaComuni AS LHA_C
		INNER JOIN IstatComuni AS SAC_C
			ON LHA_C.IstatComune = SAC_C.Codice
	WHERE LHA_C.IstatComune NOT IN (
		--Escludo i doppi
		SELECT IstatComune FROM @TempLhaComuniDoppi
	) 
	AND LHA_C.FlagComuneStatoEstero = 'C' --C=Comune, E=Nazione
	AND SAC_C.Nome like '%{Codice Sconosciuto}'
	--PRINT 'Numero aggiornamenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 	
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'

	------------------------------------------------------------------------
	-- IstatComuni: aggiornamento descrizione NAZIONI con descrizione che contiene '{Codice Sconosciuto}'
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatComuni - Aggiornamento codici nazioni esistenti con descrizione sconosciuta:'
	UPDATE SAC_C
		SET 
			Nome = LHA_C.DescrizioneComune
			, Nazione = 1 --Questa è una Nazione per LHA
	FROM
		SacConnLha_DizionariLhaComuni AS LHA_C
		INNER JOIN IstatComuni AS SAC_C
			ON LHA_C.IstatComune = SAC_C.Codice
	WHERE LHA_C.IstatComune NOT IN (
		--Escludo i doppi
		SELECT IstatComune FROM @TempLhaComuniDoppi
	) 
	AND LHA_C.FlagComuneStatoEstero = 'E' --C=Comune, E=Nazione
	AND SAC_C.Nome like '%{Codice Sconosciuto}'
	--PRINT 'Numero aggiornamenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 		
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'



------------------------------------------------------------------------
--	FINE AGGIORNAMENTO IstatComuni
------------------------------------------------------------------------


------------------------------------------------------------------------
--	INIZIO AGGIORNAMENTO IstatNazioni
------------------------------------------------------------------------
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatNazioni - Memorizzazione codici nazione doppi:'
	DECLARE @TempLhaNazioniDoppie AS TABLE(IstatNazione VARCHAR(3))
	INSERT INTO @TempLhaNazioniDoppie(IstatNazione)
	SELECT IstatNazione from SacConnLha_DizionariLhaNazioni group By IstatNazione having COUNT(*) > 1
	--PRINT 'Numero doppi : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 		
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
	------------------------------------------------------------------------
	-- IstatNazioni: aggiornamento NAZIONI esistenti
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatNazioni - Aggiornamento codici nazione esistenti:'
	UPDATE SAC_N
		SET 
			-- Nome = LHA_N.DescrizioneNazione -- per ora non aggiorno il nome della nazione
			DataInizioValidita = LHA_N.DataInizioValidita
			, DataFineValidita = LHA_N.DataFineValidita
			, FlagPaeseUE = LHA_N.FlagPaeseUE
			, DataUltimaModifica = LHA_N.TimestampUltimaModifica
			, CodiceInternoLHA = LHA_N.CodiceInternoNazione
	FROM
		SacConnLha_DizionariLhaNazioni AS LHA_N 
		INNER JOIN IstatNazioni AS SAC_N
			ON LHA_N.IstatNazione = SAC_N.Codice
	WHERE LHA_N.IstatNazione NOT IN (
		--Escludo i doppi
		SELECT IstatNazione FROM @TempLhaNazioniDoppie
	)
	--PRINT 'Numero aggiornamenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 		
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
	------------------------------------------------------------------------
	-- IstatNazioni: inserimento NAZIONI mancanti
	------------------------------------------------------------------------
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'IstatNazioni - Inserimento codici nazione mancanti:'
	INSERT INTO IstatNazioni(Codice,Nome,DataInizioValidita,DataFineValidita,FlagPaeseUE,DataUltimaModifica,CodiceInternoLHA)
	SELECT 
		LHA_N.IstatNazione AS Codice
		, LHA_N.DescrizioneNazione AS Nome
		, LHA_N.DataInizioValidita AS DataInizioValidita
		, LHA_N.DataFineValidita AS DataFineValidita
		, LHA_N.FlagPaeseUE AS FlagPaeseUE
		, LHA_N.TimestampUltimaModifica AS DataUltimaModifica
		, LHA_N.CodiceInternoNazione AS CodiceInternoLHA
	FROM 
		SacConnLha_DizionariLhaNazioni AS LHA_N
		LEFT OUTER JOIN IstatNazioni AS SAC_N
			ON LHA_N.IstatNazione = SAC_N.Codice
	WHERE
		SAC_N.Codice IS NULL 
		--Escludo i doppi
		AND LHA_N.IstatNazione NOT IN (
			SELECT IstatNazione FROM @TempLhaNazioniDoppie 
		)
	--PRINT 'Numero inserimenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 			
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'
		
------------------------------------------------------------------------
--	FINE AGGIORNAMENTO IstatNazioni
------------------------------------------------------------------------
	

------------------------------------------------------------------------
--	INIZIO AGGIORNAMENTO dbo.DizionarioIstatAsl
------------------------------------------------------------------------
	--
	-- Aggiornamento delle descrizioni
	--
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'DizionarioIstatAsl - Aggiornamento descrizioni:'
	UPDATE SAC_D
		SET SAC_D.DescrizioneAsl = SacConnLha_D.DescrizioneAsl
	FROM [dbo].[SacConnLHA_DizionariLhaAsl] AS SacConnLha_D
		INNER JOIN [dbo].[DizionarioIstatAsl] AS SAC_D
		ON RIGHT('000' + SacConnLha_D.CodiceRegione, 3) = SAC_D.CodiceRegione
			AND RIGHT('000' + CAST(SacConnLha_D.CodiceAsl AS VARCHAR(3)), 3) = SAC_D.CodiceAsl
	WHERE 
		SAC_D.DescrizioneAsl <> SacConnLha_D.DescrizioneAsl
	--PRINT 'Numero aggiornamenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 			
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'

	--
	-- Inserimento nuovi valori
	--
	--SET @T0 = GETDATE()
	--PRINT ''	
	--PRINT 'DizionarioIstatAsl - Inserimento nuovi codici mancanti:'
	INSERT INTO [dbo].[DizionarioIstatAsl] (CodiceRegione, CodiceAsl, DescrizioneAsl, DataUltimaModifica)
	SELECT 
		RIGHT('000' + SacConnLha_D.CodiceRegione, 3) AS CodiceRegione
		, RIGHT('000' + CAST(SacConnLha_D.CodiceAsl AS VARCHAR(3)), 3) AS CodiceAsl
		, SacConnLha_D.DescrizioneAsl 
		, SacConnLha_D.TimestampUltimaModifica AS DataUltimaModifica
	FROM 
		[dbo].[SacConnLHA_DizionariLhaAsl] AS SacConnLha_D
		LEFT OUTER JOIN [dbo].[DizionarioIstatAsl] AS SAC_D
			ON RIGHT('000' + SacConnLha_D.CodiceRegione, 3) = SAC_D.CodiceRegione
				AND RIGHT('000' + CAST(SacConnLha_D.CodiceAsl AS VARCHAR(3)), 3) = SAC_D.CodiceAsl
	WHERE 
		ISNULL(SAC_D.CodiceRegione + SAC_D.CodiceAsl,'') = ''

	--PRINT 'Numero inserimenti : ' + CAST(@@ROWCOUNT AS VARCHAR(10)) 			
	--PRINT 'Durata: ' + CAST(DATEDIFF(MILLISECOND, @T0, GETDATE()) AS VARCHAR(10))+ ' ms'

------------------------------------------------------------------------
--	FINE AGGIORNAMENTO dbo.DizionarioIstatAsl
------------------------------------------------------------------------

END
