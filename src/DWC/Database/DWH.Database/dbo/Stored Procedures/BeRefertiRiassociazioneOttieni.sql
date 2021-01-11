
-- =============================================
-- Author:
-- Create date: 
-- Description: Restituisce il record del referto assieme alle sue informazioni anagrafiche
-- Modify date: 2018-06-07 - ETTORE - Utilizzo delle viste "store"
-- =============================================
CREATE PROCEDURE [dbo].[BeRefertiRiassociazioneOttieni]
(
	@idReferto UNIQUEIDENTIFIER 
)
AS
BEGIN
	SET NOCOUNT ON	

	SELECT 
		R.ID,
		R.IdEsterno,
		R.IdPaziente,
		R.DataInserimento,
		R.DataModifica,
		R.AziendaErogante,
		R.SistemaErogante,
		R.RepartoErogante,
		R.DataReferto,
		R.NumeroReferto,
		R.NumeroNosologico,
		R.NumeroPrenotazione,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( R.Id, 'Cognome')) AS Cognome,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( R.Id, 'Nome')) AS Nome,
		CONVERT(VARCHAR(1), dbo.GetRefertiAttributo( R.Id, 'Sesso')) AS Sesso,
		CONVERT(VARCHAR(16), dbo.GetRefertiAttributo( R.Id, 'CodiceFiscale')) AS CodiceFiscale,
		dbo.GetRefertiAttributoDateTime( R.Id, 'DataNascita') AS DataNascita,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( R.Id, 'ComuneNascita')) AS ComuneNascita,
		CONVERT(VARCHAR(4), dbo.GetRefertiAttributo( R.Id, 'ProvinciaNascita')) AS ProvinciaNascita,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( R.Id, 'CodiceAnagraficaCentrale')) AS CodiceAnagraficaCentrale,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( R.Id, 'NomeAnagraficaCentrale')) AS NomeAnagraficaCentrale,
		CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( R.Id, 'CodiceSanitario')) AS CodiceSanitario,
	--dati letti dal sac:	
		SAC.Cognome AS SACCognome,
		SAC.Nome AS SACNome,
		SAC.Sesso as SACSesso,
		SAC.CodiceFiscale AS SACCodiceFiscale,
		SAC.DataNascita AS SACDataNascita,		
		CASE SAC.ComuneNascitaCodice
			WHEN '000000' THEN NULL
			ELSE SAC.ComuneNascitaNome
		END AS SACComuneNascita,		
		CASE SAC.ProvinciaNascitaNome 
			WHEN '??' THEN NULL
			ELSE SAC.ProvinciaNascitaNome
		END AS SACProvinciaNascita,
		SAC.Provenienza as SACProvenienza,
		SAC.IdProvenienza as SACIdProvenienza,	
		SAC.Tessera as SACTessera
		
	FROM store.RefertiBase R WITH(NOLOCK)

	LEFT JOIN dbo.[SAC_Pazienti] SAC WITH(NOLOCK) 
		ON	R.IdPaziente = SAC.Id  AND R.IdPaziente <> '00000000-0000-0000-0000-000000000000'
			
	WHERE R.Id=@idReferto
	
END






GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BeRefertiRiassociazioneOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

