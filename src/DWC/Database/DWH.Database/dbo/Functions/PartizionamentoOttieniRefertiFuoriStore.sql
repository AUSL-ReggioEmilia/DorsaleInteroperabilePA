
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-24
-- Modify date: 2016-01-08: EttoreG - Aggiunto filtro su DELTA DataReferto, DataPartizione
-- Modify date: 2016-04-26: Sandro - Non gestisco se data nel futuro
-- Description:	Ritorna la lista dei referti fuori dallo store coerente
--					in seguito ad aggiornamenti della DataReferto
-- =============================================
CREATE FUNCTION [dbo].[PartizionamentoOttieniRefertiFuoriStore]
(	
	@MaxRecord INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP(@MaxRecord) 
		[ID], [DataPartizione]
		, [DataReferto]
		, DATEDIFF( MINUTE, [DataPartizione], [DataReferto]) DeltaMinuti
	FROM 
		[store].[RefertiBase] WITH(NOLOCK)
	WHERE 
		--Prima del 2008 tutti nello store 0
		    [DataReferto] >= '2008-01-01'

		-- Non gestisco se data nel futuro (2016-04-26: Sandro)
		AND [DataReferto] < DATEADD(DAY, 60, GETDATE())

		-- Delta minimo tra DataPartizione e DataReferto (2016-01-08: EttoreG)
		AND ABS(DATEDIFF(MINUTE,DataReferto, DataPartizione)) > 3600	

		--Anno Referto  e Partizione diverso
		AND	(
			YEAR([DataPartizione]) <> YEAR([DataReferto])
			--Anno uguale e partizione 3 settimana GENNAIO diversa
			OR (
				YEAR([DataPartizione]) = YEAR([DataReferto])
				AND (
					DATEPART(WEEK, [DataPartizione]) < 3 AND DATEPART(WEEK, [DataReferto]) > 3
					
					-- 3 settimana controllo orario 12:00
					OR (DATEPART(WEEK, [DataPartizione]) = 3 AND DATEPART(WEEK, [DataReferto]) = 3
						AND DATEPART(HOUR, [DataPartizione]) < 12 AND DATEPART(HOUR, [DataReferto]) >= 12
						)
					)
				)
			)
	ORDER BY [DataReferto]
)