

-- =============================================
-- Author:		???
-- Create date: ???
-- Modify date: 2018-06-19 ETTORE - Usa vista store.RefertiBase al posto della dbo.RefertiBase
-- Description:	 
-- =============================================
CREATE FUNCTION [dbo].[GetRefertiXmlReferto] (@Id uniqueidentifier)  
RETURNS xml AS  
BEGIN 

DECLARE @Ret xml

	IF NOT @ID IS NULL
		--
		-- Solo per i dati
		--
		SET @Ret = (
			SELECT Referto.Id,  Referto.AziendaErogante, 
				Referto.SistemaErogante, Referto.RepartoErogante, 
				Referto.DataReferto, Referto.NumeroReferto, 
				Referto.NumeroPrenotazione, Referto.NumeroNosologico,
				Attributo.Nome, Attributo.Valore
			FROM store.RefertiBase AS Referto INNER JOIN store.RefertiAttributi AS Attributo
				ON Referto.Id = Attributo.IdRefertiBase
			WHERE Referto.Id = @ID
			FOR XML AUTO, ELEMENTS
					)
	ELSE
		--
		-- Solo per lo schema
		--
		SET @Ret = (
			SELECT Referto.Id,  Referto.AziendaErogante, 
				Referto.SistemaErogante, Referto.RepartoErogante, 
				Referto.DataReferto, Referto.NumeroReferto, 
				Referto.NumeroPrenotazione, Referto.NumeroNosologico,
				Attributo.Nome, Attributo.Valore
			FROM store.RefertiBase AS Referto INNER JOIN store.RefertiAttributi AS Attributo
				ON Referto.Id = Attributo.IdRefertiBase
			WHERE 1=2
			FOR XML AUTO, ELEMENTS, XMLDATA
					)

	RETURN @Ret

END



