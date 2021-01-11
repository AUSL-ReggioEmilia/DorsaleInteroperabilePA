





-- =============================================
-- Author:		Stefano P
-- Create date: 2016-10-25
-- Description:	Ricerca in pazienti_ws.PazientiLista
-- Modify Date: 2018-04-16 - simoneB: aggiunta ricerca in like.
-- Modify date: 2020-01-31: Ettore - Esclusione delle anagrafiche con Provenienza NON ricercabile [ASMN 7700]
-- Modify Date: 2020-02-27 - ETTORE: aggiunto nuovi campi da restituire [ASMN 7631]
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazientiByGeneralita]
(
	@MaxRecord int,
	@Ordinamento varchar(128),
	@Identity varchar(64),
	@Cognome varchar(64),
	@Nome varchar(64),
	@DataNascita datetime,
	@AnnoNascita integer,	
	@ComuneNascitaNome varchar(128),
	@CodiceFiscale varchar(16),
	@Tessera varchar(16)	
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
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiByGeneralita', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiByGeneralita!', 16, 1)
		RETURN
	END
	--
	-- Ricavo la provenienza dell'utente corrente
	--
	SET @ProvenienzaCorrente = dbo.LeggePazientiProvenienza(@Identity)

	---------------------------------------------------
	--  Controllo su carattere *
	---------------------------------------------------
	--
	-- SOLO PER RETROCOMPATIBILITA' SE L'ULTIMA LETTERA DEL PARAMETRO E' UN * LO ELIMINO.
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

	--
	-- Imposto '' per l'ordinamento di default
	--
	SET @Ordinamento = ISNULL(@Ordinamento,'')

	--
	-- Range per data anno di nascita
	--
	DECLARE @DataNascitaFromAnnoNascita1 DATETIME
	DECLARE @DataNascitaFromAnnoNascita2 DATETIME
	IF NOT @AnnoNascita IS NULL
	BEGIN 
		--SET @DataNascitaFromAnnoNascita1 = DATEFROMPARTS(@AnnoNascita, 1, 1)
		SET @DataNascitaFromAnnoNascita1 = CAST(CAST(@AnnoNascita AS varchar) + '-1-1' AS DATETIME)
		--SET @DataNascitaFromAnnoNascita2 = DATEFROMPARTS(@AnnoNascita, 12,31)
		SET @DataNascitaFromAnnoNascita2 = CAST(CAST(@AnnoNascita AS varchar) + '-12-31' AS DATETIME)
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
			, DataDecesso
			, MedicoDiBaseCodice
			, MedicoDiBaseCodiceFiscale
			, MedicoDiBaseCognomeNome
			, MedicoDiBaseDistretto
			, MedicoDiBaseDataScelta
			, ConsensoAziendaleCodice
			, ConsensoAziendaleDescrizione
			, ConsensoAziendaleData
			, ConsensoSoleCodice
			, ConsensoSoleDescrizione
			, ConsensoSoleData
			-- Modify Date: 2020-01-27 - ETTORE: aggiunto nuovi campi da restituire [ASMN 7631]
			-- Residenza ----------------------------------
			, ComuneResidenzaCodice
			, ComuneResidenzaNome
			, IndirizzoResidenza
			, LocalitaResidenza
			, ComuneResidenzaCap
			-- Assistito ----------------------------------
			, PosizioneAssistito
			, TerminazioneCodice
			, TerminazioneDescrizione
			, TerminazioneData
			-- Domicilio ----------------------------------
			, ComuneDomicilioCodice
			, ComuneDomicilioNome
			, IndirizzoDomicilio
			, LocalitaDomicilio
			, ComuneDomicilioCap

		FROM 
			pazienti_ws.PazientiLista AS PL
		WHERE 
				(CodiceFiscale LIKE @CodiceFiscale + '%')
			AND	(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
			AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND ( (DataNascita between @DataNascitaFromAnnoNascita1 AND @DataNascitaFromAnnoNascita2) OR @AnnoNascita IS NULL)
			AND (ComuneNascitaNome LIKE @ComuneNascitaNome + '%' OR @ComuneNascitaNome IS NULL)
			AND (Tessera LIKE @Tessera + '%' OR @Tessera IS NULL)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PL.Provenienza
				)

		ORDER BY 
			--Default
			  CASE @Ordinamento  WHEN '' THEN Cognome END DESC
			, CASE @Ordinamento  WHEN '' THEN Nome END DESC
			--Ascendente	
			, CASE @Ordinamento  WHEN 'CognomeNome@ASC' THEN Cognome END ASC --Cognome + nome
			, CASE @Ordinamento  WHEN 'CognomeNome@ASC' THEN Nome END ASC
			, CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN DataNascita END ASC
			, CASE @Ordinamento  WHEN 'DataDecesso@ASC' THEN DataDecesso END ASC
			--Discendente	
			, CASE @Ordinamento  WHEN 'CognomeNome@DESC' THEN Cognome END DESC --Cognome + nome
			, CASE @Ordinamento  WHEN 'CognomeNome@DESC' THEN Nome END DESC
			, CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN DataNascita END DESC
			, CASE @Ordinamento  WHEN 'DataDecesso@DESC' THEN DataDecesso END DESC
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
			, DataDecesso
			, MedicoDiBaseCodice
			, MedicoDiBaseCodiceFiscale
			, MedicoDiBaseCognomeNome
			, MedicoDiBaseDistretto
			, MedicoDiBaseDataScelta
			, ConsensoAziendaleCodice
			, ConsensoAziendaleDescrizione
			, ConsensoAziendaleData
			, ConsensoSoleCodice
			, ConsensoSoleDescrizione
			, ConsensoSoleData
			-- Modify Date: 2020-01-27 - ETTORE: aggiunto nuovi campi da restituire [ASMN 7631]
			-- Residenza ----------------------------------
			, ComuneResidenzaCodice
			, ComuneResidenzaNome
			, IndirizzoResidenza
			, LocalitaResidenza
			, ComuneResidenzaCap
			-- Assistito ----------------------------------
			, PosizioneAssistito
			, TerminazioneCodice
			, TerminazioneDescrizione
			, TerminazioneData
			-- Domicilio ----------------------------------
			, ComuneDomicilioCodice
			, ComuneDomicilioNome
			, IndirizzoDomicilio
			, LocalitaDomicilio
			, ComuneDomicilioCap

		FROM 
			pazienti_ws.PazientiLista AS PL
		WHERE 
				(Tessera LIKE @Tessera + '%')
			AND	(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
			AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND ( (DataNascita between @DataNascitaFromAnnoNascita1 AND @DataNascitaFromAnnoNascita2) OR @AnnoNascita IS NULL)
			AND (ComuneNascitaNome LIKE @ComuneNascitaNome + '%' OR @ComuneNascitaNome IS NULL)
			AND (CodiceFiscale LIKE @CodiceFiscale + '%' OR @CodiceFiscale IS NULL)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PL.Provenienza
				)
		ORDER BY 
			--Default
				CASE @Ordinamento  WHEN '' THEN Cognome END DESC
			,CASE @Ordinamento  WHEN '' THEN Nome END DESC
			--Ascendente	
			, CASE @Ordinamento  WHEN 'CognomeNome@ASC' THEN Cognome END ASC --Cognome + nome
			, CASE @Ordinamento  WHEN 'CognomeNome@ASC' THEN Nome END ASC
			, CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN DataNascita END ASC
			, CASE @Ordinamento  WHEN 'DataDecesso@ASC' THEN DataDecesso END ASC
			--Discendente	
			, CASE @Ordinamento  WHEN 'CognomeNome@DESC' THEN Cognome END DESC --Cognome + nome
			, CASE @Ordinamento  WHEN 'CognomeNome@DESC' THEN Nome END DESC
			, CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN DataNascita END DESC
			, CASE @Ordinamento  WHEN 'DataDecesso@DESC' THEN DataDecesso END DESC
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
			, DataDecesso
			, MedicoDiBaseCodice
			, MedicoDiBaseCodiceFiscale
			, MedicoDiBaseCognomeNome
			, MedicoDiBaseDistretto
			, MedicoDiBaseDataScelta
			, ConsensoAziendaleCodice
			, ConsensoAziendaleDescrizione
			, ConsensoAziendaleData
			, ConsensoSoleCodice
			, ConsensoSoleDescrizione
			, ConsensoSoleData
			-- Modify Date: 2020-01-27 - ETTORE: aggiunto nuovi campi da restituire [ASMN 7631]
			-- Residenza ----------------------------------
			, ComuneResidenzaCodice
			, ComuneResidenzaNome
			, IndirizzoResidenza
			, LocalitaResidenza
			, ComuneResidenzaCap
			-- Assistito ----------------------------------
			, PosizioneAssistito
			, TerminazioneCodice
			, TerminazioneDescrizione
			, TerminazioneData
			-- Domicilio ----------------------------------
			, ComuneDomicilioCodice
			, ComuneDomicilioNome
			, IndirizzoDomicilio
			, LocalitaDomicilio
			, ComuneDomicilioCap

		FROM 
			pazienti_ws.PazientiLista AS PL
		WHERE 
				(Cognome LIKE @Cognome + '%')
			AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND ( (DataNascita between @DataNascitaFromAnnoNascita1 AND @DataNascitaFromAnnoNascita2) OR @AnnoNascita IS NULL)
			AND (ComuneNascitaNome + '%' LIKE @ComuneNascitaNome OR @ComuneNascitaNome IS NULL)
			AND (CodiceFiscale + '%' LIKE @CodiceFiscale OR @CodiceFiscale IS NULL)
			AND (Tessera LIKE @Tessera + '%' OR @Tessera IS NULL)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PL.Provenienza
				)
		ORDER BY 
			--Default
				CASE @Ordinamento  WHEN '' THEN Cognome END DESC
			,CASE @Ordinamento  WHEN '' THEN Nome END DESC
			--Ascendente	
			, CASE @Ordinamento  WHEN 'CognomeNome@ASC' THEN Cognome END ASC --Cognome + nome
			, CASE @Ordinamento  WHEN 'CognomeNome@ASC' THEN Nome END ASC
			, CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN DataNascita END ASC
			, CASE @Ordinamento  WHEN 'DataDecesso@ASC' THEN DataDecesso END ASC
			--Discendente	
			, CASE @Ordinamento  WHEN 'CognomeNome@DESC' THEN Cognome END DESC --Cognome + nome
			, CASE @Ordinamento  WHEN 'CognomeNome@DESC' THEN Nome END DESC
			, CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN DataNascita END DESC
			, CASE @Ordinamento  WHEN 'DataDecesso@DESC' THEN DataDecesso END DESC

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
			, DataDecesso
			, MedicoDiBaseCodice
			, MedicoDiBaseCodiceFiscale
			, MedicoDiBaseCognomeNome
			, MedicoDiBaseDistretto
			, MedicoDiBaseDataScelta
			, ConsensoAziendaleCodice
			, ConsensoAziendaleDescrizione
			, ConsensoAziendaleData
			, ConsensoSoleCodice
			, ConsensoSoleDescrizione
			, ConsensoSoleData
			-- Modify Date: 2020-01-27 - ETTORE: aggiunto nuovi campi da restituire [ASMN 7631]
			-- Residenza ----------------------------------
			, ComuneResidenzaCodice
			, ComuneResidenzaNome
			, IndirizzoResidenza
			, LocalitaResidenza
			, ComuneResidenzaCap
			-- Assistito ----------------------------------
			, PosizioneAssistito
			, TerminazioneCodice
			, TerminazioneDescrizione
			, TerminazioneData
			-- Domicilio ----------------------------------
			, ComuneDomicilioCodice
			, ComuneDomicilioNome
			, IndirizzoDomicilio
			, LocalitaDomicilio
			, ComuneDomicilioCap

		FROM 
			pazienti_ws.PazientiLista AS PL
		WHERE 
			(Cognome LIKE @Cognome + '%' OR @Cognome IS NULL)
			AND (Nome LIKE @Nome + '%' OR @Nome IS NULL)
			AND (DataNascita = @DataNascita OR @DataNascita IS NULL)
			AND ( (DataNascita between @DataNascitaFromAnnoNascita1 AND @DataNascitaFromAnnoNascita2) OR @AnnoNascita IS NULL)
			AND (ComuneNascitaNome + '%' LIKE @ComuneNascitaNome OR @ComuneNascitaNome IS NULL)
			AND (CodiceFiscale LIKE @CodiceFiscale + '%' OR @CodiceFiscale IS NULL)
			AND (Tessera LIKE @Tessera + '%' OR @Tessera IS NULL)
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PL.Provenienza
				)
		ORDER BY 
			--Default
				CASE @Ordinamento  WHEN '' THEN Cognome END DESC
			,CASE @Ordinamento  WHEN '' THEN Nome END DESC
			--Ascendente	
			, CASE @Ordinamento  WHEN 'CognomeNome@ASC' THEN Cognome END ASC --Cognome + nome
			, CASE @Ordinamento  WHEN 'CognomeNome@ASC' THEN Nome END ASC
			, CASE @Ordinamento  WHEN 'DataNascita@ASC' THEN DataNascita END ASC
			, CASE @Ordinamento  WHEN 'DataDecesso@ASC' THEN DataDecesso END ASC
			--Discendente	
			, CASE @Ordinamento  WHEN 'CognomeNome@DESC' THEN Cognome END DESC --Cognome + nome
			, CASE @Ordinamento  WHEN 'CognomeNome@DESC' THEN Nome END DESC
			, CASE @Ordinamento  WHEN 'DataNascita@DESC' THEN DataNascita END DESC
			, CASE @Ordinamento  WHEN 'DataDecesso@DESC' THEN DataDecesso END DESC

	END 

END