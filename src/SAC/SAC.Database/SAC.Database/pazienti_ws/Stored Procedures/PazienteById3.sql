





-- =============================================
-- Author:		ETTORE
-- Create date: 2020-05-07 (derivata da versione precedente creata il 2016-10-26)
-- Description:	Ottiene un record completo di PazientiDettaglio
-- Modify Date: SimoneB - 2019-06-26 - Restituito anche il campo Attributi 
-- Modify date: 2020-05-07 - ETTORE: ComuneAslResCodice e ComuneAslAssCodice non vengono più usati (assieme ai campi per il lookup del nome)
-- =============================================
CREATE PROCEDURE [pazienti_ws].[PazienteById3]
(
   @Identity varchar(64)
  ,@Id uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Controllo accesso
	--
	IF dbo.LeggePazientiPermessiLettura(@Identity) = 0
	BEGIN
		EXEC PazientiEventiAccessoNegato @Identity, 0, 'PazienteById', 'Utente non ha i permessi di lettura!'

		RAISERROR('Errore di controllo accessi durante PazienteById!', 16, 1)
		RETURN
	END

	DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER	
	DECLARE @DataDecesso AS DATETIME
	DECLARE @IdPaziente UNIQUEIDENTIFIER
	DECLARE @StatusCodice TINYINT
	
	SELECT TOP 1 
		@IdPaziente = Id
		, @StatusCodice = StatusCodice
	FROM [pazienti_ws].PazientiDettaglio
	WHERE Id = @Id

	IF (@IdPaziente IS NOT NULL) 
	BEGIN 
		IF @StatusCodice = 2
		BEGIN
			SELECT TOP 1 @IdPazienteAttivo = IdPaziente 
			FROM dbo.PazientiFusioni 
			WHERE IdPazienteFuso = @IdPaziente AND Abilitato = 1
			
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@IdPazienteAttivo)
		END 
	ELSE
		IF @StatusCodice = 0
			SELECT @Datadecesso = dbo.GetPazientiDataDecesso(@Id)
		--Se CANCELLATO cioè Disattivato=3 @DataDecesso rimane NULL
	END 
	
	SELECT
		Id, Provenienza, IdProvenienza, LivelloAttendibilita, DataInserimento
		, DataModifica, Tessera, Cognome, Nome, DataNascita, Sesso
		, ComuneNascitaCodice, ComuneNascitaNome, ProvinciaNascitaCodice, ProvinciaNascitaNome
		, NazionalitaCodice, NazionalitaNome, CodiceFiscale, DatiAnamnestici
		, MantenimentoPediatra, CapoFamiglia, Indigenza
		
		, CASE WHEN NOT @DataDecesso IS NULL THEN '4' ELSE CodiceTerminazione END AS CodiceTerminazione
		, CASE WHEN NOT @DataDecesso IS NULL THEN 'DECESSO' ELSE DescrizioneTerminazione END AS DescrizioneTerminazione

		, ComuneResCodice, ComuneResNome, ProvinciaResCodice, ProvinciaResNome, SubComuneRes
		, IndirizzoRes, LocalitaRes, CapRes, DataDecorrenzaRes
		, CodiceAslRes, RegioneResCodice, RegioneResNome
		, ComuneDomCodice, ComuneDomNome, ProvinciaDomCodice, ProvinciaDomNome, SubComuneDom, IndirizzoDom
		, LocalitaDom, CapDom, PosizioneAss, RegioneAssCodice, RegioneAssNome
		, CodiceAslAss, DataInizioAss
		, DataScadenzaAss

		, CASE 
			WHEN NOT @DataDecesso IS NULL THEN @DataDecesso 
			ELSE DataTerminazioneAss 
		  END AS DataTerminazioneAss
		
		, DistrettoAmm, DistrettoTer, Ambito
		, CodiceMedicoDiBase, CodiceFiscaleMedicoDiBase, CognomeNomeMedicoDiBase
		, DistrettoMedicoDiBase, DataSceltaMedicoDiBase, ComuneRecapitoCodice, ComuneRecapitoNome
		, ProvinciaRecapitoCodice, ProvinciaRecapitoNome, IndirizzoRecapito, LocalitaRecapito
		, Telefono1, Telefono2, Telefono3, CodiceSTP, DataInizioSTP, DataFineSTP, MotivoAnnulloSTP
		, StatusCodice, StatusNome
		--
		-- Restituisco la DataDecesso: 
		--		se attivo restituisco la data associata alla catena
		--		altrimenti il dato sul record
		--
		, CASE 
			WHEN StatusCodice = 0 THEN 
				@DataDecesso --ATTIVO
			WHEN StatusCodice <> 0 AND CodiceTerminazione = '4' THEN
				DataTerminazioneAss	--La data decesso sul record
			ELSE
				CAST(NULL AS DATETIME)
		  END AS DataDecesso
		 --
		 -- SE FUSO RESTITUISCO IL PADRE
		 --
		 , CASE 
			WHEN StatusCodice = 2 THEN @IdPazienteAttivo
			ELSE CAST(NULL AS UNIQUEIDENTIFIER)
		   END AS IdPazienteAttivo
		 , Attributi

	FROM 
		[pazienti_ws].PazientiDettaglio
	WHERE
		Id = @Id
END