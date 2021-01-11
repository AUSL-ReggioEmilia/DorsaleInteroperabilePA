

CREATE PROCEDURE [dbo].[BevsNotaAnamnesticaRiassociazioneOttieni]
(
	@IdNotaAnamnestica UNIQUEIDENTIFIER 
)
AS
BEGIN
	SET NOCOUNT ON	

	SELECT NA.Id
		,NA.DataPartizione
		,NA.IdEsterno
		,NA.IdPaziente
		,NA.DataInserimento
		,NA.DataModifica
		,NA.DataModificaEsterno
		,NA.AziendaErogante
		,NA.SistemaErogante
		,NA.DataNota
		,NA.DataFineValidita
		,NA.TipoCodice
		,NA.TipoDescrizione
		,NA.Contenuto
		,NA.TipoContenuto
		,NA.ContenutoHtml
		,NA.ContenutoText
		,dbo.GetNotaAnamnesticaStatoDesc(NA.StatoCodice, NULL) AS StatoCodiceDesc,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'Cognome')) AS Cognome,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'Nome')) AS Nome,
		CONVERT(VARCHAR(1), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'Sesso')) AS Sesso,
		CONVERT(VARCHAR(16), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'CodiceFiscale')) AS CodiceFiscale,
		dbo.GetNoteAnamnesticheAttributoDateTime(NA.Id,NA.DataPartizione, 'DataNascita') AS DataNascita,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'ComuneNascita')) AS ComuneNascita,
		CONVERT(VARCHAR(4), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'ProvinciaNascita')) AS ProvinciaNascita,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'CodiceAnagraficaCentrale')) AS CodiceAnagraficaCentrale,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'NomeAnagraficaCentrale')) AS NomeAnagraficaCentrale,
		CONVERT(VARCHAR(64), dbo.GetNoteAnamnesticheAttributo(NA.Id,NA.DataPartizione, 'CodiceSanitario')) AS CodiceSanitario,
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
		
	FROM store.NoteAnamnesticheBase NA WITH(NOLOCK)

	LEFT JOIN dbo.[SAC_Pazienti] SAC WITH(NOLOCK) 
		ON	NA.IdPaziente = SAC.Id  AND NA.IdPaziente <> '00000000-0000-0000-0000-000000000000'
			
	WHERE NA.Id= @IdNotaAnamnestica
	
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsNotaAnamnesticaRiassociazioneOttieni] TO [ExecuteFrontEnd]
    AS [dbo];

