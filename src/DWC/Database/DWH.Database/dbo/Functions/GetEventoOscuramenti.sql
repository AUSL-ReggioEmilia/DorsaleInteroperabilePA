



-- =============================================
-- Author:      ETTORE
-- Create date: 2015-05-22
-- Modify date: 2016-10-14 Stefano P.: Aggiunto filtro ApplicaDWH
-- Modify date: 2017-04-07 Ettore: Adeguamento per gestire sistemi eroganti di ricoveri diversi da ADT
-- Modify date: 2017-10-16 Ettore: Utilizzo della TABLE FUNCTION generale per gli oscuramenti
-- Description: Ottiene la lista dei codici di oscuramento di tipo MASSIVO per l'evento ADT, 
--	se presenti restituisce gli Id dei ruoli che possono bypassare l'oscuramento
-- =============================================
CREATE FUNCTION [dbo].[GetEventoOscuramenti]
(
	@AziendaErogante varchar(16),
	@NumeroNosologico varchar(64)
)  
RETURNS TABLE
AS
	RETURN
	
	SELECT CodiceOscuramento, IdRuolo 
	FROM [dbo].[OttieniEventoOscuramenti] (
								   NULL
								  ,'Massivi'
								  ,'DWH'
								  ,@AziendaErogante
								  ,@NumeroNosologico
								  )

