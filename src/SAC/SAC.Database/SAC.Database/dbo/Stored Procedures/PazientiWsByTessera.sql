




-- =============================================
-- Author:		
-- Create date: 
-- MODIFICA ETTORE 2014-07-07: Tolto SELECT * FROM PazientiAttiviResult e aggiunto SELECT con nomi dei campi
--								Aggiunto DataDecesso
-- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
-- Modify date: 2020-01-31: Ettore - Esclusione delle anagrafiche con Provenienza NON ricercabile [ASMN 7700]
-- Description:	Restiruisce lista pazienti ricercati per tessera 
-- =============================================
CREATE PROCEDURE dbo.PazientiWsByTessera
(
	@Identity varchar(64),
	@Tessera varchar(16)
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
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazientiCercaByTessera', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazientiCercaByTessera!', 16, 1)
		RETURN
	END
	--
	-- Ricavo la provenienza dell'utente corrente
	--
	SET @ProvenienzaCorrente = dbo.LeggePazientiProvenienza(@Identity)

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------

	SELECT TOP 100
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
		Tessera = @Tessera
		AND  EXISTS(
			SELECT * 
			FROM dbo.OttieneProvenienzeRicercabiliWs(@ProvenienzaCorrente) AS TAB 
			WHERE TAB.Provenienza = PazientiAttiviResult.Provenienza
			)
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiWsByTessera] TO [DataAccessWs]
    AS [dbo];

