
CREATE PROCEDURE [dbo].[FeprRefertiSdoTestata]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/*
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store" 
	Uso le nuove funzioni GetRefertiAttributoAttributo2() con data di partizione
*/
	SET NOCOUNT ON
	SELECT	
		ID,
		IdEsterno,
		--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo		
		dbo.GetPazienteAttivoByIdSac(IdPaziente) AS IdPaziente,
		DataInserimento,
		DataModifica,
		AziendaErogante,
		SistemaErogante,
		RepartoErogante,
		CONVERT(VARCHAR(20), DataReferto, 103) AS DataReferto,
		NumeroReferto,
		NumeroNosologico,
		Cognome,
		Nome,
		Sesso,
		CodiceFiscale,
		CONVERT(VARCHAR(20), DataNascita, 103) AS DataNascita,
		ComuneNascita,
		CONVERT(VARCHAR(15), dbo.GetRefertiAttributo2( Id, DataPartizione, 'PazienteStatocivileDesc'))  AS PazienteStatocivileDesc,
		CONVERT(VARCHAR(35), dbo.GetRefertiAttributo2( Id, DataPartizione, 'PazienteLuogoResidenza'))  AS PazienteLuogoResidenza,
		CONVERT(VARCHAR(3),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'PazienteRegioneResidenzaCodice'))  AS PazienteRegioneResidenzaCodice,
		CONVERT(VARCHAR(35), dbo.GetRefertiAttributo2( Id, DataPartizione, 'PazienteRegioneResidenzaDesc'))  AS PazienteRegioneResidenzaDesc,
		CONVERT(VARCHAR(6),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'PazienteAuslCodice'))  AS PazienteAuslCodice,
		CONVERT(VARCHAR(35), dbo.GetRefertiAttributo2( Id, DataPartizione, 'PazienteAuslDesc'))  AS PazienteAuslDesc,
		CONVERT(VARCHAR(3),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'PazienteCittadinanzaCodice'))  AS PazienteCittadinanzaCodice,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'PazienteCittadinanzaDesc'))  AS PazienteCittadinanzaDesc,
		
		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2( Id, DataPartizione, 'NumeroCartellaClinica'))  AS NumeroCartellaClinica,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'RicoveroRegimeDesc'))  AS RicoveroRegimeDesc,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'TraumaDesc'))  AS TraumaDesc,
		CONVERT(VARCHAR(2),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'OnereDegenzaCodice'))  AS OnereDegenzaCodice,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'OnereDegenzaDesc'))  AS OnereDegenzaDesc,
		--CONVERT(VARCHAR(20), CONVERT(datetime, dbo.GetRefertiAttributo2( Id, DataPartizione, 'AccettazioneData')),103)  AS AccettazioneData,
		CONVERT(VARCHAR(20), dbo.GetRefertiAttributo2Datetime( Id, DataPartizione, 'AccettazioneData'),103)  AS AccettazioneData,
		--CONVERT(VARCHAR(5),  CONVERT(datetime, dbo.GetRefertiAttributo2( Id, DataPartizione, 'AccettazioneData')),108)  AS AccettazioneOra,
		CONVERT(VARCHAR(5),  dbo.GetRefertiAttributo2Datetime( Id, DataPartizione, 'AccettazioneData'),108)  AS AccettazioneOra,
		CONVERT(VARCHAR(6),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'RepartoRichiedenteCodice'))  AS RepartoRichiedenteCodice,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'RepartoRichiedenteDescrizione'))  AS RepartoRichiedenteDescrizione,
		CONVERT(VARCHAR(2),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'RicoveroTipoCodice'))  AS RicoveroTipoCodice,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'RicoveroTipoDesc'))  AS RicoveroTipoDesc,
		CONVERT(VARCHAR(3),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'RicoveroPropostaCodice'))  AS RicoveroPropostaCodice,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'RicoveroPropostaDesc'))  AS RicoveroPropostaDesc,
		CONVERT(VARCHAR(2),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'RicoveroMotivoCodice'))  AS RicoveroMotivoCodice,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'RicoveroMotivoDesc'))  AS RicoveroMotivoDesc,

		CONVERT(VARCHAR(2),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'DimissioniCodice'))  AS DimissioniCodice,
		CONVERT(VARCHAR(50), dbo.GetRefertiAttributo2( Id, DataPartizione, 'DimissioniDesc'))  AS DimissioniDesc,
		CONVERT(VARCHAR(255),dbo.GetRefertiAttributo2( Id, DataPartizione, 'DimissioniDiagnosiDesc'))  AS DimissioniDiagnosiDesc,
		--CONVERT(VARCHAR(20), CONVERT(datetime, dbo.GetRefertiAttributo2( Id, DataPartizione, 'DimissioniData')), 103)  AS DimissioniData,
		CONVERT(VARCHAR(20), dbo.GetRefertiAttributo2Datetime( Id, DataPartizione, 'DimissioniData'), 103)  AS DimissioniData,
		CONVERT(VARCHAR(5),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'DimissioniRepartoCodice'))  AS DimissioniRepartoCodice,
		CONVERT(VARCHAR(1),  dbo.GetRefertiAttributo2( Id, DataPartizione, 'DimissioniAfoCodice'))  AS DimissioniAfoCodice,
		CONVERT(VARCHAR(60), dbo.GetRefertiAttributo2( Id, DataPartizione, 'DimissioniAfoDesc'))  AS DimissioniAfoDesc
	FROM		
		frontend.Referti
	WHERE	
		ID = @IdRefertiBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiSdoTestata] TO [ExecuteFrontEnd]
    AS [dbo];

