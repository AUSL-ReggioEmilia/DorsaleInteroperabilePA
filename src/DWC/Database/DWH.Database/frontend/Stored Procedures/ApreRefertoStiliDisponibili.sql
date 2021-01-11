

-- =============================================
-- Author:		Ettore
-- Create date: 2015-05-22
-- Description:	Restituisce il record associato allo stile del referto con le configurazioni per la visualizzazione del dettaglio referto
--				Sostituisce la dbo.ApreRefertoStiliDisponibili
-- Modify date:	2018-04-10 - ETTORE: restituiti i nuovi campi per la gestione interna dei dettagli del referto
-- =============================================
CREATE PROCEDURE [frontend].[ApreRefertoStiliDisponibili]
(
	@IdRefertiBase as uniqueidentifier
)
AS
BEGIN 
	SET NOCOUNT ON

	SELECT 
		Nome, 
		Abilitato, 
		Descrizione, 
		Note, 
		PaginaWeb, 
		Parametri,
		Tipo,
		XsltTestata,
		XsltRighe, 
		--2018-04-10 - ETTORE: Nuovi campi 
		XsltAllegatoXml,
		NomeFileAllegatoXml,
		ShowLinkDocumentoPdf,
		ShowAllegatoRTF
	FROM    
		RefertiStili
	WHERE 
		Nome = CONVERT(VARCHAR(64), dbo.GetRefertiAttributo( @IdRefertiBase, 'NomeStile'))
		-- AND Abilitato = 1 --se si vuole tenere conto del flag abilitato
END


