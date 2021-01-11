


-- =============================================
-- Author:      Simone Bitti
-- Create date: 2017-03-02
-- Description: Ritorna una lista di sistemi eroganti (filtri opzionali)
-- =============================================
CREATE PROCEDURE [dbo].[BevsSistemiErogantiCodiciCombo]
(
	@Tipo varchar(10) = NULL --'referti', 'ricoveri'
)
AS
BEGIN 
	SET NOCOUNT ON;
	
	SELECT DISTINCT
		  SistemaErogante AS Codice
		, SistemaErogante AS Descrizione
	FROM 
		SistemiEroganti 
	WHERE
		(
			(TipoReferti = 1 AND @Tipo = 'referti')
			OR
			(TipoRicoveri = 1 AND @Tipo = 'ricoveri')
			OR
			(@Tipo IS NULL)			
		)
	ORDER BY 
		SistemaErogante


	SET NOCOUNT OFF;
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiCodiciCombo] TO [ExecuteFrontEnd]
    AS [dbo];

