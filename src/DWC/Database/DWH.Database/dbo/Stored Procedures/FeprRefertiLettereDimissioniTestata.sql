
CREATE PROCEDURE [dbo].[FeprRefertiLettereDimissioniTestata]
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
		Cognome,
		Nome,
		Sesso,
		CodiceFiscale,
		CONVERT(VARCHAR(20), DataNascita, 103) AS DataNascita,
		ComuneNascita,
		--PER COMPATIBILITA
		'' AS ProvinciaNascita,
		'' AS ComuneResidenza,
		Referto ,
		--NULLIF( ISNULL(MedicoRefertanteCodice,'') + ' - ' + ISNULL(MedicoRefertanteDescr,''), ' - ') AS MedicoRefertante,
		NULLIF( ISNULL(MedicoRefertanteDescr,''), ' - ') AS MedicoRefertante,
		CONVERT(VARCHAR(2), dbo.GetRefertiAttributo( Id, 'PazienteDimesso')) AS PazienteDimesso,		
		CONVERT(VARCHAR(200), dbo.GetRefertiAttributo( Id, 'UtenteRedattore'))  AS UtenteRedattore
	FROM		
		frontend.Referti
	WHERE	
		ID = @IdRefertiBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiLettereDimissioniTestata] TO [ExecuteFrontEnd]
    AS [dbo];

