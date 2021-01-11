-- =============================================
-- Author:		...
-- Create date: ...
-- Modify date: 2014-07-04 Eliminato la chiamata alla SP PazientiWsDettaglioById()
-- Modify date: 2016-05-26 Rimosso controllo accesso di lettura
-- Description:	
--				Aggiunto il medesimo codice della SP PazientiWsDettaglioById() e tolto il SELECT * FROM PazientiDettaglioResult
--				per bloccare l'output
-- Modify date ETTORE: 2016-10-28 : Calcolo CodiceTerminazione, DescrizioneTerminazione, DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
-- =============================================
CREATE PROCEDURE [dbo].[PazientiOutputById2]
	@Id uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;

	IF @Id IS NULL
	BEGIN
		RAISERROR('Il parametro Id non può essere NULL!', 16, 1)
		RETURN
	END

	DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER	
	DECLARE @DataDecesso AS DATETIME
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @Disattivato TINYINT
	
	SELECT TOP 1 
		@IdPaziente = Id
		, @Disattivato = Disattivato
	FROM Pazienti
	WHERE 
		Id = @Id
	IF (NOT @IdPaziente IS NULL) 
	BEGIN 
		IF @Disattivato = 2
		BEGIN
			SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @IdPaziente  AND Abilitato = 1
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPazienteAttivo)
		END 
		ELSE
		IF @Disattivato = 0
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@Id)
		--Se CANCELLATO cioè Disattivato=3 @DataDecesso rimane NULL
	END 

	---------------------------------------------------
	--  Ritorna i dati
	---------------------------------------------------
	SELECT 
		Id
		,Provenienza
		,IdProvenienza
		,LivelloAttendibilita
		,DataInserimento
		,DataModifica
		,Tessera
		,Cognome
		,Nome
		,DataNascita
		,Sesso
		,ComuneNascitaCodice
		,ComuneNascitaNome
		,ProvinciaNascitaCodice
		,ProvinciaNascitaNome
		,NazionalitaCodice
		,NazionalitaNome
		,CodiceFiscale
		,DatiAnamnestici
		,MantenimentoPediatra
		,CapoFamiglia
		,Indigenza

		-- MODIFICA ETTORE 2016-10-27: Calcolo CodiceTerminazione, DescrizioneTerminazione in base alla data decesso calcolata sulla catena di fusione
		, CASE WHEN NOT @DataDecesso IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
		, CASE WHEN NOT @DataDecesso IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione

		,ComuneResCodice
		,ComuneResNome
		,ProvinciaResCodice
		,ProvinciaResNome
		,SubComuneRes
		,IndirizzoRes
		,LocalitaRes
		,CapRes
		,DataDecorrenzaRes
		,ProvinciaAslResCodice
		,ProvinciaAslResNome
		,ComuneAslResCodice
		,ComuneAslResNome
		,CodiceAslRes
		,RegioneResCodice
		,RegioneResNome
		,ComuneDomCodice
		,ComuneDomNome
		,ProvinciaDomCodice
		,ProvinciaDomNome
		,SubComuneDom
		,IndirizzoDom
		,LocalitaDom
		,CapDom
		,PosizioneAss
		,RegioneAssCodice
		,RegioneAssNome
		,ProvinciaAslAssCodice
		,ProvinciaAslAssNome
		,ComuneAslAssCodice
		,ComuneAslAssNome
		,CodiceAslAss
		,DataInizioAss
		,DataScadenzaAss
		
		-- MODIFICA ETTORE 2016-10-27: Calcolo DataTerminazioneAss in base alla data decesso calcolata sulla catena di fusione
		, CASE WHEN NOT @DataDecesso IS NULL THEN @DataDecesso ELSE DataTerminazioneAss END AS DataTerminazioneAss

		,DistrettoAmm
		,DistrettoTer
		,Ambito
		,CodiceMedicoDiBase
		,CodiceFiscaleMedicoDiBase
		,CognomeNomeMedicoDiBase
		,DistrettoMedicoDiBase
		,DataSceltaMedicoDiBase
		,ComuneRecapitoCodice
		,ComuneRecapitoNome
		,ProvinciaRecapitoCodice
		,ProvinciaRecapitoNome
		,IndirizzoRecapito
		,LocalitaRecapito
		,Telefono1
		,Telefono2
		,Telefono3
		,CodiceSTP
		,DataInizioSTP
		,DataFineSTP
		,MotivoAnnulloSTP
		,StatusCodice
		,StatusNome
	FROM 
		dbo.PazientiDettaglioResult
	WHERE
		Id = @Id
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiOutputById2] TO [DataAccessSql]
    AS [dbo];

