
-- =============================================
-- Author:		ETTORE
-- Create date: 2018-07-30
-- Description:	Restituisce tutti i dati di testata (come la PazientiMsgBaseSelect)
--				Usato anche OPTION(RECOMPILE)
-- =============================================
CREATE PROCEDURE [dbo].[PazientiMsgBaseSelectAllByGeneralita2]
(
	@MaxRecord int
	, @SortOrder int
	, @IdPaziente uniqueidentifier
	, @Cognome varchar(64)
	, @Nome varchar(64)
	, @DataNascita datetime
	, @CodiceFiscale varchar(16)
	, @Sesso varchar(1)
) WITH RECOMPILE
AS 
BEGIN
	SET NOCOUNT ON;
	--
	-- La SP restituie i dati di decesso allo stesso modo del dettaglio, andando a calcolare la data di decesso sulla catena di fusione
	-- dbo.GetPazientiDataDecesso([dbo].[GetPazienteRootByPazienteId](Id))
	-- Visto che si legge dalla vista PazientiAttiviMsgBaseResult non eseguo la chiamata a [dbo].[GetPazienteRootByPazienteId](Id)
	--

	SELECT TOP (@MaxRecord)
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
		CASE WHEN (NOT dbo.GetPazientiDataDecesso(Id) IS NULL) THEN 
			CAST('4' AS VARCHAR(8))
		ELSE
			CodiceTerminazione
		END AS CodiceTerminazione,
		--
		-- Calcolo DescrizioneTerminazione in base alla data di decesso sulla catena di fusione 
		--
		CASE WHEN (NOT dbo.GetPazientiDataDecesso(Id) IS NULL) THEN 
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
		CASE WHEN (NOT dbo.GetPazientiDataDecesso(Id) IS NULL) THEN 
			dbo.GetPazientiDataDecesso(Id)
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
		dbo.GetPazientiDataDecesso(Id) AS DataDecesso, 
		Attributi
	FROM 
		PazientiAttiviMsgBaseResult

	WHERE 
			((Id = @IdPaziente) OR (@IdPaziente IS NULL))
		AND ((Cognome Like @Cognome + '%') OR (@Cognome IS NULL))
		AND ((Nome Like @Nome + '%') OR (@Nome IS NULL))
		AND ((DataNascita = @DataNascita) OR (@DataNascita IS NULL))
		AND ((CodiceFiscale = @CodiceFiscale) OR (@CodiceFiscale IS NULL))
		AND ((Sesso = @Sesso) OR (@Sesso IS NULL))

	ORDER BY CASE WHEN @SortOrder = 1 THEN Cognome
				  WHEN @SortOrder = 2 THEN Nome
				  --WHEN @SortOrder = 3 THEN DataNascita
				  WHEN @SortOrder = 4 THEN CodiceFiscale
				  WHEN @SortOrder = 5 THEN Sesso
				  ELSE Cognome
			 END
	
	OPTION(RECOMPILE)

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[PazientiMsgBaseSelectAllByGeneralita2] TO [DataAccessDll]
    AS [dbo];

