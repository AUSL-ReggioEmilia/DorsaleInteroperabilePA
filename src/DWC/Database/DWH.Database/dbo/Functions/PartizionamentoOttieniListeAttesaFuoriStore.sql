


-- =============================================
-- Author:		Ettore Garulli
-- Create date: 2016-09-09: Per spostare le liste di attesa aperte nello store corrente (Ogni anno sposta le liste di attesa aperte nello store dell'anno corrente)
-- Description:	Restituisce la lista dei nosologici di lista di attesa APERTI che non sono già nello store più recente
-- =============================================
CREATE FUNCTION [dbo].[PartizionamentoOttieniListeAttesaFuoriStore]
(	
	@MaxRecord INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP(@MaxRecord)
			NumeroNosologico, AziendaErogante
			, DataPartizione, DataAccettazione
			, DATEDIFF( MINUTE, DataPartizione, DataAccettazione) AS DeltaMinuti
	FROM 
		store.RicoveriBase WITH(NOLOCK)
	WHERE 
		----Solo ultimi 5 anni	
		DataAccettazione >= DATEADD(YEAR, -5, GETDATE())
		
		---- Non gestisco se data nel futuro
		AND [DataAccettazione] < DATEADD(DAY, 60, GETDATE())
		
		--Anno Referto  e Partizione diverso
		AND	(YEAR(DataPartizione) < YEAR(GETDATE())
			OR (
					YEAR(DataPartizione) = YEAR(GETDATE())
				AND DATEPART(WEEK, DataPartizione) <= 3
				AND DATEPART(WEEKDAY, DataPartizione) <= 4
				AND DATEPART(HOUR, DataPartizione) < 12
				)
			)
		--
		-- Elaboro tutti i nosologici di liste di attesa aperte
		--
		AND StatoCodice IN (20,21,23) --Includo le liste di attesa aperte 
	ORDER BY DataAccettazione
)