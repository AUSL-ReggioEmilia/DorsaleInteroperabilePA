
CREATE PROCEDURE [dbo].[FeprRefertiGenericoPrestazioneTestata]
(
	@IdPrestazioniBase UNIQUEIDENTIFIER
)
AS
/* 
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store" 
*/
	SET NOCOUNT ON

	DECLARE @IdReferto as uniqueidentifier
	SELECT @IdReferto = IdRefertiBase 
	FROM 
		store.Prestazioni 
	WHERE 
		Id = @IdPrestazioniBase

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
		RepartoRichiedenteDescr + ' (' + RepartoRichiedenteCodice + ')' AS RepartoRichiedenteDescr,
		COALESCE(PrioritaCodice, TipoRichiestaCodice) AS PrioritaCodice,
		COALESCE(PrioritaDescr, TipoRichiestaDescr) AS PrioritaDescr,
		StatoRichiestaCodice,
		StatoRichiestaDescr,
		TipoRichiestaCodice,
		TipoRichiestaDescr,
		Referto ,
		NULLIF( ISNULL(MedicoRefertanteCodice,'') + ' - ' + ISNULL(MedicoRefertanteDescr,''), ' - ') AS MedicoRefertante
	FROM		
		frontend.Referti 
	WHERE	
		Id = @IdReferto


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiGenericoPrestazioneTestata] TO [ExecuteFrontEnd]
    AS [dbo];

