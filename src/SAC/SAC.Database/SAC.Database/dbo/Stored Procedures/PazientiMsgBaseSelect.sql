


-- =============================================
-- Author:		?
-- Create date: ?
-- Description:	Eseguita per restituire il dettaglio paziente
-- MODIFICA ETTORE 2016-10-27: quando costruisco la risposta del paziente a prescindere se è attivo o fuso aggiorno sempre
-- 							CodiceTerminazione=4, DescrizioneTerminazione=DECESSO e DataTerminazioneAss=dbo.GetPazientiDataDecesso(@IdPazienteAttivo)
--  						se dbo.GetPazientiDataDecesso(@IdPazienteAttivo) è valorizzata
-- Modify date: 2018-08-02 - ETTORE: aggiunto il campo Attributi e DataDecesso
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgBaseSelect]
	@Id AS uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- Prendo l'Id Attivo associato all' anagrafica con Id=@Id  e calcolo comunque le informazioni di decesso sulla catena
	--  
	DECLARE @IdPazienteAttivo AS UNIQUEIDENTIFIER 
	SELECT TOP 1 @IdPazienteAttivo = IdPaziente FROM PazientiFusioni WHERE IdPazienteFuso = @Id AND Abilitato = 1
	--
	-- Se @IdPazienteAttivo è NULL allora @Id è ATTIVO
	--
	IF @IdPazienteAttivo IS NULL
		SET @IdPazienteAttivo = @Id

	--
	-- Calcolo la datadecesso derivata dalla catena di fusione
	-- Associerò i dati di decesso anche se @Id si riferisce ad un figlio
	--
	DECLARE @DataDecessoCatena as DATETIME
	SELECT @DataDecessoCatena = dbo.GetPazientiDataDecesso(@IdPazienteAttivo)
	
	SELECT 
		Id, 
		Provenienza, 
		IdProvenienza,
		DataInserimento, 
		DataModifica,
		DataSequenza, 
		LivelloAttendibilita, 
		Ts,
		Tessera, 
		Cognome, 
		Nome, 
		DataNascita, 
		Sesso, 
		ComuneNascitaCodice, 
		dbo.LookupIstatComuni(ComuneNascitaCodice) AS ComuneNascitaNome,
		NazionalitaCodice, 
		dbo.LookupIstatNazioni(NazionalitaCodice) AS NazionalitaNome,
		dbo.LookupIstatComuni(ComuneResCodice) AS ComuneResNome,
		CodiceFiscale,
		CONVERT(varchar, DatiAnamnestici) AS DatiAnamnestici,
		MantenimentoPediatra, 
		CapoFamiglia,	
		Indigenza, 
		--
		-- Calcolo CodiceTerminazione in base alla data di decesso sulla catena di fusione 
		--
		CASE WHEN (NOT @DataDecessoCatena IS NULL) THEN 
			CAST('4' AS VARCHAR(8))
		ELSE
			CodiceTerminazione
		END AS CodiceTerminazione,
		--
		-- Calcolo DescrizioneTerminazione in base alla data di decesso sulla catena di fusione 
		--
		CASE WHEN (NOT @DataDecessoCatena IS NULL) THEN 
			CAST('DECESSO' AS VARCHAR(64))
		ELSE
			DescrizioneTerminazione
		END AS DescrizioneTerminazione,
		ComuneResCodice, 
		SubComuneRes, 
		IndirizzoRes, 
		LocalitaRes, 
		CapRes, 
		DataDecorrenzaRes, 
		ComuneAslResCodice, 
		CodiceAslRes,
		dbo.LookupIstatAsl(CodiceAslRes, ComuneAslResCodice) AS AslResNome,
		RegioneResCodice,
		dbo.LookupIstatRegioni(RegioneResCodice) AS RegioneResNome ,
		ComuneDomCodice, 
		dbo.LookupIstatComuni(ComuneDomCodice) AS ComuneDomNome,
		SubComuneDom, 
		IndirizzoDom, 
		LocalitaDom, 
		CapDom, 
		PosizioneAss, 
		RegioneAssCodice, 
		dbo.LookupIstatRegioni(RegioneAssCodice) AS RegioneAssNome,
		ComuneAslAssCodice, 
		CodiceAslAss,
		dbo.LookupIstatAsl(CodiceAslAss, ComuneAslAssCodice) AS AslAssNome,
		DataInizioAss, 
		DataScadenzaAss, 
		--
		-- Calcolo DataTerminazioneAss in base alla data di decesso sulla catena di fusione 
		--
		CASE WHEN (NOT @DataDecessoCatena IS NULL) THEN 
			@DataDecessoCatena
		ELSE
			DataTerminazioneAss
		END AS DataTerminazioneAss,
		DistrettoAmm, 
		DistrettoTer,
		Ambito, 
		CodiceMedicoDiBase, 
		CodiceFiscaleMedicoDiBase, 
		CognomeNomeMedicoDiBase,
		DistrettoMedicoDiBase, 
		DataSceltaMedicoDiBase, 
		ComuneRecapitoCodice, 
		dbo.LookupIstatComuni(ComuneRecapitoCodice) AS ComuneRecapitoNome,
		IndirizzoRecapito, 
		LocalitaRecapito,
		Telefono1, 
		Telefono2, 
		Telefono3,
		CodiceSTP, 
		DataInizioSTP, 
		DataFineSTP, 
		MotivoAnnulloSTP,
		-- Modify date: 2018-08-02 - ETTORE: aggiunto il campo Attributi e DataDecesso
		@DataDecessoCatena AS DataDecesso,
		Attributi
	FROM 
		PazientiMsgBaseResult
	WHERE 
		Id = @Id

END



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgBaseSelect] TO [DataAccessDll]
    AS [dbo];

