
CREATE PROCEDURE [dbo].[FeprRefertiAltaviaPrestazioneTestata]
(
	@IdPrestazioniBase UNIQUEIDENTIFIER
)
AS
/* 
	MODIFICA ETTORE 2015-06-19: Utilizzo delle viste dello schema "frontend" e "store"
	Uso le nuove funzioni GetRefertiAttributoAttributo2() con data di partizione	
*/
	SET NOCOUNT ON
	DECLARE @IdReferto as uniqueidentifier
	--
	-- Dalla prestazione ricavo l'Id del referto
	--
	SELECT TOP 1
		@IdReferto = IdRefertiBase 
	FROM 
		store.Prestazioni 
	WHERE 
		Id = @IdPrestazioniBase

	SELECT	
		R.ID,
		R.IdEsterno,
		--MODIFICA ETTORE 2012-09-10: traslo l'idpaziente nell'idpaziente attivo		
		dbo.GetPazienteAttivoByIdSac(R.IdPaziente) AS IdPaziente,
		R.DataInserimento,
		R.DataModifica,
		R.AziendaErogante,
		R.SistemaErogante,
		R.RepartoErogante,
		CONVERT(VARCHAR(20), R.DataReferto, 103) AS DataReferto,
		R.NumeroReferto,
		R.NumeroNosologico,
		R.Cognome,
		R.Nome,
		R.Sesso,
		R.CodiceFiscale,
		CONVERT(VARCHAR(20), R.DataNascita, 103) AS DataNascita,
		R.ComuneNascita,
		--PER COMPATIBILITA
		'' AS ProvinciaNascita,
		'' AS ComuneResidenza,
		R.Referto,
		NULLIF( ISNULL(R.MedicoRefertanteCodice,'') + ' - ' + ISNULL(R.MedicoRefertanteDescr,''), ' - ') AS MedicoRefertante,
		CONVERT(VARCHAR(1024), dbo.GetRefertiAttributo2(R.Id, R.DataPartizione, 'Complicanze_descri')) AS Complicanze_descri,		
		CONVERT(VARCHAR(1024), dbo.GetRefertiAttributo2(R.Id, R.DataPartizione, 'Conclusioni'))  AS Conclusioni
	FROM		
		frontend.Referti AS R
	WHERE 
		R.ID = @IdReferto

SET NOCOUNT OFF


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[FeprRefertiAltaviaPrestazioneTestata] TO [ExecuteFrontEnd]
    AS [dbo];

