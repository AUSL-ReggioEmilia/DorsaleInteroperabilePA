
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-06-09 Copiata da [FevsGetDocumentoSistemiEroganti]
-- Modify date: 
-- Description: Restituisce il documento associato al sistema erogante
-- =============================================
CREATE PROCEDURE [dbo].[BevsGetDocumentoSistemiEroganti]
(
@Id uniqueidentifier
)
AS
--
-- Utilizzata nella pagina di visualizzazione dei documenti
--
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
SET NOCOUNT OFF;


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsGetDocumentoSistemiEroganti] TO [ExecuteFrontEnd]
    AS [dbo];

