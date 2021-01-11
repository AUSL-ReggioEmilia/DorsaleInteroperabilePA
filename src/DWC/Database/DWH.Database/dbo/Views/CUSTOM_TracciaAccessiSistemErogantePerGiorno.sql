


-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2016-05-11 ETTORE - Usato vista store.Referti al posto di dbo.Referti
-- Description:	Restituisce gli accessi ai referti di un sistema erogante per giorno
-- =============================================
CREATE VIEW [dbo].[CUSTOM_TracciaAccessiSistemErogantePerGiorno]
AS
	SELECT TOP 100 PERCENT
		COUNT(*) AS Numero,
		Year(TracciaAccessi.Data) AS Anno,
		Month(TracciaAccessi.Data) AS Mese,
		Day(TracciaAccessi.Data) AS Giorno,
		store.Referti.SistemaErogante, 
		store.Referti.RepartoErogante

	FROM	
		(
			SELECT * FROM TracciaAccessi WITH(NOLOCK) 
			UNION
			SELECT * FROM TracciaAccessi_Storico WITH(NOLOCK) 
		) AS TracciaAccessi 
		INNER JOIN store.Referti WITH(NOLOCK) 
			ON TracciaAccessi.IdReferti = store.Referti.Id
	GROUP BY Year( TracciaAccessi.Data),
		Month( TracciaAccessi.Data),
		Day( TracciaAccessi.Data),
		store.Referti.SistemaErogante, 
		store.Referti.RepartoErogante
	ORDER BY Year( TracciaAccessi.Data) DESC,
		Month( TracciaAccessi.Data) DESC,
		Day( TracciaAccessi.Data) DESC,
		store.Referti.SistemaErogante, 
		store.Referti.RepartoErogante;

GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_TracciaAccessiSistemErogantePerGiorno] TO [ExecuteFrontEnd]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[CUSTOM_TracciaAccessiSistemErogantePerGiorno] TO [ReadOlap]
    AS [dbo];

