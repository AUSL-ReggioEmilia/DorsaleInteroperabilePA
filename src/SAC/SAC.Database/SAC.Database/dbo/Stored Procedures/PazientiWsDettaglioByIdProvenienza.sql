
-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2013-02-15: Ettore
--				per gestire [Provenienza, IdProvenienza]=[SAC, IdSac] Restituisce sempre la posizione attiva
-- Modify date: 2014-07-07: Ettore
--				1) Uso la nuova funzione dbo.GetPazienteByProvenienzaIdProvenienza() che implementa la stessa logica che implementava
--					questa stored procedure (la PazientiWsDettaglioByIdProvenienza).
--				Bloccato output, tolto SELECT * FROM PazientiDettaglioResult
--				I parametri @Provenienza, @IdProvenienza possono riferirsi ad una anagrafica sia attiva che fusa: 
--				se l'anagrafica è attiva restituisco DataDecesso associata alla catena
--				se l'anagrafica non è attiva restituisco la data di decesso sul record
--				In realtà la funzione dbo.GetPazienteByProvenienzaIdProvenienza() per come è stata implementata restituisce sempre una anagrafica attiva.
-- Modify date: 2016-07-18: Ettore - Se fuso restituisco il padre nel campo IdPazienteAttivo
-- Modify date: 2016-10-27: Sovrascrivo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss se è valorizzata dataDecesso calcolata sulla catena, anche se l'anagrafica è fusa
-- Description:	Restituisce i dati di testata del paziente
-- =============================================
CREATE PROCEDURE [dbo].[PazientiWsDettaglioByIdProvenienza]
(
	@Identity varchar(64),
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Controllo accesso
	--
	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiWsDettaglioByIdProvenienza', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiWsDettaglioByIdProvenienza!', 16, 1)
		RETURN
	END
	
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	--
	-- MODIFICA ETTORE 2014-07-07
	-- Ricavo l'IdPaziente secondo le logiche prima implementate dalla SP PazientiWsDettaglioByIdProveneinza() ora implementate nella funzione
	-- dbo.GetPazienteByProvenienzaIdProvenienza()
	-- Questo @IdPaziente può essere sia attivo che fuso
	-- 
	SELECT @IdPaziente = dbo.GetPazienteByProvenienzaIdProvenienza(@Provenienza, @IdProvenienza)

	DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER	
	DECLARE @DataDecesso AS DATETIME
	DECLARE @Disattivato TINYINT
	SELECT TOP 1 
		@Disattivato = Disattivato
	FROM Pazienti
	WHERE 
		Id = @IdPaziente
		AND Disattivato IN (0,2) --solo attivi o fusi
	--
	-- Verifico se l'anagrafica identificata da @IdPaziente è Attiva o Fusa. Se Fusa devo calcolare il padre della fusione per trovare la data di decesso sulla catena
	--
	IF (NOT @IdPaziente IS NULL) 
	BEGIN 
		IF @Disattivato = 2
		BEGIN
			SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPazienteAttivo)
		END 
		ELSE
		BEGIN
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)
		END 
	END 

	--
	-- Restituisco il record del paziente
	-- MODIFICA ETTORE 2014-07-07: bloccato output	
	--		
	SELECT
		Id, Provenienza, IdProvenienza, LivelloAttendibilita, DataInserimento
		, DataModifica, Tessera, Cognome, Nome, DataNascita, Sesso
		, ComuneNascitaCodice, ComuneNascitaNome, ProvinciaNascitaCodice, ProvinciaNascitaNome
		, NazionalitaCodice, NazionalitaNome, CodiceFiscale, DatiAnamnestici
		, MantenimentoPediatra, CapoFamiglia, Indigenza
		-- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
		, CASE WHEN NOT @DataDecesso IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
		, CASE WHEN NOT @DataDecesso IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione
		, ComuneResCodice, ComuneResNome, ProvinciaResCodice, ProvinciaResNome, SubComuneRes
		, IndirizzoRes, LocalitaRes, CapRes, DataDecorrenzaRes, ProvinciaAslResCodice, ProvinciaAslResNome
		, ComuneAslResCodice, ComuneAslResNome, CodiceAslRes, RegioneResCodice, RegioneResNome
		, ComuneDomCodice, ComuneDomNome, ProvinciaDomCodice, ProvinciaDomNome, SubComuneDom, IndirizzoDom
		, LocalitaDom, CapDom, PosizioneAss, RegioneAssCodice, RegioneAssNome, ProvinciaAslAssCodice
		, ProvinciaAslAssNome, ComuneAslAssCodice, ComuneAslAssNome, CodiceAslAss, DataInizioAss
		, DataScadenzaAss
		-- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
		, CASE WHEN NOT @DataDecesso IS NULL THEN @DataDecesso ELSE DataTerminazioneAss END AS DataTerminazioneAss
		, DistrettoAmm, DistrettoTer, Ambito
		, CodiceMedicoDiBase, CodiceFiscaleMedicoDiBase, CognomeNomeMedicoDiBase
		, DistrettoMedicoDiBase, DataSceltaMedicoDiBase, ComuneRecapitoCodice, ComuneRecapitoNome
		, ProvinciaRecapitoCodice, ProvinciaRecapitoNome, IndirizzoRecapito, LocalitaRecapito
		, Telefono1, Telefono2, Telefono3, CodiceSTP, DataInizioSTP, DataFineSTP, MotivoAnnulloSTP
		, StatusCodice, StatusNome
		--
		-- MODIFICA ETTORE 2014-07-07
		-- Restituisco la DataDecesso: 
		--		se attivo restituisco la data associata alla catena
		--		altrimenti il dato sul record
		--
		, CASE WHEN @Disattivato = 0 THEN --ATTIVO
			@Datadecesso
		 WHEN @Disattivato <> 0 AND CodiceTerminazione = '4' THEN
			DataTerminazioneAss		--La data decesso sul record
		 ELSE 
			CAST(NULL AS DATETIME) 
		 END AS DataDecesso
		 --
		 -- Modifica Ettore 2016-07-18: se fuso restituisco il padre
		 --
		 , CASE WHEN @Disattivato = 2 THEN 
				@IdPazienteAttivo
		 ELSE
			CAST(NULL AS UNIQUEIDENTIFIER)
		 END AS IdPazienteAttivo

	FROM 
		dbo.PazientiDettaglioResult
	WHERE 
		Id = @Idpaziente

END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsDettaglioByIdProvenienza] TO [DataAccessWs]
    AS [dbo];

