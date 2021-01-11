
-- =============================================
-- Author:		Alessandro Nostini
-- Modify date: 2013-10-14
-- Modify date: 2014-11-04 Usa [GetProfiloGerarchia2]
-- Description:	Seleziona tutte tutta la gerarchia delle prestazioni per id profilo
-- =============================================
CREATE PROCEDURE [dbo].[CorePrestazioniSelectByIDProfilo]
	@IDProfilo UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON;
		
	SELECT P.*		
	FROM CorePrestazioniSelect P
		INNER JOIN [dbo].[GetProfiloGerarchia2](@IDProfilo) Gerarchia
			ON P.ID = Gerarchia.IDFiglio
	WHERE P.Tipo = 0
	ORDER BY P.Codice
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByIDProfilo] TO [DataAccessMsg]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[CorePrestazioniSelectByIDProfilo] TO [DataAccessWs]
    AS [dbo];

