
-- =============================================
-- Author:		...
-- Create date: ...
-- Modify sate: 2016-05-26 Rimosso controllo accesso di lettura
-- Modify date ETTORE: 2016-10-28 : Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
--							 Restituito il campo StatusNome invece che rifare il CASE basato su StatusCodice
-- Description:	
--	  Ritorna lo stesso schema della PazientiOutputByIdProvenienza2 con la differenza
--	  che gli attributi RegioneResCodice e RegioneAssCodice sono un varchar(2)
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputByIdProvenienza]
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)

AS
BEGIN
	SET NOCOUNT ON;

	IF @Provenienza IS NULL
	BEGIN
		RAISERROR('Il parametro Provenienza non può essere NULL!', 16, 1)
		RETURN
	END

	IF @IdProvenienza IS NULL
	BEGIN
		RAISERROR('Il parametro IdProvenienza non può essere NULL!', 16, 1)
		RETURN
	END


	DECLARE @DataDecesso AS DATETIME
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @Disattivato TINYINT
	
	SELECT TOP 1 
		@IdPaziente = Id
		, @Disattivato = Disattivato
	FROM Pazienti
	WHERE
		(Provenienza = @Provenienza	AND IdProvenienza = @IdProvenienza)
		OR
		( Pazienti.Id IN (
			SELECT PazientiSinonimi.IdPaziente
			FROM         
				PazientiSinonimi
			WHERE
				PazientiSinonimi.Provenienza = @Provenienza
				AND PazientiSinonimi.IdProvenienza = @IdProvenienza
				)
		)
	--
	-- Verifico se l'anagrafica identificata da @IdPaziente è Attiva o Fusa. Se Fusa devo calcolare il padre della fusione per trovare la data di decesso sulla catena
	--
	IF (NOT @IdPaziente IS NULL) 
	BEGIN 
		IF @Disattivato = 2
		BEGIN
			DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER	
			SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPazienteAttivo)
		END 
		ELSE 
		IF @Disattivato = 0
		BEGIN
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPaziente)
		END 
		--Se l'anagrafica è CANCELLATA @DataDecesso rimane NULL
	END 

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT
		  Id
		, Provenienza
		, IdProvenienza
		, DataInserimento
		, DataModifica

		, Tessera
		, Cognome
		, Nome
		, DataNascita
		, Sesso
		, ComuneNascitaCodice
		, dbo.LookupIstatComuni(ComuneNascitaCodice) AS ComuneNascitaNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneNascitaCodice) AS ProvinciaNascitaCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneNascitaCodice)) AS ProvinciaNascitaNome
		, NazionalitaCodice
		, dbo.LookupIstatNazioni(NazionalitaCodice) AS NazionalitaNome
		, CodiceFiscale

		, NULL AS DatiAnamnestici
		, ISNULL(MantenimentoPediatra, 0) AS MantenimentoPediatra
		, ISNULL(CapoFamiglia, 0) AS CapoFamiglia
		, ISNULL(Indigenza, 0) AS Indigenza

		-- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
		, CASE WHEN NOT @DataDecesso IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
		, CASE WHEN NOT @DataDecesso IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione

		, ComuneResCodice
		, dbo.LookupIstatComuni(ComuneResCodice) AS ComuneResNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneResCodice) AS ProvinciaResCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneResCodice)) AS ProvinciaResNome
		, SubComuneRes
		, IndirizzoRes
		, LocalitaRes
		, CapRes
		, DataDecorrenzaRes
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslResCodice) AS ProvinciaAslResCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslResCodice)) AS ProvinciaAslResNome
		, ComuneAslResCodice
		, dbo.LookupIstatComuni(ComuneAslResCodice) AS ComuneAslResNome
		, CodiceAslRes --dbo.LookupIstatAslCodiceEsteso(CodiceAslRes, ComuneAslResCodice) AS CodiceAslRes
		, CAST(NULL AS VARCHAR(2)) AS 'RegioneResCodice'
		, dbo.LookupIstatRegioni(RegioneResCodice) AS RegioneResNome

		, ComuneDomCodice
		, dbo.LookupIstatComuni(ComuneDomCodice) AS ComuneDomNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneDomCodice) AS ProvinciaDomCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneDomCodice)) AS ProvinciaDomNome
		, SubComuneDom
		, IndirizzoDom
		, LocalitaDom
		, CapDom

		, PosizioneAss
		, CAST(NULL AS VARCHAR(2)) AS 'RegioneAssCodice'
		, dbo.LookupIstatRegioni(RegioneAssCodice) AS RegioneAssNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslAssCodice) AS ProvinciaAslAssCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneAslAssCodice)) AS ProvinciaAslAssNome
		, ComuneAslAssCodice
		, dbo.LookupIstatComuni(ComuneAslAssCodice) AS ComuneAslAssNome
		, CodiceAslAss --dbo.LookupIstatAslCodiceEsteso(CodiceAslAss, ComuneAslAssCodice) AS CodiceAslAss
		, DataInizioAss
		, DataScadenzaAss

		-- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
		, CASE WHEN NOT @DataDecesso IS NULL THEN @DataDecesso ELSE DataTerminazioneAss END AS DataTerminazioneAss

		, DistrettoAmm
		, DistrettoTer
		, Ambito

		, CodiceMedicoDiBase
		, CodiceFiscaleMedicoDiBase
		, CognomeNomeMedicoDiBase
		, DistrettoMedicoDiBase
		, DataSceltaMedicoDiBase

		, ComuneRecapitoCodice
		, dbo.LookupIstatComuni(ComuneRecapitoCodice) AS ComuneRecapitoNome
		, dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneRecapitoCodice) AS ProvinciaRecapitoCodice
		, dbo.LookupIstatProvince(dbo.GetIstatCodiceProvinciaByCodiceComune(ComuneRecapitoCodice)) AS ProvinciaRecapitoNome
		, IndirizzoRecapito
		, LocalitaRecapito
		, Telefono1
		, Telefono2
		, Telefono3
		
		, CodiceSTP
		, DataInizioSTP
		, DataFineSTP
		, MotivoAnnulloSTP		

		, StatusCodice
		, StatusNome

	FROM 
		PazientiDettaglioResult
	WHERE
		(	Provenienza = @Provenienza
		AND IdProvenienza = @IdProvenienza)
	OR
		( PazientiDettaglioResult.Id IN (
							SELECT PazientiSinonimi.IdPaziente
							FROM         
								PazientiSinonimi
							WHERE
									PazientiSinonimi.Provenienza = @Provenienza
								AND PazientiSinonimi.IdProvenienza = @IdProvenienza
										)
		)
	ORDER BY
		StatusCodice

END







GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputByIdProvenienza] TO [DataAccessSql]
    AS [dbo];

