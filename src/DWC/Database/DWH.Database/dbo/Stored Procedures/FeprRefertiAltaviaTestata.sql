
CREATE PROCEDURE [dbo].[FeprRefertiAltaviaTestata]
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
		--PER COMPATIBILITA
		'' AS ProvinciaNascita,
		'' AS ComuneResidenza,
		Referto ,
		NULLIF( ISNULL(MedicoRefertanteCodice,'') + ' - ' + ISNULL(MedicoRefertanteDescr,''), ' - ') AS MedicoRefertante,
		CONVERT(VARCHAR(1024), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Complicanze_descri')) AS Complicanze_descri,		
		CONVERT(VARCHAR(1024), dbo.GetRefertiAttributo2(Id, DataPartizione, 'Conclusioni'))  AS Conclusioni
	FROM		
		frontend.Referti
	WHERE	
		Id = @IdRefertiBase


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiAltaviaTestata] TO [ExecuteFrontEnd]
    AS [dbo];

