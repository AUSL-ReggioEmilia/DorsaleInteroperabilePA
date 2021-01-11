
CREATE PROCEDURE [dbo].[FeprCustomView_RadioGstTestata]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/* 
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
	Uso le nuove funzioni GetRefertiAttributoAttributo2() con data di partizione
*/
SET NOCOUNT ON
	
	SELECT	ID,
		IdEsterno,
		--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo		
		dbo.GetPazienteAttivoByIdSac(IdPaziente) AS IdPaziente,
		
		---Referto
		
		AziendaErogante,
		SistemaErogante,
		RepartoErogante,
		CONVERT(VARCHAR(20), DataReferto, 103) AS DataReferto,
		NumeroReferto,
		NumeroNosologico,
		NumeroPrenotazione,

		---Paziente

		Cognome,
		Nome,
		Sesso,
		CodiceFiscale,
		CONVERT(VARCHAR(20), DataNascita, 103) AS DataNascita,
		ComuneNascita,
		CodiceSanitario,

		---Classificazione

		RepartoRichiedenteCodice,
		RepartoRichiedenteDescr + ' (' + RepartoRichiedenteCodice + ') ' AS RepartoRichiedenteDescr,
		
		PrioritaCodice,
		PrioritaDescr,

		StatoRichiestaCodice,
		StatoRichiestaDescr,

		TipoRichiestaCodice,
		TipoRichiestaDescr,

		---Risultato

		Referto,
		NULLIF( ISNULL(MedicoRefertanteCodice,'') + ' - ' + ISNULL(MedicoRefertanteDescr,''), ' - ') AS MedicoRefertante,

		---Addeddum 1

		--CONVERT(VARCHAR(20), CONVERT(DATETIME, dbo.GetRefertiAttributo( Id, 'Addendum1Data')), 103) AS Addendum1Data,
		CONVERT(VARCHAR(20), dbo.GetRefertiAttributo2Datetime( Id, DataPartizione, 'Addendum1Data'), 103) AS Addendum1Data,

		NULLIF( ISNULL( CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo2( Id, DataPartizione, 'Addendum1Testo1')), '') + ' '
			+ ISNULL( CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo2( Id, DataPartizione,'Addendum1Testo2')), ''), ' ') AS Addendum1Testo,

		NULLIF( ISNULL( CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2( Id, DataPartizione, 'Addendum1MedicoRefertanteCodice')), '') + ' - '
			+ ISNULL( CONVERT(VARCHAR(100), dbo.GetRefertiAttributo2( Id, DataPartizione, 'Addendum1MedicoRefertanteDescrizione')) ,''), ' - ') AS Addendum1MedicoRefertante,

		---Addeddum 2

		--CONVERT(VARCHAR(20), CONVERT(DATETIME, dbo.GetRefertiAttributo( Id, 'Addendum2Data')), 103) AS Addendum2Data,
		CONVERT(VARCHAR(20), dbo.GetRefertiAttributo2Datetime( Id, DataPartizione, 'Addendum2Data'), 103) AS Addendum2Data,

		NULLIF( ISNULL( CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo2( Id, DataPartizione, 'Addendum2Testo1')), '') + ' '
			+ ISNULL( CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo2( Id, DataPartizione, 'Addendum2Testo2')), ''), ' ') AS Addendum2Testo,

		NULLIF( ISNULL( CONVERT(VARCHAR(16), dbo.GetRefertiAttributo2( Id, DataPartizione, 'Addendum2MedicoRefertanteCodice')), '') + ' - '
			+ ISNULL( CONVERT(VARCHAR(100), dbo.GetRefertiAttributo2( Id, DataPartizione, 'Addendum2MedicoRefertanteDescrizione')) ,''), ' - ') AS Addendum2MedicoRefertante,

		--- Accesso al PACS

		CONVERT(VARCHAR(255), dbo.GetRefertiAttributo2( Id, DataPartizione, 'AccessNumber')) AS AccessNumber

	FROM frontend.Referti
	WHERE ID = @IdRefertiBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprCustomView_RadioGstTestata] TO [ExecuteFrontEnd]
    AS [dbo];

