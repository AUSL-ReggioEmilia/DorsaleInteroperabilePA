

CREATE PROCEDURE [frontend].[SistemiErogantiDocumenti]
(
	@AziendaErogante varchar(16),
	@SistemaErogante varchar(16)
)
AS
BEGIN
/*
	CREATA DA ETTORE 2015-05-22:
		Sostituisce la dbo.FevsSistemiErogantiDocumenti
		Nessuna modifica
*/
	SET NOCOUNT ON
	SELECT 
		dbo.SistemiErogantiDocumenti.Id as IdDocumento
		,dbo.SistemiErogantiDocumenti.Nome + '.' + dbo.SistemiErogantiDocumenti.Estensione as NomeDocumento
	FROM 
		dbo.SistemiErogantiDocumenti
		inner join dbo.SistemiEroganti on dbo.SistemiEroganti.Id = dbo.SistemiErogantiDocumenti.IDSistemaErogante
	WHERE
		dbo.SistemiEroganti.AziendaErogante = @AziendaErogante 
		AND dbo.SistemiEroganti.SistemaErogante = @SistemaErogante

END