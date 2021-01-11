CREATE PROCEDURE [dbo].[ConsensiWsAggancioPazienteByCognomeNomeCodiceFiscale]
(
	@Identity VARCHAR(64)
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @CodiceFiscale varchar(16)
) AS
BEGIN
/*
	CREATA DA ETTORE 2014-10-29: 
		questa SP è stata creata per rendere meno lasca la ricerca del paziente per agganciare il consenso
		Ha un utilizzo temporaneo perchè l'aggancio con il consenso dovrà essere fatto solo per Provenienza, IdProvenienza del paziente

	MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
*/
	DECLARE @IdPaziente uniqueidentifier	--il paziente trovato
	DECLARE @Disattivato int				--0=Attivo, 1=Cancellato, 2=Fuso
	DECLARE @IdPadre uniqueidentifier
	--DECLARE @DateStart as datetime
	--DECLARE @DateEnd as datetime
	SET NOCOUNT ON;
	--
	-- Inizializzo 
	--
	--SET @DateStart = GETDATE()
	
	BEGIN TRY
		--	
		-- Controllo accesso
		--
		IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
		BEGIN
			EXEC PazientiEventiAccessoNegato @Identity, 0, 'ConsensiWsAggancioPazienteByCognomeNomeCodiceFiscale', 'Utente non ha i permessi di lettura!'
			RAISERROR('Errore di controllo accessi durante ConsensiWsAggancioPazienteByCognomeNomeCodiceFiscale!', 16, 1)
			RETURN
		END		

		IF @CodiceFiscale = ''
			SET @CodiceFiscale = NULL
		--
		-- @Cognome = '' è permesso nel match nel DWH, quindi non lo metto a NULL
		-- @Nome = '' è permesso nel match nel DWH, quindi non lo metto a NULL
		--
		--
		-- 1) Ricerca per Cognome, Nome, CodiceFiscale
		-- 
		SELECT TOP 1 
			@IdPaziente = Id 
			, @Disattivato = Disattivato
		FROM Pazienti
		WHERE 
			Cognome = @Cognome 
			AND Nome = @Nome 
			AND (CodiceFiscale = @CodiceFiscale AND @CodiceFiscale <> '0000000000000000')
			AND Disattivato IN (0,2) --solo attivi o fusi				
		ORDER BY LivelloAttendibilita desc , Disattivato
		--
		-- Se @IdPaziente IS NULL non ho trovato la posizione anagrafica
		-- Se ho trovato la posizione anagrafica devo assicurarmi di restituire la posizione attiva
		--
		IF NOT @IdPaziente IS NULL
		BEGIN 
			IF @Disattivato = 2
			BEGIN
				--
				-- Cerco il padre della posizione con Id=@IdPaziente
				--
				SET @IdPadre = NULL
				SELECT TOP 1 @IdPadre = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
				IF NOT @IdPadre IS NULL
				BEGIN
					SET @IdPaziente = @IdPadre
				END
			END
		END
		--
		-- MODIFICA ETTORE 2016-10-27: A questo punto idPaziente è sempre il paziente attivo
		--
		DECLARE @Datadecesso DATETIME 
		IF NOT @IdPaziente IS NULL
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)
		--
		-- Eseguo la query per restituire i dati
		--
		SELECT  Id, Provenienza, IdProvenienza, LivelloAttendibilita, DataInserimento
			  , DataModifica, Tessera, Cognome, Nome, DataNascita, Sesso
			  , ComuneNascitaCodice, ComuneNascitaNome, ProvinciaNascitaCodice, ProvinciaNascitaNome
			  , NazionalitaCodice, NazionalitaNome, CodiceFiscale, DatiAnamnestici
			  , MantenimentoPediatra, CapoFamiglia, Indigenza
			  -- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT @Datadecesso IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
			  , CASE WHEN NOT @Datadecesso IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione
			  , ComuneResCodice, ComuneResNome, ProvinciaResCodice, ProvinciaResNome, SubComuneRes
			  , IndirizzoRes, LocalitaRes, CapRes, DataDecorrenzaRes, ProvinciaAslResCodice, ProvinciaAslResNome
			  , ComuneAslResCodice, ComuneAslResNome, CodiceAslRes, RegioneResCodice, RegioneResNome
			  , ComuneDomCodice, ComuneDomNome, ProvinciaDomCodice, ProvinciaDomNome, SubComuneDom, IndirizzoDom
			  , LocalitaDom, CapDom, PosizioneAss, RegioneAssCodice, RegioneAssNome, ProvinciaAslAssCodice
			  , ProvinciaAslAssNome, ComuneAslAssCodice, ComuneAslAssNome, CodiceAslAss, DataInizioAss
			  , DataScadenzaAss
			  -- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
			  , CASE WHEN NOT @Datadecesso IS NULL THEN @Datadecesso ELSE DataTerminazioneAss END AS DataTerminazioneAss
			  , DistrettoAmm, DistrettoTer, Ambito
			  , CodiceMedicoDiBase, CodiceFiscaleMedicoDiBase, CognomeNomeMedicoDiBase
			  , DistrettoMedicoDiBase, DataSceltaMedicoDiBase, ComuneRecapitoCodice, ComuneRecapitoNome
			  , ProvinciaRecapitoCodice, ProvinciaRecapitoNome, IndirizzoRecapito, LocalitaRecapito
			  , Telefono1, Telefono2, Telefono3, CodiceSTP, DataInizioSTP, DataFineSTP, MotivoAnnulloSTP
			  , StatusCodice, StatusNome
		  FROM dbo.PazientiDettaglioResult
		  WHERE Id = @IdPaziente
		
		--SET @DateEnd = GETDATE()
		--PRINT 'Durata esecuzione (ms): ' + CAST(DATEDIFF(ms, @DateStart, @dateEnd) AS VARCHAR(10))
	
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage varchar(2560)
		SELECT @ErrorMessage = 'ConsensiWsAggancioPazienteByCognomeNomeCodiceFiscale' + 
			' ErrorNumber: ' + CONVERT(varchar(8), ERROR_NUMBER()) +
			', Severity: ' + CONVERT(varchar(8), ERROR_SEVERITY()) +
			', State: ' + CONVERT(varchar(8), ERROR_STATE()) + 
			', Procedure: ' + ISNULL(ERROR_PROCEDURE(), '-') + 
			', Line: ' + CONVERT(varchar(8), ERROR_LINE()) +
			', Message: ' + ISNULL(ERROR_MESSAGE(), '-')
		RAISERROR(@ErrorMessage, 16, 1)
	END CATCH
	
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ConsensiWsAggancioPazienteByCognomeNomeCodiceFiscale] TO [DataAccessWs]
    AS [dbo];

