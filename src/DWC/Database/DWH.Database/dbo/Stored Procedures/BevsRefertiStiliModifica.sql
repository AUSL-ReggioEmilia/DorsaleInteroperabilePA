
-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Aggiornamento di un record nella tabella RefertiStili
-- Modify date:	2018-04-10 - ETTORE: inserimento dei nuovi campi per la gestione interna dei dettagli del referto
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertiStiliModifica]
(
   @Id   uniqueidentifier,
   @Nome   VARCHAR(64),
   @Abilitato   bit,
   @Descrizione   VARCHAR(50),
   @Note   VARCHAR(200),
   @PaginaWeb   VARCHAR(255),
   @Parametri   VARCHAR(255),
   @Tipo INT,
   @XsltTestata VARCHAR(MAX) = NULL,
   @XsltRighe VARCHAR(MAX) = NULL,
   @XsltAllegatoXml VARCHAR(MAX) = NULL,
   @NomeFileAllegatoXml VARCHAR(255) = NULL,
   @ShowLinkDocumentoPdf bit = NULL,
   @ShowAllegatoRTF bit = NULL
)
AS
BEGIN
	SET NOCOUNT ON
 
	UPDATE RefertiStili 
		SET Nome = @Nome,
			Abilitato = @Abilitato,
			Descrizione = @Descrizione,
			Note = @Note,
			PaginaWeb = @PaginaWeb,
			Parametri = @Parametri,
			Tipo = @Tipo,
			XsltTestata = @XsltTestata,
			XsltRighe = @XsltRighe,
			XsltAllegatoXml = @XsltAllegatoXml,
			NomeFileAllegatoXml = @NomeFileAllegatoXml,
			ShowLinkDocumentoPdf = ISNULL(@ShowLinkDocumentoPdf, 0),
			ShowAllegatoRTF = ISNULL(@ShowAllegatoRTF, 0) 
	WHERE
		Id = @Id

	IF @@ERROR = 0
		  RETURN 0
	ELSE
		  RETURN @@ERROR

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiStiliModifica] TO [ExecuteFrontEnd]
    AS [dbo];

