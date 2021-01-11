



-- =============================================
-- Author:		Ettore
-- Create date: 2013-01-30
-- Modify date: 2014-07-07: Ettore - Restituito la DataDecesso
-- Modify date: 2014-07-07: Ettore - Bloccato output, tolto SELECT * FROM PazientiDettaglioResult
-- Modify date: 2016-07-18: Ettore - Se fuso restituisco il padre nel campo IdPazienteAttivo
--									ATTENZIONE: questa SP restituisce solo gli attivi quindi IdPazienteAttivo sarà sempre NULL
-- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
-- Modify date: 2020-01-31: Ettore - Esclusione delle anagrafiche con Provenienza NON ricercabile [ASMN 7700]
-- Description:	Ricerca per generalità da usare da BT al posto del metodo presente nella DataAccess del SAC
-- =============================================
CREATE PROCEDURE dbo.PazientiWsCercaDettagliByGeneralita
(
	@Identity VARCHAR(64)
	, @Id uniqueidentifier
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @CodiceFiscale varchar(16)
	, @Sesso varchar(1)
	, @MaxRecord int
	, @SortOrder int 
) WITH RECOMPILE
AS
BEGIN
/*
	@SortOrder: 0=Cognome+Nome, 1=Cognome, 2=Nome, 3=DataNascita, 4=CodiceFiscale, 5=Sesso
	
	Questa SP è stata creata per essere utilizzata in Biztalk, al posto del metodo 
	ListaPazientiByGeneralita() presente nella DLL DataAccess del SAC.
	
	Di questa SP deve esistere anche la SP corrispondente PazientiOutputCercaDettagliByGeneralita()???
*/

	SET NOCOUNT ON;
	DECLARE @ProvenienzaCorrente VARCHAR(16) 
	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, '[PazientiWsCercaDettagliByGeneralita]', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante [PazientiWsCercaDettagliByGeneralita]!', 16, 1)
		RETURN
	END

	--
	-- Ricavo la provenienza dell'utente corrente
	--
	SET @ProvenienzaCorrente = dbo.LeggePazientiProvenienza(@Identity)

	--
	-- Aggiustamento dei parametri
	--
	IF @Cognome = '' SET @Cognome = NULL
	IF @Nome = '' SET @Nome = NULL
	IF @CodiceFiscale = '' SET @CodiceFiscale = NULL
	IF @Sesso = '' SET @Sesso = NULL	
	-- Se valori non validi per @SortOrder lo imposto a 0 (il metodo del WS controlla che i valori passati siano validi)
	IF @SortOrder IS NULL OR (@SortOrder < 0 OR @SortOrder > 5)
		SET @SortOrder = 0
		
	
	---------------------------------------------------
	--  CERCA PER ID
	---------------------------------------------------
	IF NOT @Id IS NULL
	BEGIN
		SELECT TOP (@MaxRecord)
				Id, Provenienza, IdProvenienza, LivelloAttendibilita, DataInserimento
			  , DataModifica, Tessera, Cognome, Nome, DataNascita, Sesso
			  , ComuneNascitaCodice, ComuneNascitaNome, ProvinciaNascitaCodice, ProvinciaNascitaNome
			  , NazionalitaCodice, NazionalitaNome, CodiceFiscale, DatiAnamnestici
			  , MantenimentoPediatra, CapoFamiglia, Indigenza
			  -- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione
			  , ComuneResCodice, ComuneResNome, ProvinciaResCodice, ProvinciaResNome, SubComuneRes
			  , IndirizzoRes, LocalitaRes, CapRes, DataDecorrenzaRes, ProvinciaAslResCodice, ProvinciaAslResNome
			  , ComuneAslResCodice, ComuneAslResNome, CodiceAslRes, RegioneResCodice, RegioneResNome
			  , ComuneDomCodice, ComuneDomNome, ProvinciaDomCodice, ProvinciaDomNome, SubComuneDom, IndirizzoDom
			  , LocalitaDom, CapDom, PosizioneAss, RegioneAssCodice, RegioneAssNome, ProvinciaAslAssCodice
			  , ProvinciaAslAssNome, ComuneAslAssCodice, ComuneAslAssNome, CodiceAslAss, DataInizioAss
			  , DataScadenzaAss
			  -- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN dbo.GetPazientiDataDecesso(Id) ELSE DataTerminazioneAss END AS DataTerminazioneAss
			  , DistrettoAmm, DistrettoTer, Ambito
			  , CodiceMedicoDiBase, CodiceFiscaleMedicoDiBase, CognomeNomeMedicoDiBase
			  , DistrettoMedicoDiBase, DataSceltaMedicoDiBase, ComuneRecapitoCodice, ComuneRecapitoNome
			  , ProvinciaRecapitoCodice, ProvinciaRecapitoNome, IndirizzoRecapito, LocalitaRecapito
			  , Telefono1, Telefono2, Telefono3, CodiceSTP, DataInizioSTP, DataFineSTP, MotivoAnnulloSTP
			  , StatusCodice, StatusNome
			  --
			  -- Restituisco la DataDecesso (non eseguo test se attivo o fuso perchè questa SP restotuisce sempre e solo gli attivi)
			  --
			  , dbo.GetPazientiDataDecesso(Id) AS DataDecesso
			 --
			 -- Modifica Ettore 2016-07-18: se fuso restituisco il padre
			 -- Poichè questa restotuisce sempre e solo gli attivi restiotuisco sempre NULL
			 --
			 , CAST(NULL AS UNIQUEIDENTIFIER) AS IdPazienteAttivo

        FROM dbo.PazientiDettaglioResult AS PDR
		WHERE
				Id = @Id
			AND StatusCodice = 0 --solo gli attivi

			-- Manteniamo per compatibilità
			AND ((Cognome Like @Cognome + '%') OR (@Cognome IS NULL))
			AND ((Nome Like @Nome + '%') OR (@Nome IS NULL))
			AND ((DataNascita = @DataNascita) OR (@DataNascita IS NULL))
			AND ((CodiceFiscale = @CodiceFiscale) OR (@CodiceFiscale IS NULL))
			AND ((Sesso = @Sesso) OR (@Sesso IS NULL))
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PDR.Provenienza
				)

	END
	---------------------------------------------------
	--  CERCA PER @Cognome
	---------------------------------------------------
	ELSE IF NOT @Cognome IS NULL
	BEGIN 
		SELECT TOP (@MaxRecord)
				Id, Provenienza, IdProvenienza, LivelloAttendibilita, DataInserimento
			  , DataModifica, Tessera, Cognome, Nome, DataNascita, Sesso
			  , ComuneNascitaCodice, ComuneNascitaNome, ProvinciaNascitaCodice, ProvinciaNascitaNome
			  , NazionalitaCodice, NazionalitaNome, CodiceFiscale, DatiAnamnestici
			  , MantenimentoPediatra, CapoFamiglia, Indigenza
			  -- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione
			  , ComuneResCodice, ComuneResNome, ProvinciaResCodice, ProvinciaResNome, SubComuneRes
			  , IndirizzoRes, LocalitaRes, CapRes, DataDecorrenzaRes, ProvinciaAslResCodice, ProvinciaAslResNome
			  , ComuneAslResCodice, ComuneAslResNome, CodiceAslRes, RegioneResCodice, RegioneResNome
			  , ComuneDomCodice, ComuneDomNome, ProvinciaDomCodice, ProvinciaDomNome, SubComuneDom, IndirizzoDom
			  , LocalitaDom, CapDom, PosizioneAss, RegioneAssCodice, RegioneAssNome, ProvinciaAslAssCodice
			  , ProvinciaAslAssNome, ComuneAslAssCodice, ComuneAslAssNome, CodiceAslAss, DataInizioAss
			  , DataScadenzaAss
			  -- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN dbo.GetPazientiDataDecesso(Id) ELSE DataTerminazioneAss END AS DataTerminazioneAss
			  , DistrettoAmm, DistrettoTer, Ambito
			  , CodiceMedicoDiBase, CodiceFiscaleMedicoDiBase, CognomeNomeMedicoDiBase
			  , DistrettoMedicoDiBase, DataSceltaMedicoDiBase, ComuneRecapitoCodice, ComuneRecapitoNome
			  , ProvinciaRecapitoCodice, ProvinciaRecapitoNome, IndirizzoRecapito, LocalitaRecapito
			  , Telefono1, Telefono2, Telefono3, CodiceSTP, DataInizioSTP, DataFineSTP, MotivoAnnulloSTP
			  , StatusCodice, StatusNome
			  --
			  -- Restituisco la DataDecesso (non eseguo test se attivo o fuso perchè questa SP restotuisce sempre e solo gli attivi)
			  --
			  , dbo.GetPazientiDataDecesso(Id) AS DataDecesso
			 --
			 -- Modifica Ettore 2016-07-18: se fuso restituisco il padre
			 -- Poichè questa restotuisce sempre e solo gli attivi restiotuisco sempre NULL
			 --
			 , CAST(NULL AS UNIQUEIDENTIFIER) AS IdPazienteAttivo
		FROM 
			dbo.PazientiDettaglioResult AS PDR
		WHERE 
				Cognome Like @Cognome + '%'
			AND StatusCodice = 0 --solo gli attivi
			AND ((Nome Like @Nome + '%') OR (@Nome IS NULL))
			AND ((DataNascita = @DataNascita) OR (@DataNascita IS NULL))
			AND ((CodiceFiscale = @CodiceFiscale) OR (@CodiceFiscale IS NULL))
			AND ((Sesso = @Sesso) OR (@Sesso IS NULL))
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PDR.Provenienza
				)

		ORDER BY 	
				CASE 
					WHEN @SortOrder = 1 THEN Cognome
					WHEN @SortOrder = 2 THEN Nome
					WHEN @SortOrder = 3 THEN CONVERT(VARCHAR(20), DataNascita  , 120) --deve essere una stringa
					WHEN @SortOrder = 4 THEN CodiceFiscale
					WHEN @SortOrder = 5 THEN Sesso
					ELSE Cognome 
				END
				--- 2016-07-11 Ordinamento siu più campi
				,
				CASE 
					WHEN @SortOrder = 0 THEN Nome
				END
				,
				CASE 
					WHEN @SortOrder = 0 THEN DataModifica
				END

	END	ELSE BEGIN
	---------------------------------------------------
	--  CERCA PER tutti (per compatibilità)
	---------------------------------------------------
		SELECT TOP (@MaxRecord)
				Id, Provenienza, IdProvenienza, LivelloAttendibilita, DataInserimento
			  , DataModifica, Tessera, Cognome, Nome, DataNascita, Sesso
			  , ComuneNascitaCodice, ComuneNascitaNome, ProvinciaNascitaCodice, ProvinciaNascitaNome
			  , NazionalitaCodice, NazionalitaNome, CodiceFiscale, DatiAnamnestici
			  , MantenimentoPediatra, CapoFamiglia, Indigenza
			  -- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione
			  , ComuneResCodice, ComuneResNome, ProvinciaResCodice, ProvinciaResNome, SubComuneRes
			  , IndirizzoRes, LocalitaRes, CapRes, DataDecorrenzaRes, ProvinciaAslResCodice, ProvinciaAslResNome
			  , ComuneAslResCodice, ComuneAslResNome, CodiceAslRes, RegioneResCodice, RegioneResNome
			  , ComuneDomCodice, ComuneDomNome, ProvinciaDomCodice, ProvinciaDomNome, SubComuneDom, IndirizzoDom
			  , LocalitaDom, CapDom, PosizioneAss, RegioneAssCodice, RegioneAssNome, ProvinciaAslAssCodice
			  , ProvinciaAslAssNome, ComuneAslAssCodice, ComuneAslAssNome, CodiceAslAss, DataInizioAss
			  , DataScadenzaAss
			  -- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT dbo.GetPazientiDataDecesso(Id) IS NULL THEN dbo.GetPazientiDataDecesso(Id) ELSE DataTerminazioneAss END AS DataTerminazioneAss
			  , DistrettoAmm, DistrettoTer, Ambito
			  , CodiceMedicoDiBase, CodiceFiscaleMedicoDiBase, CognomeNomeMedicoDiBase
			  , DistrettoMedicoDiBase, DataSceltaMedicoDiBase, ComuneRecapitoCodice, ComuneRecapitoNome
			  , ProvinciaRecapitoCodice, ProvinciaRecapitoNome, IndirizzoRecapito, LocalitaRecapito
			  , Telefono1, Telefono2, Telefono3, CodiceSTP, DataInizioSTP, DataFineSTP, MotivoAnnulloSTP
			  , StatusCodice, StatusNome
			  --
			  -- Restituisco la DataDecesso (non eseguo test se attivo o fuso perchè questa SP restotuisce sempre e solo gli attivi)
			  --
			  , dbo.GetPazientiDataDecesso(Id) AS DataDecesso
			 --
			 -- Modifica Ettore 2016-07-18: se fuso restituisco il padre
			 -- Poichè questa restotuisce sempre e solo gli attivi restiotuisco sempre NULL
			 --
			 , CAST(NULL AS UNIQUEIDENTIFIER) AS IdPazienteAttivo
		FROM 
			dbo.PazientiDettaglioResult AS PDR
		WHERE 
			StatusCodice = 0 --solo gli attivi
			AND ((Id = @Id) OR (@Id IS NULL))
			AND ((Cognome Like @Cognome + '%') OR (@Cognome IS NULL))
			AND ((Nome Like @Nome + '%') OR (@Nome IS NULL))
			AND ((DataNascita = @DataNascita) OR (@DataNascita IS NULL))
			AND ((CodiceFiscale = @CodiceFiscale) OR (@CodiceFiscale IS NULL))
			AND ((Sesso = @Sesso) OR (@Sesso IS NULL))
			AND  EXISTS(
				SELECT * 
				FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
				WHERE TAB.Provenienza = PDR.Provenienza
				)

		ORDER BY 	
				CASE 
					WHEN @SortOrder = 1 THEN Cognome
					WHEN @SortOrder = 2 THEN Nome
					WHEN @SortOrder = 3 THEN CONVERT(VARCHAR(20), DataNascita  , 120) --deve essere una stringa
					WHEN @SortOrder = 4 THEN CodiceFiscale
					WHEN @SortOrder = 5 THEN Sesso
					ELSE Cognome 
				END
				--- 2016-07-11 Ordinamento siu più campi
				,
				CASE 
					WHEN @SortOrder = 0 THEN Nome
				END
				,
				CASE 
					WHEN @SortOrder = 0 THEN DataModifica
				END

	END
END





GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsCercaDettagliByGeneralita] TO [DataAccessWs]
    AS [dbo];

