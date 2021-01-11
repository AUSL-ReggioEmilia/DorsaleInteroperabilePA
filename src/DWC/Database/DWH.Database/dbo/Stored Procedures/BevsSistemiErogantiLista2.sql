
-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-02-03
-- Description: Ritorna una lista di sistemi eroganti (filtri opzionali)
-- Modify date: 2017-09-12: SimoneB - Modificato il campo Descrizione componendo Codice + Descrizione.
-- Modify date: 2018-01-18: Ettore  - Aggiunta la gestione del tipo 'NoteAnamnestiche'
-- =============================================
CREATE PROCEDURE [dbo].[BevsSistemiErogantiLista2]
(
	@AziendaErogante varchar(16) = NULL
  , @Tipo varchar(32) = NULL --'referti', 'ricoveri'
)
AS
BEGIN 
	SET NOCOUNT ON;
	
	SELECT DISTINCT
		  SistemaErogante AS Codice
		,SistemaErogante + ISNULL(' (' + Descrizione + ')','') As Descrizione
	FROM 
		SistemiEroganti 
	WHERE
		(@AziendaErogante IS NULL OR AziendaErogante = @AziendaErogante)
		AND 
		(
			(TipoReferti = 1 AND @Tipo = 'referti')
			OR
			(TipoRicoveri = 1 AND @Tipo = 'ricoveri')
			OR
			(TipoNoteAnamnestiche = 1 AND @Tipo = 'NoteAnamnestiche')
			OR
			(@Tipo IS NULL)			
		)
	ORDER BY 
		Descrizione


	SET NOCOUNT OFF;
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[BevsSistemiErogantiLista2] TO [ExecuteFrontEnd]
    AS [dbo];

