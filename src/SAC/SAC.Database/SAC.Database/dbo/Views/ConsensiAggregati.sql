




CREATE VIEW [dbo].[ConsensiAggregati]
AS
SELECT 
	Id 
FROM Consensi C
	INNER JOIN (
		SELECT DISTINCT
			C.IdPAziente, C.DataStato, C.DataInserimento, C.IdTipo
		FROM 
			Consensi as C
			INNER JOIN (
				SELECT 
					C.IdPAziente, C.IdTipo, C.DataStato, Max(C.DataInserimento) AS DataInserimentoMax
				FROM 
					Consensi C 
					INNER JOIN 
					( 
						SELECT 
							C.IdPaziente, C.IdTipo, Max(C.DataStato) AS DataStatoMax
						FROM 
							Consensi C 
						WHERE 
							C.Disattivato = 0
						GROUP BY C.IdPaziente, C.IdTipo
					) AS TAB1
					ON C.IdPAziente = TAB1.IdPAziente and c.IdTipo = TAB1.IdTipo and C.DataStato = TAB1.DataStatoMax
				GROUP BY 
					C.IdPAziente, C.IdTipo, C.DataStato
			) AS TAB2 
			ON C.IdPAziente = TAB2.IdPAziente 
				AND C.DataStato = TAB2.DataStato
				AND C.dataInserimento = TAB2.DataInserimentoMax 
		GROUP BY
		C.IdPAziente, C.DataStato, C.DataInserimento, C.IdTipo
	) AS TAB3 
	ON C.IdPaziente = TAB3.IdPaziente 
		AND C.DataStato = TAB3.DataStato
		AND C.DataInserimento = TAB3.DataInserimento
		AND C.IdTipo = TAB3.IdTipo






