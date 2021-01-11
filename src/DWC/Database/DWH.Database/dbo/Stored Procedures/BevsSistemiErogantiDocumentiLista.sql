CREATE PROCEDURE [dbo].[BevsSistemiErogantiDocumentiLista]
(
	@AziendaErogante varchar(16)
)
AS
SET NOCOUNT ON;
SELECT 
	SistemiErogantiDocumenti.Id
	,SistemiErogantiDocumenti.Nome + '.' + SistemiErogantiDocumenti.Estensione AS Nome
	,SistemiErogantiDocumenti.Dimensione
	,SistemiErogantiDocumenti.ContentType
	,SistemiEroganti.AziendaErogante
	,SistemiEroganti.SistemaErogante
FROM
	dbo.SistemiErogantiDocumenti
	inner join SistemiEroganti ON SistemiEroganti.ID = SistemiErogantiDocumenti.IdSistemaErogante
WHERE
	(SistemiEroganti.AziendaErogante like @AziendaErogante + '%') or (@AziendaErogante IS NULL)
ORDER BY
	SistemiEroganti.AziendaErogante + SistemiEroganti.SistemaErogante

SET NOCOUNT OFF;


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiDocumentiLista] TO [ExecuteFrontEnd]
    AS [dbo];

