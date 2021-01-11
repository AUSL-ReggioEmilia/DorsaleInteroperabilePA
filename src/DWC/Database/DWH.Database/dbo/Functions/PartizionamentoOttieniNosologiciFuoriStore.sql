
-- =============================================
-- Author:		Alessandro Nostini
-- Create date: 2015-11-24
-- Modify date: 2016-01-07: Ettore - si cerca solo eventi A e IL con StatoCodice=0. Corretto filtri date dove non era stata messa la data DataEvento
-- Modify date: 2016-01-08: Ettore - aggiunto filtro ABS(DATEDIFF(MINUTE,DataEvento, DataPartizione)) > 3600
-- Modify date: 2016-01-28: Ettore - Prima si cercava nella tabella store.EventiBase. Ora si cerca nella tabella store.RicoveriBase (la query diventa simile alla ricerca referti fuori store)
-- Modify date: 2016-04-27: Ettore - Non gestisco se data nel futuro
-- Modify date: 2016-09-09: Ettore - escludo le liste attesa aperte
-- Modify date: 2016-09-21: Sandro - Verifico anche eventi con data partizione diversa da quella rdel ricovero
-- Description:	Ritorna la lista degli eventi fuori dallo store coerente
--					in seguito ad aggiornamenti della DataReferto
-- =============================================
CREATE FUNCTION [dbo].[PartizionamentoOttieniNosologiciFuoriStore]
(	
	@MaxRecord INT
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT TOP(@MaxRecord) *
	FROM (
		--- Ricoveri con Eventi che hanno data partizione minore del data partizione del ricovero
		---
		SELECT 	NumeroNosologico, AziendaErogante
				, DataPartizione, DataAccettazione
				, DATEDIFF( MINUTE, DataPartizione, DataAccettazione) AS DeltaMinuti
		FROM 
			(
			--
			-- Aggrega Riecoveri ed eventi per valutare la dataPartizione di entrambi
			--
			SELECT rb.NumeroNosologico, rb.AziendaErogante
					, MIN(CASE WHEN eb.DataPartizione < rb.DataPartizione THEN eb.DataPartizione ELSE rb.DataPartizione END) AS DataPartizione
					, rb.DataAccettazione
			FROM 
				store.RicoveriBase rb WITH(NOLOCK) 
				INNER JOIN store.EventiBase eb WITH(NOLOCK) 
					ON rb.AziendaErogante = eb.AziendaErogante
					AND rb.NumeroNosologico = eb.NumeroNosologico
				
			WHERE NOT rb.StatoCodice IN (20,21,23)
				AND eb.DataPartizione < rb.DataPartizione
				
			GROUP BY rb.NumeroNosologico, rb.AziendaErogante, rb.DataAccettazione
			) RicoveriBase
		
		WHERE 
			----Prima del 2008 tutti nello store 0	
			DataAccettazione >= '2008-01-01'
		
			AND YEAR(DataPartizione) = 2015
		
			---- Non gestisco se data nel futuro (2016-04-27: Ettore)
			AND [DataAccettazione] < DATEADD(DAY, 60, GETDATE())
		
			AND ABS(DATEDIFF(MINUTE, DataAccettazione, DataPartizione)) > 3600	
			--Anno Referto  e Partizione diverso
			AND	(
				YEAR(DataPartizione) <> YEAR(DataAccettazione)
				--Anno uguale e partizione 3 settimana GENNAIO diversa
				OR (
					YEAR(DataPartizione) = YEAR(DataAccettazione)
					AND (
						DATEPART(WEEK, DataPartizione) < 3 AND DATEPART(WEEK, DataAccettazione) > 3
					
						-- 3 settimana controllo orario 12:00
						OR (DATEPART(WEEK, DataPartizione) = 3 AND DATEPART(WEEK, DataAccettazione) = 3
							AND DATEPART(HOUR, DataPartizione) < 12 AND DATEPART(HOUR, DataAccettazione) >= 12
							)
						)
					)
				)

		UNION ALL
		--
		--- Ricoveri
		---
		SELECT NumeroNosologico, AziendaErogante
				, DataPartizione, DataAccettazione
				, DATEDIFF( MINUTE, DataPartizione, DataAccettazione) AS DeltaMinuti
		FROM 
			store.RicoveriBase rb WITH(NOLOCK)
		
		WHERE 
			----Prima del 2008 tutti nello store 0	
			DataAccettazione >= '2008-01-01'
		
			---- Non gestisco se data nel futuro (2016-04-27: Ettore)
			AND [DataAccettazione] < DATEADD(DAY, 60, GETDATE())
		
			AND ABS(DATEDIFF(MINUTE, DataAccettazione, DataPartizione)) > 3600	
			--Anno Referto  e Partizione diverso
			AND	(
				YEAR(DataPartizione) <> YEAR(DataAccettazione)
				--Anno uguale e partizione 3 settimana GENNAIO diversa
				OR (
					YEAR(DataPartizione) = YEAR(DataAccettazione)
					AND (
						DATEPART(WEEK, DataPartizione) < 3 AND DATEPART(WEEK, DataAccettazione) > 3
					
						-- 3 settimana controllo orario 12:00
						OR (DATEPART(WEEK, DataPartizione) = 3 AND DATEPART(WEEK, DataAccettazione) = 3
							AND DATEPART(HOUR, DataPartizione) < 12 AND DATEPART(HOUR, DataAccettazione) >= 12
							)
						)
					)
				)
			AND NOT StatoCodice IN (20,21,23)	

	) FuoriStore
	ORDER BY DataAccettazione
)