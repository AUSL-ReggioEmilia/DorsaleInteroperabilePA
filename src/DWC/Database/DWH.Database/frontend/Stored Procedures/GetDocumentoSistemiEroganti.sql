

CREATE PROCEDURE [frontend].[GetDocumentoSistemiEroganti]
(
	@Id uniqueidentifier
)
AS
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsGetDocumentoSistemiEroganti
		Utilizzata nella pagina di visualizzazione dei documenti
*/
SET NOCOUNT ON;
SELECT 
	Id
	,Nome
	,Estensione
	,Dimensione
	,ContentType
	,Contenuto		--campo IMAGE
FROM
	dbo.SistemiErogantiDocumenti
WHERE
	Id = @Id

