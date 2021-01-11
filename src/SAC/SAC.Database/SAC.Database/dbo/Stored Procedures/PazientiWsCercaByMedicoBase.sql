






-- =============================================
-- Author:		...
-- Create date: ...
-- Modify date: 2014-07-02: Ettore - Restituito la DataDecesso
-- Modify date: 2016-07-11: Ettore - Suddivisione in query separate relative ai parametri
--										per ogni query almento un campo obbligatorio
--										altrimenti @parametro IS NULL non usa nessun indice
-- Modify date: 2020-01-31: Ettore - Esclusione delle anagrafiche con Provenienza NON ricercabile [ASMN 7700]
-- Modify date: 2020-01-31: Ettore - Esclusione delle anagrafiche con Provenienza NON ricercabile [ASMN 7700]
--									 Aggiunto OPTION(RECOMPILE)
-- Description:	Ritorna la lista dei pazienti
-- =============================================
CREATE PROCEDURE dbo.PazientiWsCercaByMedicoBase
(
	@Identity varchar(64),
	@CodiceFiscaleMedico varchar(64),
	@Cognome varchar(64),
	@Nome varchar(64),
	@DataNascita datetime,
	@ComuneNascitaNome varchar(128),
	@CodiceFiscale varchar(16),
	@Tessera varchar(16),
	@MaxRecord int
)  WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProvenienzaCorrente VARCHAR(16) 	
	
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsCercaByMedicoBase', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiWsCercaByMedicoBase!', 16, 1)
		RETURN
	END
	--
	-- Ricavo la provenienza dell'utente corrente
	--
	SET @ProvenienzaCorrente = dbo.LeggePazientiProvenienza(@Identity)

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	IF NOT @CodiceFiscaleMedico IS NULL
	BEGIN 
		---------------------------------------------------
		--  Priorità  a CodiceFiscaleFiscaleMedico
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
				(CodiceFiscaleMedicoDiBase = @CodiceFiscaleMedico)
			AND	(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
			AND (Nome LIKE '%' + @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE '%' + @ComuneNascitaNome + '%' OR @ComuneNascitaNome IS NULL)
			AND (CodiceFiscale = @CodiceFiscale OR @CodiceFiscale IS NULL)
			AND (Tessera = @Tessera OR @Tessera IS NULL)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PazientiCercaResult.Provenienza
			)
		OPTION(RECOMPILE)
	END
	ELSE
	BEGIN
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
				(CodiceFiscaleMedicoDiBase = @CodiceFiscaleMedico OR @CodiceFiscaleMedico IS NULL)
			AND	(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
			AND (Nome LIKE '%' + @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND (ComuneNascitaNome LIKE '%' + @ComuneNascitaNome + '%' OR @ComuneNascitaNome IS NULL)
			AND (CodiceFiscale = @CodiceFiscale OR @CodiceFiscale IS NULL)
			AND (Tessera = @Tessera OR @Tessera IS NULL)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PazientiCercaResult.Provenienza
			)
		OPTION(RECOMPILE)
	END

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsCercaByMedicoBase] TO [DataAccessWs]
    AS [dbo];

