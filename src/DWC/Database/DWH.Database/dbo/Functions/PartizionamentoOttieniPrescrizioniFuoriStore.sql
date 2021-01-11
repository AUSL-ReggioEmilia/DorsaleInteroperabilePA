

-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-24
-- Modify date: 2016-01-08: ETTORE - aggiunto filtro ABS(DATEDIFF(MINUTE, DataPrescrizione, DataPartizione)) > 3600
-- Modify date: 2016-04-27: ETTORE - Non gestisco se data nel futuro
-- Description:	Restituisce la lista delle prescrizioni fuori dallo store coerente
--					in seguito ad aggiornamenti della DataPrescrizione
-- =============================================
CREATE FUNCTION [dbo].[PartizionamentoOttieniPrescrizioniFuoriStore]
(	
	@MaxRecord INT
)
RETURNS TABLE 
AS
RETURN 
(
/*
	MODIFICA ETTORE 2016-01-08: aggiunto filtro ABS(DATEDIFF(MINUTE, DataPrescrizione, DataPartizione)) > 3600
*/
	SELECT TOP(@MaxRecord) 
		[ID], [DataPartizione]
		, [DataPrescrizione]
		, DATEDIFF( MINUTE, [DataPartizione], [DataPrescrizione]) DeltaMinuti
	FROM 
		[store].[Prescrizioni]
	WHERE 
		--Prima del 2008 tutti nello store 0
		[DataPrescrizione] >= '2008-01-01'

		-- Non gestisco se data nel futuro (2016-04-26: Sandro)
		AND [DataPrescrizione] < DATEADD(DAY, 60, GETDATE())
		
		-- Delta minimo tra DataPartizione e DataPrescrizione (2016-01-08: ETTORE)
		AND ABS(DATEDIFF(MINUTE, DataPrescrizione, DataPartizione)) > 3600	
		
		--Anno Referto  e Partizione diverso
		AND	(
			YEAR([DataPartizione]) <> YEAR([DataPrescrizione])
			--Anno uguale e mese partizione GENNAIO e mese Referto e Partizione diverso
			OR (
				YEAR([DataPartizione]) = YEAR([DataPrescrizione]) 
				AND MONTH([DataPartizione]) <> MONTH([DataPrescrizione])
				AND MONTH([DataPartizione]) = 1)
			)
	ORDER BY [DataPrescrizione]
)