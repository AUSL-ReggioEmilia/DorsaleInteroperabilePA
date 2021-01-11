
-- =============================================
-- Author:		...
-- Create date: ...
-- Modify date: 2014-07-07: Ettore - Disaccoppiato la SP dalla SP WS PazientiWsCerca()
-- Modify date: 2016-05-26: Sandro - Rimosso controllo accesso di lettura
-- Modify date: 2016-07-07: Ettore - Aggiunto WITH RECOMPILE
-- Modify date: 2016-07-11: Sandro - Suddivisione in query separate relative ai parametri
--										per ogni query almento un campo obbligatorio
--										altrimenti @parametro IS NULL non usa nessun indice
-- Description:	Ritorna la lista dei pazienti
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputCerca]
(
	  @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @LuogoNascita varchar(128)
	, @CodiceFiscale varchar(16)
	, @Tessera varchar(16)
	, @MaxRecord int
) WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;

	IF @MaxRecord IS NULL
	BEGIN
		RAISERROR('Il parametro MaxRecord non può essere NULL!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Impostazione parametri
	---------------------------------------------------
	IF RIGHT(@Cognome, 1) = '*'
	BEGIN
		SET @Cognome = SUBSTRING(@Cognome, 1, LEN(@Cognome)-1) + '%'
	END

	IF RIGHT(@Nome, 1) = '*'
	BEGIN
		SET @Nome = SUBSTRING(@Nome, 1, LEN(@Nome)-1) + '%'
	END

	IF RIGHT(@LuogoNascita, 1) = '*'
	BEGIN
		SET @LuogoNascita = SUBSTRING(@LuogoNascita, 1, LEN(@LuogoNascita)-1) + '%'
	END

	IF RIGHT(@CodiceFiscale, 1) = '*'
	BEGIN
		SET @CodiceFiscale = SUBSTRING(@CodiceFiscale, 1, LEN(@CodiceFiscale)-1) + '%'
	END

	IF RIGHT(@Tessera, 1) = '*'
	BEGIN
		SET @Tessera = SUBSTRING(@Tessera, 1, LEN(@Tessera)-1) + '%'
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
		FROM 
			PazientiCercaResult
		WHERE 
				CodiceFiscale LIKE @CodiceFiscale
			AND	(Cognome LIKE @Cognome OR @Cognome IS NULL)
			AND (Nome LIKE @Nome OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE @LuogoNascita OR @LuogoNascita IS NULL)
			AND (Tessera LIKE @Tessera OR @Tessera IS NULL)	
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
		FROM 
			PazientiCercaResult
		WHERE 
				Tessera LIKE @Tessera
			AND (Cognome LIKE @Cognome OR @Cognome IS NULL)
			AND (Nome LIKE @Nome OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE @LuogoNascita OR @LuogoNascita IS NULL)
			AND (CodiceFiscale LIKE @CodiceFiscale OR @CodiceFiscale IS NULL)
	END
	
	ELSE IF NOT @Cognome IS NULL
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
		FROM 
			PazientiCercaResult
		WHERE 
				Cognome LIKE @Cognome
			AND (Nome LIKE @Nome OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE @LuogoNascita OR @LuogoNascita IS NULL)
			AND (CodiceFiscale LIKE @CodiceFiscale OR @CodiceFiscale IS NULL)
			AND (Tessera LIKE @Tessera OR @Tessera IS NULL)	
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
		FROM 
			PazientiCercaResult
		WHERE 
				(Cognome LIKE @Cognome OR @Cognome IS NULL)
			AND (Nome LIKE @Nome OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE @LuogoNascita OR @LuogoNascita IS NULL)
			AND (CodiceFiscale LIKE @CodiceFiscale OR @CodiceFiscale IS NULL)
			AND (Tessera LIKE @Tessera OR @Tessera IS NULL)	
	END	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputCerca] TO [DataAccessSql]
    AS [dbo];

