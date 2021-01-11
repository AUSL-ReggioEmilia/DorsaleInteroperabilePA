


-- =============================================
-- Author:		...
-- Create date: ...
-- Description:	Ritorna la lista dei pazienti
-- Modify date: 2014-07-02: Ettore - Restituito la DataDecesso
-- Modify date: 2016-07-11: Ettore - Suddivisione in query separate relative ai parametri
--										per ogni query almento un campo obbligatorio
--										altrimenti @parametro IS NULL non usa nessun indice
-- Modify date: 2018/06/01: Eliminazione del carattere '*' usato come wildcard (se presente lo rimuovo e messo +'%' nella where)
-- Modify date: 2019-09-17: Ettore - Aggiunto ORDER BY Cognome, Nome
-- Modify date: 2020-01-31: Ettore - Esclusione delle anagrafiche con Provenienza NON ricercabile [ASMN 7700]
-- =============================================
CREATE PROCEDURE dbo.PazientiWsCerca
(
	@Identity varchar(64),
	@Cognome varchar(64),
	@Nome varchar(64),
	@DataNascita datetime,
	@ComuneNascitaNome varchar(128),
	@CodiceFiscale varchar(16),
	@Tessera varchar(16),
	@MaxRecord int
) WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProvenienzaCorrente VARCHAR(16) 	

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsCerca', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiWsCerca!', 16, 1)
		RETURN
	END
	--
	-- Ricavo la provenienza dell'utente corrente
	--
	SET @ProvenienzaCorrente = dbo.LeggePazientiProvenienza(@Identity)
	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	--
	-- MODIFICA ETTORE 2018/06/01: Solo per retrocompatibilità se l'ultima carattere è un * lo elimino
	--
	IF RIGHT(@Cognome, 1) = '*'
		BEGIN
			SET @Cognome = SUBSTRING(@Cognome, 1, LEN(@Cognome)-1)
		END

	IF RIGHT(@Nome, 1) = '*'
		BEGIN
			SET @Nome = SUBSTRING(@Nome, 1, LEN(@Nome)-1)
		END

	IF RIGHT(@ComuneNascitaNome, 1) = '*'
		BEGIN
			SET @ComuneNascitaNome = SUBSTRING(@ComuneNascitaNome, 1, LEN(@ComuneNascitaNome)-1)
		END

	IF RIGHT(@CodiceFiscale, 1) = '*'
		BEGIN
			SET @CodiceFiscale = SUBSTRING(@CodiceFiscale, 1, LEN(@CodiceFiscale)-1)
		END

	IF RIGHT(@Tessera, 1) = '*'
		BEGIN
			SET @Tessera = SUBSTRING(@Tessera, 1, LEN(@Tessera)-1)
		END


	IF NOT @CodiceFiscale IS NULL
	BEGIN 
		---------------------------------------------------
		--  Priorità  a CodiceFiscale
		---------------------------------------------------
		SELECT TOP(@MaxRecord)
			  Id
			, Provenienza
			, IdProvenienza
			, LivelloAttendibilita
			, DataInserimento
			, DataModifica
			, Tessera
			, Cognome
			, Nome
			, DataNascita
			, Sesso
			, ComuneNascitaCodice
			, ComuneNascitaNome
			, NazionalitaCodice
			, NazionalitaNome
			, CodiceFiscale
			-- Restituzione di DataDecesso
			, DataDecesso
		FROM 
			PazientiCercaResult
		WHERE 
				(CodiceFiscale LIKE @CodiceFiscale + '%')
			AND	(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
			AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE @ComuneNascitaNome + '%' OR @ComuneNascitaNome IS NULL)
			AND (Tessera LIKE @Tessera + '%' OR @Tessera IS NULL)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PazientiCercaResult.Provenienza
				)
		ORDER BY 
			Cognome, Nome
	END

	ELSE IF NOT @Tessera IS NULL
	BEGIN
		---------------------------------------------------
		--  Priorità  a Tessera
		---------------------------------------------------
		SELECT TOP(@MaxRecord)
			  Id
			, Provenienza
			, IdProvenienza
			, LivelloAttendibilita
			, DataInserimento
			, DataModifica
			, Tessera
			, Cognome
			, Nome
			, DataNascita
			, Sesso
			, ComuneNascitaCodice
			, ComuneNascitaNome
			, NazionalitaCodice
			, NazionalitaNome
			, CodiceFiscale
			-- Restituzione di DataDecesso
			, DataDecesso
		FROM 
			PazientiCercaResult
		WHERE 
				(Tessera LIKE @Tessera + '%')				
			AND	(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
			AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE @ComuneNascitaNome + '%' OR @ComuneNascitaNome IS NULL)
			AND (CodiceFiscale LIKE @CodiceFiscale + '%' OR @CodiceFiscale IS NULL)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PazientiCercaResult.Provenienza
				)
		ORDER BY 
			Cognome, Nome
	END

	ELSE IF NOT @Cognome IS NULL
	BEGIN 
		---------------------------------------------------
		--  Priorità  a Cognome
		---------------------------------------------------
		SELECT TOP(@MaxRecord)
			  Id
			, Provenienza
			, IdProvenienza
			, LivelloAttendibilita
			, DataInserimento
			, DataModifica
			, Tessera
			, Cognome
			, Nome
			, DataNascita
			, Sesso
			, ComuneNascitaCodice
			, ComuneNascitaNome
			, NazionalitaCodice
			, NazionalitaNome
			, CodiceFiscale
			-- Restituzione di DataDecesso
			, DataDecesso
		FROM 
			PazientiCercaResult
		WHERE 
			(Cognome LIKE @Cognome + '%')
			AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE @ComuneNascitaNome + '%' OR @ComuneNascitaNome IS NULL)
			AND (CodiceFiscale LIKE @CodiceFiscale + '%' OR @CodiceFiscale IS NULL)
			AND (Tessera LIKE @Tessera + '%' OR @Tessera IS NULL)				
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PazientiCercaResult.Provenienza
				)
		ORDER BY 
			Cognome, Nome
	END 
	ELSE BEGIN
		---------------------------------------------------
		--  Per compatibilità senza filtro obbligatorio
		--		NON userà INDICI
		---------------------------------------------------
		SELECT TOP(@MaxRecord)
			  Id
			, Provenienza
			, IdProvenienza
			, LivelloAttendibilita
			, DataInserimento
			, DataModifica
			, Tessera
			, Cognome
			, Nome
			, DataNascita
			, Sesso
			, ComuneNascitaCodice
			, ComuneNascitaNome
			, NazionalitaCodice
			, NazionalitaNome
			, CodiceFiscale
			-- Restituzione di DataDecesso
			, DataDecesso
		FROM 
			PazientiCercaResult
		WHERE 
			(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
			AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE @ComuneNascitaNome + '%' OR @ComuneNascitaNome IS NULL)
			AND (CodiceFiscale LIKE @CodiceFiscale + '%' OR @CodiceFiscale IS NULL)
			AND (Tessera LIKE @Tessera + '%' OR @Tessera IS NULL)				
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PazientiCercaResult.Provenienza
				)
		ORDER BY 
			Cognome, Nome
	END
END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsCerca] TO [DataAccessWs]
    AS [dbo];

