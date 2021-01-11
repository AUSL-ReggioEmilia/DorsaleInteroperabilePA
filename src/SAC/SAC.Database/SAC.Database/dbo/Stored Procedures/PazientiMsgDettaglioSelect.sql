

-- =============================================
-- Author:		ETTORE
-- Create date: 2018-09-10
-- Description:	Utilizzata, in particolare, per popolare il nodo FUSIONE del messaggio di OUTPUT della DAE WCF
--
-- LA SP deve agire come la SP [dbo].[PazientiWsDettaglioById] utilizzata dal metodo WS2.PazienteDettaglio2ById
-- che veniva usato da BizTalk per popolare il nodo fusione del messaggio di output versione 2.
-- Ora è la DAE WCF che popola il nodo FUSIONE e deve quindi eseguire una SP analoga alla [dbo].[PazientiWsDettaglioById]
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgDettaglioSelect]
(
	@Id AS uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IdPazienteAttivo AS UNIQUEIDENTIFIER 
	DECLARE @DataDecessoCatena as DATETIME
	--
	-- Prendo l'Id Attivo associato all' anagrafica con Id=@Id  e calcolo comunque le informazioni di decesso sulla catena
	--  
	SELECT @IdPazienteAttivo = [dbo].[GetPazienteRootByPazienteId](@Id)
	--
	-- Calcolo la datadecesso derivata dalla catena di fusione
	--
	SELECT @DataDecessoCatena = dbo.GetPazientiDataDecesso(@IdPazienteAttivo)

	SELECT 
		Id, 
		Provenienza, 
		IdProvenienza,
		DataInserimento, 
		DataModifica,
		LivelloAttendibilita, 
		Tessera, 
		Cognome, 
		Nome, 
		DataNascita, 
		Sesso, 
		ComuneNascitaCodice, 
		--dbo.LookupIstatComuni(ComuneNascitaCodice) AS ComuneNascitaNome,
		ComuneNascitaNome,
		NazionalitaCodice, 
		--dbo.LookupIstatNazioni(NazionalitaCodice) AS NazionalitaNome,
		NazionalitaNome,
		--dbo.LookupIstatComuni(ComuneResCodice) AS ComuneResNome,
		ComuneResNome,
		CodiceFiscale,
		MantenimentoPediatra, 
		CapoFamiglia,	
		Indigenza, 
		--
		-- Calcolo CodiceTerminazione in base alla data di decesso sulla catena di fusione 
		--
		CASE WHEN (NOT @DataDecessoCatena IS NULL) THEN CAST('4' AS VARCHAR(8)) ELSE CodiceTerminazione END AS CodiceTerminazione,
		--
		-- Calcolo DescrizioneTerminazione in base alla data di decesso sulla catena di fusione 
		--
		CASE WHEN (NOT @DataDecessoCatena IS NULL) THEN CAST('DECESSO' AS VARCHAR(64)) ELSE DescrizioneTerminazione END AS DescrizioneTerminazione,
		ComuneResCodice, 
		SubComuneRes, 
		IndirizzoRes, 
		LocalitaRes, 
		CapRes, 
		DataDecorrenzaRes, 
		ComuneAslResCodice, 
		CodiceAslRes,
		--dbo.LookupIstatAsl(CodiceAslRes, ComuneAslResCodice) AS AslResNome, --c'è nella vista PazientiMsgBaseResult
		AslResNome,
		RegioneResCodice,
		--dbo.LookupIstatRegioni(RegioneResCodice) AS RegioneResNome , --c'è nella vista PazientiMsgBaseResult
		RegioneResNome ,
		ComuneDomCodice, 
		--dbo.LookupIstatComuni(ComuneDomCodice) AS ComuneDomNome, --c'è nella vista PazientiMsgBaseResult
		ComuneDomNome,
		SubComuneDom, 
		IndirizzoDom, 
		LocalitaDom, 
		CapDom, 
		PosizioneAss, 
		RegioneAssCodice, 
		--dbo.LookupIstatRegioni(RegioneAssCodice) AS RegioneAssNome, --c'è nella vista PazientiMsgBaseResult
		RegioneAssNome,
		ComuneAslAssCodice, 
		CodiceAslAss,
		--dbo.LookupIstatAsl(CodiceAslAss, ComuneAslAssCodice) AS AslAssNome, --c'è nella vista PazientiMsgBaseResult
		AslAssNome,
		DataInizioAss, 
		DataScadenzaAss, 
		--
		-- Calcolo DataTerminazioneAss in base alla data di decesso sulla catena di fusione 
		--
		CASE WHEN (NOT @DataDecessoCatena IS NULL) THEN @DataDecessoCatena ELSE DataTerminazioneAss END AS DataTerminazioneAss,
		DistrettoAmm, 
		DistrettoTer,
		Ambito, 
		CodiceMedicoDiBase, 
		CodiceFiscaleMedicoDiBase, 
		CognomeNomeMedicoDiBase,
		DistrettoMedicoDiBase, 
		DataSceltaMedicoDiBase, 
		ComuneRecapitoCodice, 
		--dbo.LookupIstatComuni(ComuneRecapitoCodice) AS ComuneRecapitoNome, --c'è nella vista PazientiMsgBaseResult
		ComuneRecapitoNome,
		IndirizzoRecapito, 
		LocalitaRecapito,
		Telefono1, 
		Telefono2, 
		Telefono3,
		CodiceSTP, 
		DataInizioSTP, 
		DataFineSTP, 
		MotivoAnnulloSTP,
		-- 
		-- Gestisco DataDecesso: serve il campo Disattivato nella vista PazientiMsgBaseResult
		--
		CASE WHEN Disattivato = 0 THEN
			@DataDecessoCatena 
		WHEN Disattivato <> 0 AND CodiceTerminazione = '4' THEN
			DataTerminazioneAss
		ELSE
			CAST(NULL AS DATETIME) 
		END AS DataDecesso
		--
		-- Per compatibilità con il metodo WS2
		--
		, Disattivato AS StatusCodice
		, CASE
			WHEN Disattivato = 0 THEN 'Attivo'
			WHEN Disattivato = 1 THEN 'Cancellato'
			WHEN Disattivato = 2 THEN 'Fuso'
		END AS StatusNome
		--
		-- Devo restituire tutti campi della SP [dbo].[PazientiWsDettaglioById] chela SP corrente non restituisce
		-- Tali campi (forse i lookup no, li faccio direttamente nella SP...) li devo aggiungere alla vista PazientiMsgBaseResult.
		-- Oppure tale SP legge dalla vista pazienti ed esegue tutti i lookup
		--
		, ProvinciaNascitaCodice	
		, ProvinciaNascitaNome	
		, ProvinciaResCodice	
		, ProvinciaResNome
		, ProvinciaAslResCodice
		, ProvinciaAslResNome
		, ComuneAslResNome
		, ProvinciaDomCodice
		, ProvinciaDomNome
		, ProvinciaAslAssCodice
		, ProvinciaAslAssNome
		, ComuneAslAssNome
		, ProvinciaRecapitoCodice
		, ProvinciaRecapitoNome
		-- Per compatibilità con WS2.DettaglioById
		 , CASE WHEN Disattivato = 2 THEN 
				@IdPazienteAttivo
		 ELSE
			CAST(NULL AS UNIQUEIDENTIFIER)
		 END AS IdPazienteAttivo
		--
		-- Campo Attributi
		--
		, Attributi
	FROM 
		PazientiMsgBaseResult
		--Pazienti
	WHERE 
		Id = @Id

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgDettaglioSelect] TO [DataAccessDll]
    AS [dbo];

