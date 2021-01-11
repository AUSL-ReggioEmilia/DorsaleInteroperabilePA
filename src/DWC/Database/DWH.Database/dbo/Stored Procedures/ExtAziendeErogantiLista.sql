

-- =============================================
-- Author:		ETTORE
-- Create date: 2019-02-22
-- Description:	Legge la lista delle aziende eroganti
-- =============================================
CREATE PROCEDURE [dbo].[ExtAziendeErogantiLista]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT 
		AziendaErogante 
	FROM dbo.SistemiEroganti WITH(NOLOCK)

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ExtAziendeErogantiLista] TO [ExecuteExt]
    AS [dbo];

