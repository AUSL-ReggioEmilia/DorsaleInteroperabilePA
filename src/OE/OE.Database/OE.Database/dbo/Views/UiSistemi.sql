
CREATE VIEW [dbo].[UiSistemi]
AS
	SELECT s.[ID]
		  ,s.[Codice]
		  ,s.[Azienda] AS [CodiceAzienda] 
		  ,s.[Descrizione]
		  ,s.[Richiedente]
		  ,s.[Erogante]
		  ,s.[Attivo] AS AttivoSac 
	  
		  ,CONVERT(bit ,ISNULL(s_e.[Attivo], 0))AS [Attivo]
		  ,CONVERT(bit ,ISNULL(s_e.[CancellazionePostInoltro], 0)) AS [CancellazionePostInoltro]

	FROM [SacOrganigramma].[Sistemi] s
		LEFT JOIN [dbo].[SistemiEstesa] s_e
			ON s_e.ID = s.Id
	WHERE s.ID != '00000000-0000-0000-0000-000000000000'

