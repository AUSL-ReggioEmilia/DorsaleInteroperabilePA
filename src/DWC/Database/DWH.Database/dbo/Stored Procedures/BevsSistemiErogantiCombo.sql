
-- Date: /
-- Description: /
-- Modify: SimoneB - 2017-09-12, Restituito anche il campo Codice.
CREATE PROCEDURE [dbo].[BevsSistemiErogantiCombo]
(
@AziendaErogante VARCHAR(16)=NULL
)
AS

SET NOCOUNT ON;

SELECT 
	UPPER(CAST(Id AS VARCHAR(40))) AS Id
	,AziendaErogante + ' - ' + Descrizione AS Descrizione
	,AziendaErogante + ' - ' + SistemaErogante as Codice
FROM 
	SistemiEroganti
WHERE
	AziendaErogante = @AziendaErogante OR @AziendaErogante IS NULL
ORDER BY
	AziendaErogante + Descrizione

SET NOCOUNT OFF;

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiCombo] TO [ExecuteFrontEnd]
    AS [dbo];

