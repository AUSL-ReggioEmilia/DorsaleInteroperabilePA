


-- =============================================
-- Author:      Ettore
-- Create date: 2015-05-22
-- Modify date: 
-- Description: Ottiene la lista XML dei codici di oscuramento di tutti gli oscuramenti a cui l'evento è soggetto, 
--	se presenti restituisce gli Id dei ruoli che possono bypassare l'oscuramento
-- =============================================

CREATE FUNCTION [dbo].[GetEventoOscuramentiXml]
(
	@AziendaErogante varchar(16),
	@NumeroNosologico varchar(64)
)  
RETURNS XML
AS
BEGIN

	RETURN (
			SELECT CAST( 
				(	SELECT CodiceOscuramento, IdRuolo 
					FROM dbo.GetEventoOscuramenti(@AziendaErogante, @NumeroNosologico) AS Oscuramento 
					FOR XML AUTO , ROOT('Oscuramenti') )  AS XML
			)
		) 
END

