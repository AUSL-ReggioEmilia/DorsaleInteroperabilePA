



-- =============================================
-- Author:		ETTORE
-- Create date: 2017-11-21
-- Description:	Restituisce la lista delle note anamnestiche fuori dallo store coerente
--					in seguito ad aggiornamenti della DataNota
-- =============================================
CREATE FUNCTION [dbo].[PartizionamentoOttieniNoteAnamnesticheFuoriStore]
(	
	@MaxRecord INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP(@MaxRecord) 
		[ID], [DataPartizione]
		, [DataNota]
		, DATEDIFF( MINUTE, [DataPartizione], [DataNota]) DeltaMinuti
	FROM 
		[store].[NoteAnamnestiche]
	WHERE 
		--Prima del 2008 tutti nello store 0	
		[DataNota] >= '2008-01-01'
		-- Non gestisco se data nel futuro
		AND [DataNota] < DATEADD(DAY, 60, GETDATE())
		
		-- Delta minimo tra DataPartizione e DataNota
		AND ABS(DATEDIFF(MINUTE, DataNota, DataPartizione)) > 3600	
		
		--Anno Referto  e Partizione diverso
		AND	(
			YEAR([DataPartizione]) <> YEAR([DataNota])
			--Anno uguale e mese partizione GENNAIO e mese Referto e Partizione diverso
			OR (
				YEAR([DataPartizione]) = YEAR([DataNota]) 
				AND MONTH([DataPartizione]) <> MONTH([DataNota])
				AND MONTH([DataPartizione]) = 1)
			)
	ORDER BY [DataNota]
)