




CREATE PROCEDURE dbo.PazientiBatchMerge
(
	@MaxNumFusioni AS INT = NULL -- limita il numero massimo di fusioni padre-figlio
	, @Minuti INT = 60			 -- serve ad escludere anagrafiche con DataModifica più vecchia di N minuti
)
AS
BEGIN
/*
	--MODIFICA ETTORE 2013-05-15: 
	--	1) tolto uso tabella temporanea per evitare scritture su tempdb
	--  2) nuova select per il cursore principale per escludere anagrafiche più vecchie di N minuti
	-----------------------------------------------------------------------------------
	-- ATTENZIONE
	-- Il controllo di fascia orario non viene più fatto qui 
	-- ma implementato nello scheduler: 
	--			tutti i giorni dalle 08:00 alle 18:00
	--			tranne il sabato e la domenica
	-----------------------------------------------------------------------------------

	1) Trova tutte le triplette [Cognome, Nome, CodiceFiscale] multiple che sono quindi soggette a fusione 
		(modifica Ettore 20/07/2012)
		
	2) Per ogni posizione con stesso [Cognome, Nome, CodiceFiscale] determina il "peso" della posizione
	3) Seleziona come padre della fusione, @IdPadre, la posizione a maggior livello
	   di attendibilità e con maggior peso
	4) Fonde le posizioni con stesso codice fiscale nel padre di fusione @IdPadre
	5) I figli vengono posti tutti allo stesso livello
	6) L'elaborazione del batch termina una volta raggiunto o superato il numero massimo 
	   di fusioni permesse @MaxNumFusioni

		MODIFICA ETTORE 2016-07-18: gestione delle anagrafiche che possono essere fuse automaticamente (per gestione provenienza HPV)
		MODIFICA ETTORE 2016-08-01: Eliminazione dei WITH(NOLOCK) e lettura di record modificati almeno 5 minuti fa rispetto alla data corrente
									per evitare problema autofusioni.
									Se IdPaziente = IdPazienteFuso non eseguo la fusione

		MODIFICA ETTORE 2019-10-21: Nuovo codice per eseguire fusioni fra anagrafche con stesso livello di attendibilità in base a configurazione

*/
	--
	-- I campi su cui si basa la regola di fusione (modifica Ettore 20/07/2012)
	--
	DECLARE @CodiceFiscale varchar(16)
	DECLARE @Cognome varchar(64)
	DECLARE @Nome varchar(64)
	--
	--
	--
	DECLARE @IdFiglio uniqueidentifier;	DECLARE @IdPadre uniqueidentifier
	DECLARE @LivAttendPadre tinyint; DECLARE @LivAttendFiglio tinyint
	DECLARE @CognomePadre varchar(64); DECLARE @CognomeFiglio varchar(64)
	DECLARE @NomePadre varchar(64); DECLARE @NomeFiglio varchar(64)
	DECLARE @DataNascitaPadre datetime; DECLARE @DataNascitaFiglio datetime
	DECLARE @SessoPadre varchar(1); DECLARE @SessoFiglio varchar(1)
	DECLARE @ComuneNascitaCodicePadre varchar(6); DECLARE @ComuneNascitaCodiceFiglio varchar(6)
	DECLARE @TesseraPadre varchar(16); DECLARE @TesseraFiglio varchar(16)
	DECLARE @CodiceFiscalePadre varchar(16); DECLARE @CodiceFiscaleFiglio varchar(16)
	DECLARE @ProvenienzaPadre varchar(16); DECLARE @ProvenienzaFiglio varchar(16)
	DECLARE @IdProvenienzaPadre varchar(64); DECLARE @IdProvenienzaFiglio varchar(64)

	DECLARE @FirstLoop bit
	DECLARE @TotaleDuplicati int
	DECLARE @TotalePosizioniFuse int
	DECLARE @CounterDuplicati int
	DECLARE @DataModificaMax DATETIME

	DECLARE @FusionePazientiConUgualeAttendibilita BIT = 0
	--
	-- MODIFICA ETTORE 2019-10-21: Memorizzo la configurazone per le fusioni di uguale livello di attendiblità
	--
	SET @FusionePazientiConUgualeAttendibilita = [dbo].[ConfigPazientiFusionePazientiConUgualeAttendibilita]()
	

	DECLARE @Utente varchar(64)
	SET @Utente = USER_NAME()
	--
	-- Limito il numero di fusioni
	--
	IF @MaxNumFusioni IS NULL
		SET @MaxNumFusioni = 500

	SET NOCOUNT ON;	
	
	---------------------------------------------------
	-- Azzero Performance Counter
	---------------------------------------------------
	EXEC sp_user_counter7 0
	EXEC sp_user_counter8 0
	
	---------------------------------------------------
	-- Aggiorna i dati senza controllo della concorrenza
	---------------------------------------------------
	DECLARE curSearchDuplicate CURSOR STATIC READ_ONLY FOR 	
	--
	-- Recupero tutti i codice fiscali multipli
	-- [bisognerebbe anche aggiungere controllo sui codici fiscali = '0' o '00' ...]
	-- Attenzione cerco i duplicati per CodiceFiscale, Cognome, Nome
	--
	SELECT Pazienti.CodiceFiscale, Pazienti.Cognome, Pazienti.Nome
		  , MAX(Pazienti.DataModifica) AS DataModificaMax
	FROM 
		Pazienti
		INNER JOIN (
				SELECT CodiceFiscale, Cognome, Nome
				FROM Pazienti
				 WHERE 
					--MODIFICA ETTORE 2016-08-01: processo anagrafiche la cui data di modifica è vecchia di almeno 5 minuti per evitare problema autofusioni
					DataModifica < DATEADD(minute, -5, GETDATE())
					--Pazienti modificati entro @Minuti dalla data corrente
					AND DataModifica >= DATEADD(minute, - @Minuti, GETDATE())
					AND Disattivato = 0
			  		--
					-- MODIFICA ETTORE 2018-07-18: Includo solo le provenienza che possono essere fuse automaticamente
					--
					AND Pazienti.Provenienza IN (SELECT Provenienza From Provenienze WHERE FusioneAutomatica = 1)
		 ) PazientiRecenti
          ON Pazienti.CodiceFiscale = PazientiRecenti.CodiceFiscale
			AND Pazienti.Cognome = PazientiRecenti.Cognome
			AND Pazienti.Nome = PazientiRecenti.Nome
	WHERE LEN(ISNULL(Pazienti.CodiceFiscale, '')) > 0 
		  AND Pazienti.CodiceFiscale <> '0000000000000000' 
		  AND Pazienti.CodiceFiscale <> '0' 
		  AND Pazienti.Disattivato = 0
		  --
		  -- MODIFICA ETTORE 2018-07-18: Includo solo le provenienza che possono essere fuse automaticamente
		  --
		  AND Pazienti.Provenienza IN (SELECT Provenienza From Provenienze WHERE FusioneAutomatica = 1)

	GROUP BY Pazienti.CodiceFiscale, Pazienti.Cognome, Pazienti.Nome
	HAVING COUNT(Pazienti.CodiceFiscale + Pazienti.Cognome + Pazienti.Nome) > 1
		  AND MAX(Pazienti.DataModifica) >= DATEADD(minute, - @Minuti, GETDATE())
	
	
	--
	-- Apro cursore su posizioni duplicate
	--
	OPEN curSearchDuplicate
	SET @TotaleDuplicati = @@CURSOR_ROWS
	SET @TotalePosizioniFuse = 0
	SET @CounterDuplicati = 0
	FETCH NEXT FROM curSearchDuplicate INTO @CodiceFiscale, @Cognome, @Nome, @DataModificaMax 
	WHILE @@FETCH_STATUS = 0 AND @TotalePosizioniFuse < @MaxNumFusioni 
		BEGIN
			SET @CounterDuplicati = @CounterDuplicati + 1
			PRINT ''
			PRINT CAST(@CounterDuplicati AS VARCHAR(10)) + '/' + CAST(@TotaleDuplicati AS VARCHAR(10))  
				  + ' - Fusioni relative a ' + @CodiceFiscale + ' ' + @Cognome + ' ' + @Nome
			--
			-- Memorizzo i dati del padre
			--				  
			SET @IdFiglio = NULL;	SET @IdPadre = NULL
			SET @LivAttendPadre = NULL; SET @LivAttendFiglio = NULL
			SET @CognomePadre = NULL; SET @CognomeFiglio = NULL
			SET @NomePadre = NULL; SET @NomeFiglio = NULL
			SET @DataNascitaPadre = NULL; SET @DataNascitaFiglio = NULL
			SET @SessoPadre = NULL; SET @SessoFiglio = NULL
			SET @ComuneNascitaCodicePadre = NULL; SET @ComuneNascitaCodiceFiglio = NULL
			SET @TesseraPadre = NULL; SET @TesseraFiglio = NULL
			SET @CodiceFiscalePadre = NULL; SET @CodiceFiscaleFiglio = NULL
			SET @ProvenienzaPadre = NULL; SET @ProvenienzaFiglio = NULL
			SET @IdProvenienzaPadre = NULL; SET @IdProvenienzaFiglio = NULL
			--
			-- Trovo il padre
			--
			SELECT TOP 1 
				@IdPadre = Id , @LivAttendPadre=LivelloAttendibilita
				, @ProvenienzaPadre=Provenienza, @IdProvenienzaPadre=IdProvenienza, 
				@CognomePadre=Cognome, @NomePadre=Nome, @DataNascitaPadre=DataNascita, @SessoPadre=Sesso
				, @ComuneNascitaCodicePadre=ComuneNascitaCodice
				, @TesseraPadre=Tessera, @CodiceFiscalePadre = CodiceFiscale
			FROM 
				Pazienti
			WHERE 
				(CodiceFiscale = @CodiceFiscale AND Cognome = @Cognome AND Nome = @Nome)
				AND Disattivato = 0
			ORDER BY 
				LivelloAttendibilita DESC
				, dbo.GetPesoPaziente(Cognome, Nome, DataNascita, Sesso, ComuneNascitaCodice, Tessera) DESC -- Fondamentale questo ordinamento

			IF NOT @IdPadre IS NULL
			BEGIN
				--
				-- Scrivo per debug
				--
				PRINT   'Padre fusione:'
					  + ' Id: ' + CAST(@IdPadre AS VARCHAR(64)) 
					  + ' CodiceFiscale=' + ISNULL(@CodiceFiscalePadre,'NULL')
					  + ' LivAttendibilità=' + CAST(@LivAttendPadre AS VARCHAR(10))
					  + ' Provenienza=' + ISNULL(@ProvenienzaPadre,'NULL')
					  + ' IdProvenienza='+ ISNULL(@IdProvenienzaPadre,'NULL')
				PRINT + '              ' 
					  + ' Cognome=' + ISNULL(@CognomePadre,'NULL')
					  + ' Nome=' + ISNULL(@NomePadre, 'NULL')
					  + ' DataNascita=' + ISNULL(CONVERT(VARCHAR(12), @DataNascitaPadre, 102) ,'NULL')
					  + ' Sesso=' + ISNULL(CAST(@SessoPadre AS VARCHAR(4)),'NULL')
					  + ' ComuneNascitaCodice=' + ISNULL(@ComuneNascitaCodicePadre,'NULL')
					  + ' Tessera=' + ISNULL(@TesseraPadre,'NULL')
				--
				--
				-- Apro il secondo cursore per trovare i possibili figli
				--
				DECLARE curFigli CURSOR STATIC READ_ONLY FOR 	
				SELECT 
					Id, LivelloAttendibilita, Provenienza, IdProvenienza, Cognome, Nome, DataNascita, Sesso, ComuneNascitaCodice, Tessera
				FROM 
					Pazienti
				WHERE (Id <> @IdPadre) --escludo la posizione padre della fusione
					AND (CodiceFiscale = @CodiceFiscale AND Cognome = @Cognome AND Nome = @Nome)
					AND Disattivato = 0
					--
					-- MODIFICA ETTORE 2018-07-18: Includo solo le provenienza che possono essere fuse automaticamente
					--
					AND Pazienti.Provenienza IN (SELECT Provenienza From Provenienze WHERE FusioneAutomatica = 1)
					--
					-- MODIFICA ETTORE 2019-10-21: gestisco configurabilità della fusione fra anagrafiche con uguale livello di attendibilità
					-- Da questa query in base alla configurazione @FusionePazientiConUgualeAttendibilita vengono restituiti pazienti possibili figli
					-- con livello attendibilità <= al livello attendibilità del padre se @FusionePazientiConUgualeAttendibilita = 1 
					-- con livello attendibilità <  al livello attendibilità del padre se @FusionePazientiConUgualeAttendibilita = 0 
					--
					AND (
							(@FusionePazientiConUgualeAttendibilita = 1  AND LivelloAttendibilita <= @LivAttendPadre)
							OR
							(@FusionePazientiConUgualeAttendibilita = 0  AND LivelloAttendibilita < @LivAttendPadre)
						)
				ORDER BY 
					LivelloAttendibilita DESC
					, dbo.GetPesoPaziente(Cognome, Nome, DataNascita, Sesso, ComuneNascitaCodice, Tessera) DESC --per prima leggo la posizione a attendibilità e peso maggiore
				OPEN curFigli
				FETCH NEXT FROM curFigli
					INTO @IdFiglio, @LivAttendFiglio, @ProvenienzaFiglio, @IdProvenienzaFiglio, @CognomeFiglio, @NomeFiglio,
					@DataNascitaFiglio, @SessoFiglio, @ComuneNascitaCodiceFiglio, @TesseraFiglio
				WHILE @@FETCH_STATUS = 0 
				BEGIN
					BEGIN TRY
						--
						-- Eseguo solo se il livello di attendibilità del figlio è minore o uguale di quello del padre
						-- (dovrebbe già essere garantito dall'ordinamento nella tabella temporanea) e se il livello di attendibilità
						-- del figlio è minore al massimo livello di attendibilità per cui è permessa una fusione
						-- e se il figlio ha una provenienza per cui è ammessa la fusione
						-- MODIFICA ETTORE 2019-10-21: gestisco configurabilità della fusione fra anagrafiche con uguale livello di attendibilità
						-- In base alla configurazione @FusionePazientiConUgualeAttendibilita la query sui figli può non restituire
						-- pazienti con livello attendibilita uguale a quello del padre
						--
						IF  (@LivAttendPadre >= @LivAttendFiglio) AND 
							(dbo.GetPermessoFusioneByProvenienza(@ProvenienzaFiglio) <> 0) AND 
							(dbo.GetPermessoFusioneByLivelloAttendibilita(@LivAttendFiglio) <> 0)
						BEGIN
							--
							-- Merge + notifica: qui si potrebbe chiamare la dbo.PazientiBatchMergeInsert2...
							--
							--MODIFICA ETTORE 2016-08-01: Eseguo un test di sicurezza per evitare autofusioni
							IF @IdPadre <> @IdFiglio 
							BEGIN
								EXEC dbo.PazientiBatchMergeInsert  @IdPadre, @IdFiglio, @ProvenienzaFiglio, @IdProvenienzaFiglio
								EXEC PazientiNotificheAdd @IdFiglio, '3', @Utente										
								PRINT CHAR(9) + '-> FUSIONE : IdFiglio=' + CAST(@IdFiglio AS VARCHAR(40)) + ' [Provenienza,LivAttendibilità]=[' +  @ProvenienzaFiglio + ',' + CAST(@LivAttendFiglio AS VARCHAR(10)) + ']' 
								--
								-- Conto le fusioni
								--
								SET @TotalePosizioniFuse = @TotalePosizioniFuse + 1
							END
							ELSE
							BEGIN 
								PRINT CHAR(9) + '-> Fusione NON ESEGUITA: IdPadre=IdFiglio! IdFiglio=' + CAST(@IdFiglio AS VARCHAR(40))
							END 
						END
						ELSE
						BEGIN
							PRINT CHAR(9) + '-> Fusione NON ESEGUITA: IdFiglio=' + CAST(@IdFiglio AS VARCHAR(40)) + ' [Provenienza,LivAttendibilità]=[' +  @ProvenienzaFiglio + ',' + CAST(@LivAttendFiglio AS VARCHAR(10)) + ']' 
						END
					END TRY
					BEGIN CATCH
						PRINT 'Errore: IdPadre=' + cast(@IdPadre as varchar(40)) + 
									  ' IdFiglio=' + CAST(@IdFiglio as varchar(40)) + 
									  ' ProvenienzaFiglio=' + ISNULL(@ProvenienzaFiglio,'NULL') + 
									  ' IdProvenienzaFiglio='+ ISNULL(@IdProvenienzaFiglio,'NULL') +
									  ' CodiceFiscaleFiglio=' + ISNULL(@CodiceFiscaleFiglio,'NULL')
					END CATCH
					--
					-- Avanzo il secondo cursore
					-- 	
					FETCH NEXT FROM curFigli
						INTO @IdFiglio, @LivAttendFiglio, @ProvenienzaFiglio, @IdProvenienzaFiglio, @CognomeFiglio, @NomeFiglio,
						@DataNascitaFiglio, @SessoFiglio, @ComuneNascitaCodiceFiglio, @TesseraFiglio
				END
				--
				-- Reset della variabile
				--
				SET @IdPadre = NULL
				--
				-- Chiudo il cursore
				--
				CLOSE curFigli
				DEALLOCATE curFigli			
			
			END
			  
			--
			-- Performance Counter
			--
			DECLARE @Valore INT

			SET @Valore = @TotalePosizioniFuse
			EXEC sp_user_counter7 @Valore

			SET @Valore = (@CounterDuplicati * 100 / @TotaleDuplicati)
			EXEC sp_user_counter8 @Valore

			--
			-- Avanzo il primo cursore
			-- 			
			FETCH NEXT FROM curSearchDuplicate INTO @CodiceFiscale, @Cognome, @Nome, @DataModificaMax 
		END

		--
		-- Chiudo il cursore
		--
		CLOSE curSearchDuplicate
		DEALLOCATE curSearchDuplicate
		
		PRINT ''
		PRINT 'Totale Posizioni Fuse: ' + CAST(@TotalePosizioniFuse AS VARCHAR(10))

END

