


-- =============================================
-- Author:      Stefano P.
-- Create date: 2015-05-20
-- Modify date: 2016-10-14 Stefano P.: Aggiunto filtro ApplicaDWH
-- Modify date: 2017-10-16 Ettore: Utilizzo della TABLE FUNCTION generale per gli oscuramenti
-- Description: Ritorna 1 se il referto passato è oscurato da un oscuramento di tipo PUNTUALE
-- =============================================

CREATE FUNCTION [dbo].[GetEventoOscuramentiPuntuali]
(
 @AziendaErogante varchar(16),
 @NumeroNosologico varchar(64)
)  
RETURNS BIT 
AS  
BEGIN
	IF EXISTS (SELECT * FROM [dbo].[OttieniEventoOscuramenti] (
								   NULL
								  ,'Puntuali'
								  ,'DWH'
								  ,@AziendaErogante
								  ,@NumeroNosologico)
					)
	BEGIN 
		RETURN 1 
	END
	RETURN 0
END



