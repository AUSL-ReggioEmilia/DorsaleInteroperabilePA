


CREATE VIEW [dbo].[RepartiRichiedentiUnificati]
AS
SELECT 
	dbo.SistemiEroganti.AziendaErogante
	, dbo.SistemiEroganti.SistemaErogante
	, dbo.RepartiRichiedentiSistemiEroganti.RepartoRichiedenteCodice
	, dbo.RepartiRichiedentiSistemiEroganti.RepartoRichiedenteDescrizione
	, dbo.RepartiRichiedenti.Id AS IdRepartiRichiedenti
   	, dbo.RepartiRichiedenti.RepartoRichiedenteCodice AS Codice
	, dbo.RepartiRichiedenti.RepartoRichiedenteDescrizione AS Descrizione
	, dbo.RepartiRichiedenti.RuoloVisualizzazione
	, dbo.RepartiRichiedenti.RuoloManager
FROM         
	dbo.RepartiRichiedenti 
	RIGHT OUTER JOIN dbo.RepartiRichiedentiSistemiEroganti
		ON dbo.RepartiRichiedenti.Id = dbo.RepartiRichiedentiSistemiEroganti.IdRepartiRichiedenti
	INNER JOIN dbo.SistemiEroganti 
		ON dbo.RepartiRichiedentiSistemiEroganti.IdSistemaErogante = dbo.SistemiEroganti.Id



