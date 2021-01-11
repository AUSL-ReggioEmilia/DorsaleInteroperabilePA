

-- =============================================
-- Author:		???
-- Create date: ???
-- Description:	Inserisce un nuovo record nella tabella RefertiStili
-- Modify date:	2018-04-10 - ETTORE: inserimento nuovi campi per la gestione interna dei dettagli del referto
-- =============================================
CREATE PROCEDURE [dbo].[BevsRefertiStiliAggiungi]
(
   @Id  uniqueidentifier,
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
   @ShowLinkDocumentoPdf bit NULL,
   @ShowAllegatoRTF bit NULL
)
AS
BEGIN 
	SET NOCOUNT ON

	INSERT RefertiStili (
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
	)
	VALUES (
		@Id,
		@Nome,
		@Abilitato,
		@Descrizione,
		@Note,
		@PaginaWeb,
		@Parametri,
		@Tipo,
		@XsltTestata,
		@XsltRighe,
		@XsltAllegatoXml,
		@NomeFileAllegatoXml,
		ISNULL(@ShowLinkDocumentoPdf, 0),
		ISNULL(@ShowAllegatoRTF, 0)
	)
 
	IF @@ERROR = 0
	   BEGIN
		  SELECT Id = @Id
		  RETURN 0
	   END
	ELSE
	   BEGIN
		  RETURN @@ERROR
		  SELECT Id = NULL
	   END

END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsRefertiStiliAggiungi] TO [ExecuteFrontEnd]
    AS [dbo];

