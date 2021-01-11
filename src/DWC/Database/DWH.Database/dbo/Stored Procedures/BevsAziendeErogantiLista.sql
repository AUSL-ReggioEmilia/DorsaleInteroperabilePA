CREATE PROCEDURE [dbo].[BevsAziendeErogantiLista]
AS
BEGIN 
	SET NOCOUNT ON;
	SELECT DISTINCT
		SistemiEroganti.AziendaErogante AS Codice
		,SistemiEroganti.AziendaErogante AS Descrizione
	FROM 
		SistemiEroganti 
	ORDER BY
		SistemiEroganti.AziendaErogante
	SET NOCOUNT OFF;
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsAziendeErogantiLista] TO [ExecuteFrontEnd]
    AS [dbo];

