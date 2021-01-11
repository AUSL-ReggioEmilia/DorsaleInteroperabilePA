


CREATE PROCEDURE [dbo].[PazientiWsByIdProvenienza]
(
	@Identity varchar(64),
	@Provenienza varchar(16),
	@IdProvenienza varchar(64)
)
AS
BEGIN
/*
	MODIFICA ETTORE 2014-07-07:
		Tolto SELECT * FROM PazientiAttiviResult e aggiunto SELECT con nomi dei campi
		Aggiunto DataDecesso
	MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
*/
	SET NOCOUNT ON;

	---------------------------------------------------
	-- Controllo accesso
	---------------------------------------------------

	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiCercaByIdProvenienza', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiCercaByIdProvenienza!', 16, 1)
		RETURN
	END

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT 
		Id, Provenienza, IdProvenienza, DataInserimento, DataModifica
		, Tessera, Cognome, Nome, DataNascita, Sesso
		, ComuneNascitaCodice, ComuneNascitaNome, ProvinciaNascitaCodice, ProvinciaNascitaNome, NazionalitaCodice, NazionalitaNome
		, CodiceFiscale, DatiAnamnestici, MantenimentoPediatra, CapoFamiglia, Indigenza
		-- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
		, CASE WHEN NOT DataDecesso IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
		, CASE WHEN NOT DataDecesso IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione
		, ComuneResCodice, ComuneResNome, ProvinciaResCodice, ProvinciaResNome, SubComuneRes
		, IndirizzoRes, LocalitaRes, CapRes, DataDecorrenzaRes, ProvinciaAslResCodice, ProvinciaAslResNome
		, ComuneAslResCodice, ComuneAslResNome, CodiceAslRes, RegioneResCodice, RegioneResNome
		, ComuneDomCodice, ComuneDomNome, ProvinciaDomCodice, ProvinciaDomNome, SubComuneDom
		, IndirizzoDom, LocalitaDom, CapDom, PosizioneAss, RegioneAssCodice, RegioneAssNome
		, ProvinciaAslAssCodice, ProvinciaAslAssNome, ComuneAslAssCodice, ComuneAslAssNome
		, CodiceAslAss, DataInizioAss, DataScadenzaAss
		-- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
		, CASE WHEN NOT DataDecesso IS NULL THEN DataDecesso ELSE DataTerminazioneAss END AS DataTerminazioneAss
		, DistrettoAmm, DistrettoTer, Ambito
		, CodiceMedicoDiBase, CodiceFiscaleMedicoDiBase, CognomeNomeMedicoDiBase, DistrettoMedicoDiBase, DataSceltaMedicoDiBase
		, ComuneRecapitoCodice, ComuneRecapitoNome, ProvinciaRecapitoCodice, ProvinciaRecapitoNome, IndirizzoRecapito, LocalitaRecapito
		, Telefono1, Telefono2, Telefono3, CodiceSTP, DataInizioSTP, DataFineSTP, MotivoAnnulloSTP
		, DataDecesso
	FROM 
		dbo.PazientiAttiviResult
	WHERE
		(	Provenienza = @Provenienza
		AND IdProvenienza = @IdProvenienza)
	OR
		( PazientiAttiviResult.Id IN (
							SELECT PazientiSinonimi.IdPaziente
							FROM         
								PazientiSinonimi
							WHERE
									PazientiSinonimi.Provenienza = @Provenienza
								AND PazientiSinonimi.IdProvenienza = @IdProvenienza
										)
		)
	
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsByIdProvenienza] TO [DataAccessWs]
    AS [dbo];

