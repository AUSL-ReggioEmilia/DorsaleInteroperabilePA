
CREATE PROCEDURE [dbo].[FeprRefertiRadionetTestata]
(
	@IdRefertiBase UNIQUEIDENTIFIER
)
AS
/*
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store" 
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
		NumeroPrenotazione,
		Cognome,
		Nome,
		Sesso,
		CodiceFiscale,
		CONVERT(VARCHAR(20), DataNascita, 103) AS DataNascita,
		ComuneNascita,
		--PER COMPATIBILITA
		'' AS ProvinciaNascita,
		'' AS ComuneResidenza,
		'' AS CodiceSAUB,
		CodiceSanitario,
		RepartoRichiedenteCodice,
		RepartoRichiedenteDescr + ' (' + RepartoRichiedenteCodice + ') ' AS RepartoRichiedenteDescr,
		PrioritaCodice,
		PrioritaDescr,
		StatoRichiestaCodice,
		StatoRichiestaDescr,
		TipoRichiestaCodice,
		TipoRichiestaDescr,
		Referto,

		NULLIF( ISNULL(MedicoRefertanteCodice,'') + ' - ' + ISNULL(MedicoRefertanteDescr,''), ' - ') AS MedicoRefertante,

		dbo.GetRefertiAttributoDateTime(Id, 'DataAdd1') AS DataAdd1,
		CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo( Id, 'RefertoAdd1')) AS Addendum1,

		NULLIF( ISNULL( CONVERT(VARCHAR(16), dbo.GetRefertiAttributo( Id, 'MedicoRefertanteAdd1Codice')), '') + ' - '
			+ ISNULL( CONVERT(VARCHAR(100), dbo.GetRefertiAttributo( Id, 'MedicoRefertanteAdd1Descr')) ,''), ' - ') AS MedicoRefertanteAdd1,

		dbo.GetRefertiAttributoDateTime(Id, 'DataAdd2') AS DataAdd2,
		CONVERT(VARCHAR(8000), dbo.GetRefertiAttributo( Id, 'RefertoAdd2')) AS Addendum2,

		NULLIF( ISNULL( CONVERT(VARCHAR(16), dbo.GetRefertiAttributo( Id, 'MedicoRefertanteAdd2Codice')), '') + ' - '
			+ ISNULL( CONVERT(VARCHAR(100), dbo.GetRefertiAttributo( Id, 'MedicoRefertanteAdd2Descr')) ,''), ' - ')  AS MedicoRefertanteAdd2,

		CONVERT(VARCHAR(255), dbo.GetRefertiAttributo( Id, 'AccessNumber')) AS AccessNumber

	FROM		
		frontend.Referti
	WHERE	
		ID = @IdRefertiBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiRadionetTestata] TO [ExecuteFrontEnd]
    AS [dbo];

