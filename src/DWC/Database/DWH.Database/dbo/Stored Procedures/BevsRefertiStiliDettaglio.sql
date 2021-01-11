

-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Restituisce un record della tabella RefertiStili
-- Modify date:	2018-04-10 - ETTORE: restituiti i nuovi campi per la gestione interna dei dettagli del referto
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertiStiliDettaglio]
(
	@Id as uniqueidentifier
)
AS
BEGIN
	SET NOCOUNT ON

	SELECT   
		Id,
		Nome,
		Abilitato,
		Descrizione,
		Note,
		PaginaWeb,
		Parametri,
		Tipo,
		XsltTestata,
		XsltRighe, 
		XsltAllegatoXml,
		NomeFileAllegatoXml,
		ShowLinkDocumentoPdf,
		ShowAllegatoRTF
	FROM         
		RefertiStili
	WHERE 
		Id = @Id

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiStiliDettaglio] TO [ExecuteFrontEnd]
    AS [dbo];

